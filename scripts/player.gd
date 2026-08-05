extends CharacterBody3D

enum PlayerClass { SOLDIER, MEDIC, ENGINEER, FIELD_OPS, SCOUT }

@export var peer_id := 0
@export var team := 0
@export var player_name := "Player"
@export var player_class: PlayerClass = PlayerClass.SOLDIER

const MOVE_SPEED := 7.0
const JUMP_SPEED := 5.2
const FIRE_INTERVAL_MS := 120
const OBJECTIVE_INTERVAL_MS := 500

var health := 100
var ammo := 30
var alive := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var input_vector := Vector2.ZERO
var jump_requested := false
var last_input_sequence := 0
var next_fire_time := 0
var next_objective_time := 0
var hud: Label

func _ready() -> void:
	var body := $Body as MeshInstance3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.38, 0.72) if team == 0 else Color(0.72, 0.22, 0.16)
	body.material_override = mat
	if _is_local_player() and DisplayServer.get_name() != "headless":
		$Head/Camera3D.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_local_player() or not alive:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.0025)
		pitch = clampf(pitch - event.relative.y * 0.0025, -1.35, 1.35)
		$Head.rotation.x = pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if _is_local_player():
		_collect_and_send_input()
		_update_hud()
	if multiplayer.is_server():
		_server_simulate(delta)

func _collect_and_send_input() -> void:
	if not alive:
		return
	last_input_sequence += 1
	var move := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wants_jump := Input.is_action_just_pressed("jump")
	submit_input.rpc_id(1, move, rotation.y, pitch, wants_jump, last_input_sequence)
	if Input.is_action_pressed("fire"):
		var camera := $Head/Camera3D as Camera3D
		request_fire.rpc_id(1, camera.global_position, -camera.global_transform.basis.z)
	if Input.is_action_pressed("interact"):
		request_objective_action.rpc_id(1)
	for index in 5:
		if Input.is_action_just_pressed("class_%d" % (index + 1)):
			request_class.rpc_id(1, index)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_input(move: Vector2, yaw: float, look_pitch: float, wants_jump: bool, sequence: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id:
		return
	if sequence <= last_input_sequence:
		return
	last_input_sequence = sequence
	input_vector = move.limit_length(1.0)
	rotation.y = yaw
	pitch = clampf(look_pitch, -1.35, 1.35)
	$Head.rotation.x = pitch
	jump_requested = jump_requested or wants_jump

func _server_simulate(delta: float) -> void:
	if not alive:
		velocity = Vector3.ZERO
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jump_requested:
		velocity.y = JUMP_SPEED
	jump_requested = false
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	move_and_slide()
	replicate_state.rpc(global_position, rotation.y, $Head.rotation.x, health, ammo, alive, player_class)

@rpc("authority", "call_remote", "unreliable_ordered")
func replicate_state(pos: Vector3, yaw: float, head_pitch: float, hp: int, rounds: int, is_alive: bool, class_id: int) -> void:
	if multiplayer.is_server():
		return
	global_position = pos
	rotation.y = yaw
	$Head.rotation.x = head_pitch
	health = hp
	ammo = rounds
	alive = is_alive
	player_class = class_id
	visible = alive

@rpc("any_peer", "call_remote", "reliable")
func request_fire(origin: Vector3, direction: Vector3) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive:
		return
	var now := Time.get_ticks_msec()
	if now < next_fire_time or ammo <= 0:
		return
	if origin.distance_to($Head.global_position) > 2.0:
		return
	next_fire_time = now + FIRE_INTERVAL_MS
	ammo -= 1
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * 100.0)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider is CharacterBody3D:
		var target = hit.collider
		if target.has_method("server_take_damage") and target.team != team:
			target.server_take_damage(20, peer_id)

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not alive:
		return
	health = maxi(0, health - amount)
	if health == 0:
		alive = false
		visible = false
		velocity = Vector3.ZERO
		print("Peer %d eliminated by peer %d" % [peer_id, attacker_id])

func server_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	global_position = spawn_position
	health = _class_health(player_class)
	ammo = _class_ammo(player_class)
	alive = true
	visible = true
	velocity = Vector3.ZERO
	input_vector = Vector2.ZERO

@rpc("any_peer", "call_remote", "reliable")
func request_objective_action() -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive:
		return
	if player_class != PlayerClass.ENGINEER or team != 0:
		return
	var objective := get_parent().get_node_or_null("Objective")
	if objective == null or global_position.distance_to(objective.global_position) > 3.5:
		return
	var now := Time.get_ticks_msec()
	if now < next_objective_time:
		return
	next_objective_time = now + OBJECTIVE_INTERVAL_MS
	get_parent().damage_objective(5, team)

@rpc("any_peer", "call_remote", "reliable")
func request_class(index: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id:
		return
	player_class = clampi(index, 0, 4)
	health = mini(health, _class_health(player_class))
	ammo = _class_ammo(player_class)

func _class_health(class_id: int) -> int:
	match class_id:
		PlayerClass.SOLDIER: return 120
		PlayerClass.MEDIC: return 110
		PlayerClass.SCOUT: return 90
		_: return 100

func _class_ammo(class_id: int) -> int:
	match class_id:
		PlayerClass.SOLDIER: return 45
		PlayerClass.FIELD_OPS: return 36
		PlayerClass.SCOUT: return 24
		_: return 30

func _is_local_player() -> bool:
	return peer_id != 0 and peer_id == multiplayer.get_unique_id()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(18, 18)
	hud.add_theme_font_size_override("font_size", 18)
	layer.add_child(hud)
	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.position = Vector2(638, 350)
	crosshair.add_theme_font_size_override("font_size", 24)
	layer.add_child(crosshair)

func _update_hud() -> void:
	if hud == null:
		return
	var names := ["Soldier", "Medic", "Engineer", "Field Ops", "Scout"]
	var main = get_parent()
	var minutes := int(main.match_time_remaining) / 60
	var seconds := int(main.match_time_remaining) % 60
	var life_text := "ALIVE" if alive else "RESPAWN IN %.1f" % main.spawn_wave_remaining
	hud.text = "%s | %s | %s\nHP %d  Ammo %d\nObjective %d%%  Time %02d:%02d\nClass: %s (1–5)" % [
		player_name,
		"Attackers" if team == 0 else "Defenders",
		life_text,
		health,
		ammo,
		main.objective_health,
		minutes,
		seconds,
		names[player_class]
	]
