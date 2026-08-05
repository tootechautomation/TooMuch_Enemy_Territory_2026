extends CharacterBody3D

enum PlayerClass { SOLDIER, MEDIC, ENGINEER, FIELD_OPS, SCOUT }

@export var peer_id := 1
@export var team := 0
@export var player_name := "Player"
@export var player_class: PlayerClass = PlayerClass.SOLDIER

var health := 100
var ammo := 30
var speed := 7.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var next_fire_time := 0
var objective_tick := 0
var hud: Label

func _ready() -> void:
	set_multiplayer_authority(peer_id)
	var body := $Body as MeshInstance3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.38, 0.72) if team == 0 else Color(0.72, 0.22, 0.16)
	body.material_override = mat
	if is_multiplayer_authority() and not DisplayServer.get_name() == "headless":
		$Head/Camera3D.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.0025)
		pitch = clamp(pitch - event.relative.y * 0.0025, -1.35, 1.35)
		$Head.rotation.x = pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 5.2

	var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

	if Input.is_action_pressed("fire"):
		_try_fire()
	if Input.is_action_pressed("interact"):
		_try_objective()
	for index in 5:
		if Input.is_action_just_pressed("class_%d" % (index + 1)):
			set_class.rpc_id(1, index)

	_sync_state.rpc(position, rotation.y, $Head.rotation.x)
	_update_hud()

@rpc("any_peer", "unreliable_ordered")
func _sync_state(pos: Vector3, yaw: float, head_pitch: float) -> void:
	if is_multiplayer_authority():
		return
	position = pos
	rotation.y = yaw
	$Head.rotation.x = head_pitch

func _try_fire() -> void:
	var now := Time.get_ticks_msec()
	if now < next_fire_time or ammo <= 0:
		return
	next_fire_time = now + 120
	ammo -= 1
	var camera := $Head/Camera3D as Camera3D
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * 100.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider is CharacterBody3D:
		var target := hit.collider
		if target.team != team:
			target.apply_damage.rpc_id(1, 20, peer_id)

@rpc("any_peer", "reliable")
func apply_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server():
		return
	health -= amount
	set_health.rpc(health)
	if health <= 0:
		health = 100
		position = get_parent()._get_spawn(team, peer_id)
		respawn.rpc(position, health)

@rpc("authority", "call_local", "reliable")
func set_health(value: int) -> void:
	health = value

@rpc("authority", "call_local", "reliable")
func respawn(spawn_position: Vector3, restored_health: int) -> void:
	position = spawn_position
	health = restored_health
	ammo = 30

func _try_objective() -> void:
	if player_class != PlayerClass.ENGINEER or team != 0:
		return
	var objective := get_parent().get_node_or_null("Objective")
	if not objective or global_position.distance_to(objective.global_position) > 3.5:
		return
	var now := Time.get_ticks_msec()
	if now < objective_tick:
		return
	objective_tick = now + 500
	get_parent().damage_objective.rpc_id(1, 5, team)

@rpc("any_peer", "call_local", "reliable")
func set_class(index: int) -> void:
	player_class = clampi(index, 0, 4)
	match player_class:
		PlayerClass.SOLDIER:
			health = 120
			ammo = 45
		PlayerClass.MEDIC:
			health = 110
			ammo = 30
		PlayerClass.ENGINEER:
			health = 100
			ammo = 30
		PlayerClass.FIELD_OPS:
			health = 100
			ammo = 36
		PlayerClass.SCOUT:
			health = 90
			ammo = 24

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
	if not hud:
		return
	var names := ["Soldier", "Medic", "Engineer", "Field Ops", "Scout"]
	var objective_health := get_parent().objective_health
	hud.text = "%s | Team %s\nHP %d  Ammo %d\nObjective %d%%\nClass: %s (1–5)" % [
		player_name,
		"Attackers" if team == 0 else "Defenders",
		health,
		ammo,
		objective_health,
		names[player_class]
	]
