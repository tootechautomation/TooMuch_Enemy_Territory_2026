extends CharacterBody3D

enum PlayerClass { SOLDIER, MEDIC, ENGINEER, FIELD_OPS, SCOUT }

@export var peer_id := 0
@export var team := 0
@export var player_name := "Player"
@export var player_class: PlayerClass = PlayerClass.SOLDIER
const SERVICE_RIFLE: WeaponDefinition = preload("res://data/weapons/service_rifle.tres")
const SERVICE_PISTOL: WeaponDefinition = preload("res://data/weapons/service_pistol.tres")

@export var weapon: WeaponDefinition = SERVICE_RIFLE

const WALK_SPEED := 7.0
const SPRINT_SPEED := 10.0
const CROUCH_SPEED := 4.0
const JUMP_SPEED := 5.2
const SNAPSHOT_LERP_SPEED := 14.0
const ABILITY_COOLDOWN_MS := 8000
const REVIVE_RANGE := 2.8
const BLEEDOUT_MS := 15000

var health := 100
var ammo_in_mag := 30
var reserve_ammo := 120
var alive := true
var downed := false
var bleedout_finish_ms := 0
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
var next_interact_time := 0
var next_ability_time := 0
var kills := 0
var deaths := 0
var xp := 0
var is_bot := false
var interact_accumulator := 0.0
var bot_think_accumulator := 0.0
var bot_fire_accumulator := 0.0
var target_position := Vector3.ZERO
var target_yaw := 0.0
var target_pitch := 0.0
var hud: Label
var scoreboard: Label
var feed: Label
var weapon_view: Node3D
var spectator_target_id := 0
var spectator_index := -1
var weapon_slots: Array[WeaponDefinition] = []
var weapon_magazines: Array[int] = []
var weapon_reserves: Array[int] = []
var current_weapon_index := 0
var hit_marker: Label
var hit_marker_until_ms := 0
var grenades_remaining := 2
var next_grenade_time := 0

func _ready() -> void:
	_initialize_loadout()
	target_position = global_position
	if _is_local_player() and DisplayServer.get_name() != "headless":
		$Head/Camera3D.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_first_person_weapon()
		_build_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_local_player():
		return

	if event is InputEventMouseMotion and alive and not downed:
		rotation.y -= event.relative.x * 0.0025
		pitch = clampf(pitch - event.relative.y * 0.0025, -1.35, 1.35)
		$Head.rotation.x = pitch

	if event.is_action_pressed("spectator_next") and not alive:
		_cycle_spectator_target()

	if event.is_action_pressed("weapon_switch") and alive and not downed:
		request_weapon_switch.rpc_id(1)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and is_bot:
		_server_bot_tick(delta)
		return

	if _is_local_player():
		_collect_and_send_input()
		_update_spectator_camera()
		_update_hud()
	elif not multiplayer.is_server():
		global_position = global_position.lerp(target_position, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		$Head.rotation.x = lerp_angle($Head.rotation.x, target_pitch, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
	if multiplayer.is_server(): _server_simulate(delta)

func _collect_and_send_input() -> void:
	if not alive:
		return

	local_sequence += 1
	var move := Vector2.ZERO if downed else Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	submit_input.rpc_id(
		1,
		move,
		rotation.y,
		pitch,
		Input.is_action_just_pressed("jump"),
		Input.is_action_pressed("sprint"),
		Input.is_action_pressed("crouch"),
		local_sequence
	)

	if not downed and Input.is_action_pressed("fire"):
		var camera := $Head/Camera3D as Camera3D
		request_fire.rpc_id(1, camera.global_position, -camera.global_transform.basis.z)

	if not downed and Input.is_action_just_pressed("reload"):
		request_reload.rpc_id(1)

	if not downed and Input.is_action_just_pressed("throw_grenade"):
		var grenade_camera: Camera3D = $Head/Camera3D as Camera3D
		if grenade_camera != null:
			request_throw_grenade.rpc_id(
				1,
				grenade_camera.global_position,
				-grenade_camera.global_transform.basis.z
			)

	if Input.is_action_pressed("interact"):
		interact_accumulator += get_physics_process_delta_time()
		if interact_accumulator >= 0.25:
			interact_accumulator = 0.0
			request_interact.rpc_id(1)
	else:
		interact_accumulator = 0.0

	if not downed and Input.is_action_just_pressed("ability"):
		request_class_ability.rpc_id(1)

	for index in 5:
		if Input.is_action_just_pressed("class_%d" % (index + 1)):
			request_class.rpc_id(1, index)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_input(move: Vector2, yaw: float, look_pitch: float, wants_jump: bool, wants_sprint: bool, wants_crouch: bool, sequence: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or sequence <= last_received_sequence: return
	last_received_sequence = sequence; input_vector = move.limit_length(1.0); rotation.y = yaw; pitch = clampf(look_pitch, -1.35, 1.35); $Head.rotation.x = pitch
	jump_requested = jump_requested or wants_jump; sprint_requested = wants_sprint; crouch_requested = wants_crouch

func _server_simulate(delta: float) -> void:
	var now := Time.get_ticks_msec()
	if is_reloading and now >= reload_finish_ms: _finish_reload()
	if downed and now >= bleedout_finish_ms: _finish_death(0)
	if not alive or downed:
		velocity = Vector3.ZERO
		replicate_state.rpc(global_position, rotation.y, $Head.rotation.x, health, ammo_in_mag, reserve_ammo, alive, downed, is_reloading, player_class, kills, deaths, xp, current_weapon_index, grenades_remaining)
		return
	if not is_on_floor(): velocity.y -= gravity * delta
	elif jump_requested and not crouch_requested: velocity.y = JUMP_SPEED
	jump_requested = false
	var move_speed := CROUCH_SPEED if crouch_requested else (SPRINT_SPEED if sprint_requested and input_vector.y < -0.2 else WALK_SPEED)
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	velocity.x = direction.x * move_speed; velocity.z = direction.z * move_speed; move_and_slide()
	replicate_state.rpc(global_position, rotation.y, $Head.rotation.x, health, ammo_in_mag, reserve_ammo, alive, downed, is_reloading, player_class, kills, deaths, xp, current_weapon_index, grenades_remaining)

@rpc("authority", "call_remote", "unreliable_ordered")
func replicate_state(pos: Vector3, yaw: float, head_pitch: float, hp: int, magazine: int, reserve: int, is_alive: bool, is_downed: bool, reloading: bool, class_id: int, kill_count: int, death_count: int, experience: int, weapon_index: int, grenade_count: int) -> void:
	if multiplayer.is_server(): return
	target_position = pos; target_yaw = yaw; target_pitch = head_pitch
	if _is_local_player(): global_position = pos
	health = hp
	alive = is_alive
	downed = is_downed
	is_reloading = reloading
	player_class = class_id
	kills = kill_count
	deaths = death_count
	xp = experience
	grenades_remaining = grenade_count

	if weapon_index != current_weapon_index:
		_apply_weapon_index(weapon_index, false)

	ammo_in_mag = magazine
	reserve_ammo = reserve
	if current_weapon_index < weapon_magazines.size():
		weapon_magazines[current_weapon_index] = ammo_in_mag
		weapon_reserves[current_weapon_index] = reserve_ammo

	visible = alive
	if weapon_view:
		weapon_view.visible = alive and not downed

@rpc("any_peer", "call_remote", "reliable")
func request_fire(origin: Vector3, direction: Vector3) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive or downed or is_reloading: return
	var now := Time.get_ticks_msec()
	if now < next_fire_time or ammo_in_mag <= 0 or origin.distance_to($Head.global_position) > 2.0: return
	next_fire_time = now + weapon.fire_interval_ms()
	ammo_in_mag -= 1
	_store_current_weapon_ammo()
	var spread := weapon.moving_spread_degrees if input_vector.length() > 0.15 else weapon.hip_spread_degrees
	var shot_direction := _apply_spread(direction.normalized(), spread)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + shot_direction * weapon.range_meters); query.exclude = [self]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.get("collider") is CharacterBody3D:
		var target: CharacterBody3D = hit.get("collider") as CharacterBody3D
		if target != null and target.has_method("server_take_damage"):
			var target_team: int = int(target.get("team"))
			if target_team != team:
				target.call("server_take_damage", weapon.damage, peer_id)
				confirm_hit.rpc_id(peer_id)

func _apply_spread(direction: Vector3, degrees: float) -> Vector3:
	var spread_radians := deg_to_rad(degrees)
	return direction.rotated(Vector3.UP, randf_range(-spread_radians, spread_radians)).rotated(global_transform.basis.x, randf_range(-spread_radians, spread_radians)).normalized()

@rpc("any_peer", "call_remote", "reliable")
func request_throw_grenade(
	origin: Vector3,
	direction: Vector3
) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	if not alive or downed:
		return
	if grenades_remaining <= 0:
		return

	var now: int = Time.get_ticks_msec()
	if now < next_grenade_time:
		return
	if origin.distance_to($Head.global_position) > 2.0:
		return

	next_grenade_time = now + 900
	var main: Node = get_parent()
	if main != null and main.has_method("server_throw_grenade"):
		var thrown: bool = bool(
			main.call(
				"server_throw_grenade",
				self,
				origin + direction.normalized() * 0.55,
				direction
			)
		)
		if thrown:
			grenades_remaining -= 1

@rpc("any_peer", "call_remote", "reliable")
func request_reload() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	if not alive or downed:
		return
	_server_start_reload()

func _server_start_reload() -> void:
	if not multiplayer.is_server():
		return
	if is_reloading:
		return
	if ammo_in_mag >= weapon.magazine_size:
		return
	if reserve_ammo <= 0:
		return

	is_reloading = true
	reload_finish_ms = (
		Time.get_ticks_msec()
		+ int(weapon.reload_seconds * 1000.0)
	)

func _finish_reload() -> void:
	var needed := weapon.magazine_size - ammo_in_mag
	var transferred := mini(needed, reserve_ammo)
	ammo_in_mag += transferred
	reserve_ammo -= transferred
	is_reloading = false
	_store_current_weapon_ammo()

func _initialize_loadout() -> void:
	weapon_slots = [SERVICE_RIFLE, SERVICE_PISTOL]
	weapon_magazines.clear()
	weapon_reserves.clear()

	for slot_weapon in weapon_slots:
		weapon_magazines.append(slot_weapon.magazine_size)
		weapon_reserves.append(slot_weapon.reserve_ammo)

	current_weapon_index = 0
	_apply_weapon_index(0, false)

func _reset_loadout_ammo() -> void:
	if weapon_slots.is_empty():
		_initialize_loadout()
		return

	for index in weapon_slots.size():
		weapon_magazines[index] = weapon_slots[index].magazine_size
		weapon_reserves[index] = weapon_slots[index].reserve_ammo

	_apply_weapon_index(0, true)

func _store_current_weapon_ammo() -> void:
	if current_weapon_index < 0 or current_weapon_index >= weapon_slots.size():
		return
	weapon_magazines[current_weapon_index] = ammo_in_mag
	weapon_reserves[current_weapon_index] = reserve_ammo

func _apply_weapon_index(index: int, rebuild_view: bool = true) -> void:
	if weapon_slots.is_empty():
		return

	var safe_index: int = posmod(index, weapon_slots.size())
	if current_weapon_index >= 0 and current_weapon_index < weapon_slots.size():
		_store_current_weapon_ammo()

	current_weapon_index = safe_index
	weapon = weapon_slots[current_weapon_index]
	ammo_in_mag = weapon_magazines[current_weapon_index]
	reserve_ammo = weapon_reserves[current_weapon_index]
	is_reloading = false

	if rebuild_view and _is_local_player() and DisplayServer.get_name() != "headless":
		_rebuild_first_person_weapon()

@rpc("any_peer", "call_remote", "reliable")
func request_weapon_switch() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	if not alive or downed:
		return
	_apply_weapon_index(current_weapon_index + 1, false)

@rpc("authority", "call_remote", "reliable")
func confirm_hit() -> void:
	if not _is_local_player():
		return
	hit_marker_until_ms = Time.get_ticks_msec() + 140
	if hit_marker != null:
		hit_marker.visible = true

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not alive or downed: return
	health = maxi(0, health - amount)
	if health == 0:
		downed = true; health = 1; bleedout_finish_ms = Time.get_ticks_msec() + BLEEDOUT_MS; is_reloading = false; velocity = Vector3.ZERO
		get_parent().push_kill_feed.rpc("%s downed %s" % [get_parent().player_names.get(attacker_id, "World"), player_name])
		set_meta("last_attacker_id", attacker_id)

func _finish_death(attacker_override: int) -> void:
	if not multiplayer.is_server() or not alive: return
	var attacker_id := attacker_override if attacker_override != 0 else int(get_meta("last_attacker_id", 0))
	alive = false; downed = false; health = 0; deaths += 1; visible = false; velocity = Vector3.ZERO
	get_parent().register_elimination(peer_id, attacker_id)

func server_revive(reviver_id: int = 0) -> void:
	if not multiplayer.is_server() or not alive or not downed:
		return
	downed = false
	health = maxi(45, int(_class_health(player_class) * 0.4))
	bleedout_finish_ms = 0
	if get_parent().players.has(reviver_id):
		get_parent().players[reviver_id].add_xp(15, "revive")
	get_parent().push_kill_feed.rpc("%s was revived" % player_name)

func server_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	global_position = spawn_position
	target_position = spawn_position
	health = _class_health(player_class)
	_reset_loadout_ammo()
	grenades_remaining = 2
	alive = true
	downed = false
	is_reloading = false
	visible = true
	velocity = Vector3.ZERO
	input_vector = Vector2.ZERO

@rpc("any_peer", "call_remote", "reliable")
func request_interact() -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive: return
	var now := Time.get_ticks_msec()
	if now < next_interact_time: return
	next_interact_time = now + 500
	if player_class == PlayerClass.MEDIC:
		for candidate in get_parent().players.values():
			if candidate != self and candidate.team == team and candidate.alive and candidate.downed and global_position.distance_to(candidate.global_position) <= REVIVE_RANGE:
				candidate.server_revive(peer_id); return
	if player_class == PlayerClass.ENGINEER and not downed:
		get_parent().server_engineer_interact(self)

@rpc("any_peer", "call_remote", "reliable")
func request_class_ability() -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id or not alive or downed: return
	var now := Time.get_ticks_msec()
	if now < next_ability_time: return
	next_ability_time = now + ABILITY_COOLDOWN_MS
	match player_class:
		PlayerClass.SOLDIER: reserve_ammo = mini(reserve_ammo + 45, weapon.reserve_ammo + 90)
		PlayerClass.MEDIC: get_parent().create_supply_pack(self, 0, 45)
		PlayerClass.ENGINEER: health = mini(_class_health(player_class), health + 25)
		PlayerClass.FIELD_OPS: get_parent().create_supply_pack(self, 1, 70)
		PlayerClass.SCOUT: health = mini(_class_health(player_class), health + 15)

@rpc("any_peer", "call_remote", "reliable")
func request_class(index: int) -> void:
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != peer_id: return
	player_class = clampi(index, 0, 4); health = mini(health, _class_health(player_class))


func _server_bot_tick(delta: float) -> void:
	if not alive or downed or get_parent().match_over:
		velocity = Vector3.ZERO
		return

	var now := Time.get_ticks_msec()
	if is_reloading and now >= reload_finish_ms:
		_finish_reload()

	bot_fire_accumulator = maxf(0.0, bot_fire_accumulator - delta)
	var target: Node3D = null

	if player_class == PlayerClass.MEDIC:
		target = get_parent().nearest_downed_teammate(self)
		if target and global_position.distance_to(target.global_position) <= 2.6:
			target.server_revive(peer_id)
			return

	if player_class == PlayerClass.ENGINEER:
		if get_parent().objective_stage == 0 and team == 0:
			target = get_parent().get_node_or_null("BridgeBuildSite")
			if target and global_position.distance_to(target.global_position) <= 3.2:
				get_parent().server_engineer_interact(self)
				return
		elif get_parent().objective_stage == 1:
			target = get_parent().get_node_or_null("Objective")
			if target and global_position.distance_to(target.global_position) <= 3.2:
				get_parent().server_engineer_interact(self)
				return

	if target == null:
		target = get_parent().nearest_enemy(self)

	if target == null:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var flat_direction := target.global_position - global_position
	flat_direction.y = 0.0
	var distance := flat_direction.length()

	if distance > 0.05:
		flat_direction = flat_direction.normalized()
		look_at(global_position + flat_direction, Vector3.UP)

	var target_is_player: bool = get_parent().players.values().has(target)
	if target_is_player and distance <= weapon.range_meters:
		velocity.x = 0.0
		velocity.z = 0.0

		if bot_fire_accumulator <= 0.0 and _bot_has_line_of_sight(target):
			bot_fire_accumulator = maxf(
				0.12,
				float(weapon.fire_interval_ms()) / 1000.0
			)
			_server_bot_fire(target)
	else:
		var bot_speed := 4.8
		velocity.x = flat_direction.x * bot_speed
		velocity.z = flat_direction.z * bot_speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _bot_has_line_of_sight(target: Node3D) -> bool:
	var from := global_position + Vector3.UP * 0.8
	var to := target.global_position + Vector3.UP * 0.8
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == target

func _server_bot_fire(target: Node3D) -> void:
	if is_reloading:
		return

	if ammo_in_mag <= 0:
		_server_start_reload()
		return

	ammo_in_mag -= 1
	_store_current_weapon_ammo()

	if target.has_method("server_take_damage"):
		target.server_take_damage(weapon.damage, peer_id)

func server_force_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	global_position = spawn_position
	velocity = Vector3.ZERO
	alive = true
	downed = false
	health = _class_health(player_class)
	_reset_loadout_ammo()
	grenades_remaining = 2
	bleedout_finish_ms = 0
	show()

func server_apply_class(class_id: int) -> void:
	if not multiplayer.is_server():
		return
	player_class = clampi(class_id, 0, 4)
	health = _class_health(player_class)

func add_xp(amount: int, reason: String = "") -> void:
	if not multiplayer.is_server():
		return
	xp = maxi(0, xp + amount)
	if reason != "":
		print("%s gained %d XP: %s" % [player_name, amount, reason])

func rank_name() -> String:
	if xp >= 300:
		return "Captain"
	if xp >= 180:
		return "Lieutenant"
	if xp >= 100:
		return "Sergeant"
	if xp >= 40:
		return "Corporal"
	return "Recruit"

func _class_health(class_id: int) -> int:
	match class_id:
		PlayerClass.SOLDIER: return 120
		PlayerClass.MEDIC: return 110
		PlayerClass.SCOUT: return 90
		_: return 100

func _is_local_player() -> bool: return peer_id != 0 and peer_id == multiplayer.get_unique_id()

func _living_teammates() -> Array:
	var result: Array = []
	for candidate in get_parent().players.values():
		if candidate == self:
			continue
		if candidate.team == team and candidate.alive and not candidate.downed:
			result.append(candidate)
	return result

func _cycle_spectator_target() -> void:
	var candidates := _living_teammates()
	if candidates.is_empty():
		spectator_target_id = 0
		spectator_index = -1
		return

	spectator_index = (spectator_index + 1) % candidates.size()
	spectator_target_id = int(candidates[spectator_index].peer_id)

func _update_spectator_camera() -> void:
	if not _is_local_player():
		return

	var camera := $Head/Camera3D as Camera3D

	if alive:
		spectator_target_id = 0
		spectator_index = -1
		camera.position = Vector3.ZERO
		camera.rotation = Vector3.ZERO
		return

	var candidates := _living_teammates()
	if candidates.is_empty():
		return

	var target: Node3D = get_parent().players.get(spectator_target_id) as Node3D
	if target == null or not bool(target.get("alive")) or bool(target.get("downed")) or int(target.get("team")) != team:
		spectator_index = 0
		target = candidates[0] as Node3D
		spectator_target_id = int(target.get("peer_id"))

	var target_head: Node3D = target.get_node_or_null("Head") as Node3D
	if target_head != null:
		camera.global_transform = target_head.global_transform

func _build_first_person_weapon() -> void:
	weapon_view = Node3D.new()
	weapon_view.name = "FirstPersonWeapon"
	$Head/Camera3D.add_child(weapon_view)
	_rebuild_first_person_weapon()

func _rebuild_first_person_weapon() -> void:
	if weapon_view == null:
		return

	for child in weapon_view.get_children():
		child.queue_free()

	var is_pistol: bool = current_weapon_index == 1
	weapon_view.position = Vector3(0.30, -0.27, -0.62) if is_pistol else Vector3(0.34, -0.28, -0.72)

	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.18, 0.19, 0.20)

	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.28, 0.16, 0.08)

	var receiver := MeshInstance3D.new()
	var receiver_mesh := BoxMesh.new()
	receiver_mesh.size = Vector3(0.13, 0.14, 0.34) if is_pistol else Vector3(0.16, 0.16, 0.72)
	receiver.mesh = receiver_mesh
	receiver.material_override = metal
	weapon_view.add_child(receiver)

	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.022 if is_pistol else 0.025
	barrel_mesh.bottom_radius = barrel_mesh.top_radius
	barrel_mesh.height = 0.28 if is_pistol else 0.55
	barrel.mesh = barrel_mesh
	barrel.rotation_degrees.x = 90.0
	barrel.position.z = -0.27 if is_pistol else -0.55
	barrel.material_override = metal
	weapon_view.add_child(barrel)

	var grip := MeshInstance3D.new()
	var grip_mesh := BoxMesh.new()
	grip_mesh.size = Vector3(0.12, 0.25, 0.12) if is_pistol else Vector3(0.18, 0.22, 0.34)
	grip.mesh = grip_mesh
	grip.position = Vector3(0.0, 0.15, 0.10) if is_pistol else Vector3(0.0, 0.0, 0.42)
	grip.rotation_degrees.x = -15.0 if is_pistol else 0.0
	grip.material_override = wood
	weapon_view.add_child(grip)


func _build_hud() -> void:
	var layer := CanvasLayer.new(); add_child(layer)
	hud = Label.new(); hud.position = Vector2(18, 18); hud.add_theme_font_size_override("font_size", 18); layer.add_child(hud)
	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.position = Vector2(638, 350)
	crosshair.add_theme_font_size_override("font_size", 24)
	layer.add_child(crosshair)

	hit_marker = Label.new()
	hit_marker.text = "×"
	hit_marker.position = Vector2(634, 344)
	hit_marker.add_theme_font_size_override("font_size", 30)
	hit_marker.visible = false
	layer.add_child(hit_marker)

	scoreboard = Label.new(); scoreboard.position = Vector2(390, 150); scoreboard.add_theme_font_size_override("font_size", 18); scoreboard.visible = false; layer.add_child(scoreboard)
	feed = Label.new(); feed.position = Vector2(930, 24); feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; feed.custom_minimum_size = Vector2(320, 150); layer.add_child(feed)

func _update_hud() -> void:
	if hud == null:
		return

	if hit_marker != null and hit_marker.visible and Time.get_ticks_msec() >= hit_marker_until_ms:
		hit_marker.visible = false
	var names := ["Soldier", "Medic", "Engineer", "Field Ops", "Scout"]
	var main = get_parent(); var minutes := int(main.match_time_remaining) / 60; var seconds := int(main.match_time_remaining) % 60
	var life_text := "DOWNED" if downed else (
		"ALIVE" if alive else "RESPAWN IN %.1f · F cycles teammate" % main.spawn_wave_remaining
	)
	var objective_text: String = main.objective_status_text()
	var cooldown := maxf(0.0, float(next_ability_time - Time.get_ticks_msec()) / 1000.0)
	hud.text = "%s | %s | %s\nHP %d  Ammo %d/%d  %s [%d/%d]  Grenades %d\n%s  Time %02d:%02d\nClass: %s  XP %d (%s)  Q: %.1fs  G: grenade  X: switch  E: interact" % [
		player_name,
		"Attackers" if team == 0 else "Defenders",
		life_text,
		health,
		ammo_in_mag,
		reserve_ammo,
		"RELOADING" if is_reloading else weapon.display_name,
		current_weapon_index + 1,
		weapon_slots.size(),
		grenades_remaining,
		objective_text,
		minutes,
		seconds,
		names[player_class],
		xp,
		rank_name(),
		cooldown
	]
	scoreboard.visible = Input.is_action_pressed("scoreboard")
	if scoreboard.visible: scoreboard.text = main.scoreboard_text()
	feed.text = "\n".join(main.kill_feed)
