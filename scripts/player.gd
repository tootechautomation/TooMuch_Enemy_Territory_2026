extends CharacterBody3D

enum PlayerClass { SOLDIER, MEDIC, ENGINEER, FIELD_OPS, SCOUT }

@export var peer_id := 0
@export var team := 0
@export var player_name := "Player"
@export var player_class: PlayerClass = PlayerClass.SOLDIER
@export var weapon: WeaponDefinition = preload("res://data/weapons/service_rifle.tres")

const WALK_SPEED := 7.0
const SPRINT_SPEED := 10.0
const CROUCH_SPEED := 4.0
const JUMP_SPEED := 5.2
const OBJECTIVE_INTERVAL_MS := 500
const SNAPSHOT_LERP_SPEED := 14.0
const ABILITY_COOLDOWN_MS := 8000
const SUPPORT_RANGE := 7.0

var health := 100
var ammo_in_mag := 30
var reserve_ammo := 120
var alive := true
var is_reloading := false
var reload_finish_ms := 0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var input_vector := Vector2.ZERO
var jump_requested := false
var sprint_requested := false
var crouch_requested := false
var last_received_sequence := 0
var local_sequence := 0
var next_fire_time := 0
var next_objective_time := 0
var next_ability_time := 0
var kills := 0
var deaths := 0
var target_position := Vector3.ZERO
var target_yaw := 0.0
var target_pitch := 0.0
var hud: Label

func _ready() -> void:
	ammo_in_mag = weapon.magazine_size
	reserve_ammo = weapon.reserve_ammo
	target_position = global_position
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
		rotation.y -= event.relative.x * 0.0025
		pitch = clampf(pitch - event.relative.y * 0.0025, -1.35, 1.35)
		$Head.rotation.x = pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if _is_local_player():
		_collect_and_send_input()
		_update_hud()
	elif not multiplayer.is_server():
		global_position = global_position.lerp(target_position, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		$Head.rotation.x = lerp_angle($Head.rotation.x, target_pitch, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
	if multiplayer.is_server():
		_server_simulate(delta)

func _collect_and_send_input() -> void:
	if not alive:
		return
	local_sequence += 1
	var move := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	submit_input.rpc_id(1, move, rotation.y, pitch, Input.is_action_just_pressed("jump"), Input.is_action_pressed("sprint"), Input.is_action_pressed("crouch"), local_sequence)
	if Input.is_action_pressed("fire"):
		var camera := $Head/Camera3D as Camera3D
		request_fire.rpc_id(1, camera.global_position, -camera.global_transform.basis.z)
	if Input.is_action_just_pressed("reload"):
		request_reload.rpc_id(1)
	if Input.is_action_pressed("interact"):
		request_objective_action.rpc_id(1)
	if Input.is_action_just_pressed("ability"):
		request_class_ability.rpc_id(1)
	for index in 5:
		if Input.is_action_just_pressed("class_%d" % (index + 1)):
			request_class.rpc_id(1, index)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_input(move: Vector2, yaw: float, look_pitch: float, wants_jump: bool, wants_sprint: bool, wants_crouch: bool, sequence: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or sequence <= last_received_sequence:
		return
	last_received_sequence = sequence
	input_vector = move.limit_length(1.0)
	rotation.y = yaw
	pitch = clampf(look_pitch, -1.35, 1.35)
	$Head.rotation.x = pitch
	jump_requested = jump_requested or wants_jump
	sprint_requested = wants_sprint
	crouch_requested = wants_crouch

func _server_simulate(delta: float) -> void:
	if is_reloading and Time.get_ticks_msec() >= reload_finish_ms:
		_finish_reload()
	if not alive:
		velocity = Vector3.ZERO
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jump_requested and not crouch_requested:
		velocity.y = JUMP_SPEED
	jump_requested = false
	var move_speed := CROUCH_SPEED if crouch_requested else (SPRINT_SPEED if sprint_requested and input_vector.y < -0.2 else WALK_SPEED)
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()
	replicate_state.rpc(global_position, rotation.y, $Head.rotation.x, health, ammo_in_mag, reserve_ammo, alive, is_reloading, player_class)

@rpc("authority", "call_remote", "unreliable_ordered")
func replicate_state(pos: Vector3, yaw: float, head_pitch: float, hp: int, magazine: int, reserve: int, is_alive: bool, reloading: bool, class_id: int) -> void:
	if multiplayer.is_server():
		return
	target_position = pos
	target_yaw = yaw
	target_pitch = head_pitch
	if _is_local_player():
		global_position = pos
	health = hp
	ammo_in_mag = magazine
	reserve_ammo = reserve
	alive = is_alive
	is_reloading = reloading
	player_class = class_id
	visible = alive

@rpc("any_peer", "call_remote", "reliable")
func request_fire(origin: Vector3, direction: Vector3) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive or is_reloading:
		return
	var now := Time.get_ticks_msec()
	if now < next_fire_time or ammo_in_mag <= 0 or origin.distance_to($Head.global_position) > 2.0:
		return
	next_fire_time = now + weapon.fire_interval_ms()
	ammo_in_mag -= 1
	var moving := input_vector.length() > 0.15
	var spread := weapon.moving_spread_degrees if moving else weapon.hip_spread_degrees
	var shot_direction := _apply_spread(direction.normalized(), spread)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + shot_direction * weapon.range_meters)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider is CharacterBody3D:
		var target = hit.collider
		if target.has_method("server_take_damage") and target.team != team:
			target.server_take_damage(weapon.damage, peer_id)

func _apply_spread(direction: Vector3, degrees: float) -> Vector3:
	var spread_radians := deg_to_rad(degrees)
	var yaw_offset := randf_range(-spread_radians, spread_radians)
	var pitch_offset := randf_range(-spread_radians, spread_radians)
	return direction.rotated(Vector3.UP, yaw_offset).rotated(global_transform.basis.x, pitch_offset).normalized()

@rpc("any_peer", "call_remote", "reliable")
func request_reload() -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive:
		return
	if is_reloading or ammo_in_mag >= weapon.magazine_size or reserve_ammo <= 0:
		return
	is_reloading = true
	reload_finish_ms = Time.get_ticks_msec() + int(weapon.reload_seconds * 1000.0)

func _finish_reload() -> void:
	var needed := weapon.magazine_size - ammo_in_mag
	var transferred := mini(needed, reserve_ammo)
	ammo_in_mag += transferred
	reserve_ammo -= transferred
	is_reloading = false

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not alive:
		return
	health = maxi(0, health - amount)
	if health == 0:
		alive = false
		deaths += 1
		is_reloading = false
		visible = false
		velocity = Vector3.ZERO
		print("Peer %d eliminated by peer %d" % [peer_id, attacker_id])

func server_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	global_position = spawn_position
	target_position = spawn_position
	health = _class_health(player_class)
	ammo_in_mag = weapon.magazine_size
	reserve_ammo = weapon.reserve_ammo
	alive = true
	is_reloading = false
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
func request_class_ability() -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive:
		return
	var now := Time.get_ticks_msec()
	if now < next_ability_time:
		return
	next_ability_time = now + ABILITY_COOLDOWN_MS
	match player_class:
		PlayerClass.SOLDIER:
			reserve_ammo = mini(reserve_ammo + 45, weapon.reserve_ammo + 90)
		PlayerClass.MEDIC:
			_support_heal()
		PlayerClass.ENGINEER:
			health = mini(_class_health(player_class), health + 25)
		PlayerClass.FIELD_OPS:
			_support_ammo()
		PlayerClass.SCOUT:
			health = mini(_class_health(player_class), health + 15)

func _support_heal() -> void:
	for candidate in get_parent().players.values():
		if candidate != self and candidate.team == team and candidate.alive and global_position.distance_to(candidate.global_position) <= SUPPORT_RANGE:
			candidate.health = mini(candidate._class_health(candidate.player_class), candidate.health + 45)

func _support_ammo() -> void:
	for candidate in get_parent().players.values():
		if candidate.team == team and candidate.alive and global_position.distance_to(candidate.global_position) <= SUPPORT_RANGE:
			candidate.reserve_ammo = mini(candidate.reserve_ammo + 60, candidate.weapon.reserve_ammo + 120)

@rpc("any_peer", "call_remote", "reliable")
func request_class(index: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id:
		return
	player_class = clampi(index, 0, 4)
	health = mini(health, _class_health(player_class))

func _class_health(class_id: int) -> int:
	match class_id:
		PlayerClass.SOLDIER: return 120
		PlayerClass.MEDIC: return 110
		PlayerClass.SCOUT: return 90
		_: return 100

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
	var weapon_state := "RELOADING" if is_reloading else weapon.display_name
	var cooldown := maxf(0.0, float(next_ability_time - Time.get_ticks_msec()) / 1000.0)
	hud.text = "%s | %s | %s\nHP %d  Ammo %d/%d  %s\nObjective %d%%  Time %02d:%02d\nClass: %s (1–5)  Ability Q: %.1fs" % [player_name, "Attackers" if team == 0 else "Defenders", life_text, health, ammo_in_mag, reserve_ammo, weapon_state, main.objective_health, minutes, seconds, names[player_class], cooldown]
