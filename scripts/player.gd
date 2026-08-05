extends CharacterBody3D

enum PlayerClass { SOLDIER, MEDIC, ENGINEER, FIELD_OPS, SCOUT }

@export var peer_id := 0
@export var team := 0
@export var player_name := "Player"
@export var player_class: PlayerClass = PlayerClass.SOLDIER
const SERVICE_RIFLE: Resource = preload("res://data/weapons/service_rifle.tres")
const SERVICE_PISTOL: Resource = preload("res://data/weapons/service_pistol.tres")
const SOLDIER_LMG: Resource = preload("res://data/weapons/soldier_lmg.tres")
const MEDIC_SMG: Resource = preload("res://data/weapons/medic_smg.tres")
const ENGINEER_CARBINE: Resource = preload("res://data/weapons/engineer_carbine.tres")
const FIELD_OPS_RIFLE: Resource = preload("res://data/weapons/field_ops_rifle.tres")
const SCOUT_MARKSMAN: Resource = preload("res://data/weapons/scout_marksman.tres")

@export var weapon: Resource = SERVICE_RIFLE

const WALK_SPEED := 7.0
const SPRINT_SPEED := 10.0
const CROUCH_SPEED := 4.0
const JUMP_SPEED := 5.2
const SNAPSHOT_LERP_SPEED := 14.0
const ABILITY_COOLDOWN_MS := 12000
const SCOUT_SPOT_DURATION_MS := 8000
const REVIVE_RANGE := 2.8
const BLEEDOUT_MS := 15000
const STANDING_HEAD_Y := 0.65
const CROUCH_HEAD_Y := 0.12
const STANDING_CAPSULE_HEIGHT := 1.8
const CROUCH_CAPSULE_HEIGHT := 1.15
const CROUCH_BODY_SCALE_Y := 0.64
const SPAWN_PROTECTION_MS := 5000

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
var weapon_slots: Array[Resource] = []
var weapon_magazines: Array[int] = []
var weapon_reserves: Array[int] = []
var current_weapon_index := 0
var hit_marker: Label
var hit_marker_until_ms := 0
var muzzle_flash: MeshInstance3D
var muzzle_flash_until_ms := 0
var damage_indicator: Label
var damage_indicator_until_ms := 0
var spawn_menu: Control
var selected_team := 0
var selected_class := 0
var spawn_menu_open := false
var has_deployed := false
var menu_toggle_latched := false
var spawn_protection_until_ms := 0
var replicated_spawn_protection_ms := 0
var replicated_ability_cooldown_ms := 0
var spotted_until_ms := 0
var replicated_spotted_ms := 0
var spotted_label: Label3D
var selection_status: Label
var local_next_fire_feedback_ms := 0
var grenades_remaining := 2
var next_grenade_time := 0
var is_crouching := false
var weapon_kick_offset := 0.0

var server_logged_first_input := false

func _ready() -> void:
	_initialize_loadout()
	_build_spotted_marker()
	target_position = global_position
	if _is_local_player() and DisplayServer.get_name() != "headless":
		$Head/Camera3D.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_first_person_weapon()
		_build_hud()
		_build_spawn_menu()
		_show_spawn_menu()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_local_player():
		return

	if event is InputEventMouseMotion and alive and not downed:
		rotation.y -= event.relative.x * 0.0025
		pitch = clampf(pitch - event.relative.y * 0.0025, -1.35, 1.35)
		$Head.rotation.x = pitch

	if event.is_action_pressed("spectator_next") and not alive:
		_cycle_spectator_target()

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and is_bot:
		_server_bot_tick(delta)
		return

	if _is_local_player():
		_poll_spawn_menu_toggle()
		_collect_and_send_input()
		_update_spectator_camera()
		_update_hud()
	elif not multiplayer.is_server():
		global_position = global_position.lerp(target_position, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
		$Head.rotation.x = lerp_angle($Head.rotation.x, target_pitch, clampf(delta * SNAPSHOT_LERP_SPEED, 0.0, 1.0))
	if multiplayer.is_server(): _server_simulate(delta)

func _poll_spawn_menu_toggle() -> void:
	var pressed: bool = Input.is_action_pressed("spawn_menu")

	if pressed and not menu_toggle_latched:
		menu_toggle_latched = true
		if spawn_menu_open:
			if has_deployed:
				_hide_spawn_menu()
		else:
			_show_spawn_menu()
	elif not pressed:
		menu_toggle_latched = false

func _collect_and_send_input() -> void:
	if spawn_menu_open:
		return
	if not alive:
		return

	local_sequence += 1
	var move := Vector2.ZERO if downed else Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var local_crouch: bool = Input.is_action_pressed("crouch") and not downed
	_apply_crouch_visual(local_crouch)

	if not downed and Input.is_action_just_pressed("weapon_switch"):
		_local_request_weapon_switch()

	var main_node: Node = get_parent()
	var local_peer_id: int = multiplayer.get_unique_id()
	if main_node != null:
		main_node.submit_player_input.rpc_id(
			1,
			local_peer_id,
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
		if camera != null:
			var now: int = Time.get_ticks_msec()
			if now >= local_next_fire_feedback_ms and ammo_in_mag > 0 and not is_reloading:
				local_next_fire_feedback_ms = now + _weapon_fire_interval_ms()
				_local_fire_feedback()
			if main_node != null:
				main_node.request_player_fire.rpc_id(
					1,
					local_peer_id,
					camera.global_position,
					-camera.global_transform.basis.z
				)

	if not downed and Input.is_action_just_pressed("reload"):
		if main_node != null:
			main_node.request_player_reload.rpc_id(1, local_peer_id)

	if not downed and Input.is_action_just_pressed("throw_grenade"):
		var grenade_camera: Camera3D = $Head/Camera3D as Camera3D
		if grenade_camera != null:
			if main_node != null:
				main_node.request_player_grenade.rpc_id(
					1,
					local_peer_id,
					grenade_camera.global_position,
					-grenade_camera.global_transform.basis.z
				)

	if Input.is_action_pressed("interact"):
		interact_accumulator += get_physics_process_delta_time()
		if interact_accumulator >= 0.25:
			interact_accumulator = 0.0
			if main_node != null:
				main_node.request_player_interact.rpc_id(1, local_peer_id)
	else:
		interact_accumulator = 0.0

	if not downed and Input.is_action_just_pressed("ability"):
		if main_node != null:
			main_node.request_player_ability.rpc_id(1, local_peer_id)

	for index in 5:
		if Input.is_action_just_pressed("class_%d" % (index + 1)):
			if main_node != null:
				main_node.request_player_class.rpc_id(1, local_peer_id, index)

func server_receive_input(move: Vector2, yaw: float, look_pitch: float, wants_jump: bool, wants_sprint: bool, wants_crouch: bool, sequence: int) -> void:
	if not multiplayer.is_server() or sequence <= last_received_sequence:
		return

	if not server_logged_first_input:
		server_logged_first_input = true
		print(
			"Accepted gameplay input from peer %d (%s)" % [
				peer_id,
				player_name
			]
		)

	last_received_sequence = sequence
	input_vector = move.limit_length(1.0)
	rotation.y = yaw
	pitch = clampf(look_pitch, -1.35, 1.35)
	$Head.rotation.x = pitch
	jump_requested = jump_requested or wants_jump
	sprint_requested = wants_sprint
	crouch_requested = wants_crouch

func _server_simulate(delta: float) -> void:
	var now: int = Time.get_ticks_msec()

	if is_reloading and now >= reload_finish_ms:
		_finish_reload()

	if downed and now >= bleedout_finish_ms:
		_finish_death(0)

	if not alive or downed:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jump_requested and not crouch_requested:
		velocity.y = JUMP_SPEED

	jump_requested = false
	_apply_server_crouch(crouch_requested)

	var move_speed: float = (
		CROUCH_SPEED
		if crouch_requested
		else (
			SPRINT_SPEED
			if sprint_requested and input_vector.y < -0.2
			else WALK_SPEED
		)
	)

	var direction: Vector3 = (
		transform.basis
		* Vector3(input_vector.x, 0.0, input_vector.y)
	).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()


func apply_player_snapshot(pos: Vector3, yaw: float, head_pitch: float, hp: int, magazine: int, reserve: int, is_alive: bool, is_downed: bool, reloading: bool, class_id: int, player_team: int, kill_count: int, death_count: int, experience: int, weapon_index: int, grenade_count: int, crouching: bool, spawn_protection_ms: int, ability_cooldown_ms: int, spotted_ms: int) -> void:
	if multiplayer.is_server():
		return
	target_position = pos; target_yaw = yaw; target_pitch = head_pitch
	if _is_local_player(): global_position = pos
	health = hp
	alive = is_alive
	downed = is_downed
	is_reloading = reloading
	var previous_class: int = player_class
	player_class = class_id
	team = player_team

	if player_class != previous_class:
		current_weapon_index = 0
		_configure_class_loadout(
			true,
			_is_local_player()
		)

	kills = kill_count
	deaths = death_count
	xp = experience
	grenades_remaining = grenade_count
	replicated_spawn_protection_ms = maxi(0, spawn_protection_ms)
	replicated_ability_cooldown_ms = maxi(0, ability_cooldown_ms)
	replicated_spotted_ms = maxi(0, spotted_ms)
	_update_spotted_marker()
	_apply_crouch_visual(crouching)

	if weapon_index != current_weapon_index:
		_apply_weapon_index(weapon_index, true)

	ammo_in_mag = magazine
	reserve_ammo = reserve
	if current_weapon_index < weapon_magazines.size():
		weapon_magazines[current_weapon_index] = ammo_in_mag
		weapon_reserves[current_weapon_index] = reserve_ammo

	visible = alive
	if weapon_view:
		weapon_view.visible = alive and not downed

	if _is_local_player():
		if not has_deployed and not spawn_menu_open:
			_show_spawn_menu()
		elif not alive and not spawn_menu_open:
			_show_spawn_menu()

func server_fire(direction: Vector3) -> void:
	if not multiplayer.is_server() or not alive or downed or is_reloading:
		return

	_cancel_spawn_protection()
	var now: int = Time.get_ticks_msec()
	if now < next_fire_time or ammo_in_mag <= 0:
		return

	var origin: Vector3 = $Head.global_position
	next_fire_time = now + _weapon_fire_interval_ms()
	ammo_in_mag -= 1
	_store_current_weapon_ammo()
	var spread: float = (
		_weapon_moving_spread()
		if input_vector.length() > 0.15
		else _weapon_hip_spread()
	)
	var shot_direction: Vector3 = _apply_spread(
		direction.normalized(),
		spread
	)
	var query: PhysicsRayQueryParameters3D = (
		PhysicsRayQueryParameters3D.create(
			origin,
			origin + shot_direction * _weapon_range_meters()
		)
	)
	query.exclude = [self]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.get("collider") is CharacterBody3D:
		var target: CharacterBody3D = hit.get("collider") as CharacterBody3D
		if target != null and target.has_method("server_take_damage"):
			var target_team: int = int(target.get("team"))
			if target_team != team:
				target.call("server_take_damage", _weapon_damage(), peer_id)
				confirm_hit.rpc_id(peer_id)

func _apply_spread(direction: Vector3, degrees: float) -> Vector3:
	var spread_radians: float = deg_to_rad(degrees)
	return direction.rotated(Vector3.UP, randf_range(-spread_radians, spread_radians)).rotated(global_transform.basis.x, randf_range(-spread_radians, spread_radians)).normalized()

func server_throw_grenade_request(
	direction: Vector3
) -> void:
	if not multiplayer.is_server():
		return

	_cancel_spawn_protection()
	if not alive or downed:
		return
	if grenades_remaining <= 0:
		return

	var now: int = Time.get_ticks_msec()
	if now < next_grenade_time:
		return

	var origin: Vector3 = $Head.global_position
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

func server_reload_request() -> void:
	if not multiplayer.is_server():
		return
	if not alive or downed:
		return
	_server_start_reload()

func _server_start_reload() -> void:
	if not multiplayer.is_server():
		return
	if is_reloading:
		return
	if ammo_in_mag >= _weapon_magazine_size():
		return
	if reserve_ammo <= 0:
		return

	is_reloading = true
	reload_finish_ms = (
		Time.get_ticks_msec()
		+ int(_weapon_reload_seconds() * 1000.0)
	)

func _finish_reload() -> void:
	var needed := _weapon_magazine_size() - ammo_in_mag
	var transferred := mini(needed, reserve_ammo)
	ammo_in_mag += transferred
	reserve_ammo -= transferred
	is_reloading = false
	_store_current_weapon_ammo()

func _resource_int(
	resource: Resource,
	property_name: StringName,
	default_value: int
) -> int:
	if resource == null:
		return default_value
	var value: Variant = resource.get(property_name)
	return int(value) if value != null else default_value

func _resource_float(
	resource: Resource,
	property_name: StringName,
	default_value: float
) -> float:
	if resource == null:
		return default_value
	var value: Variant = resource.get(property_name)
	return float(value) if value != null else default_value

func _resource_string(
	resource: Resource,
	property_name: StringName,
	default_value: String
) -> String:
	if resource == null:
		return default_value
	var value: Variant = resource.get(property_name)
	return str(value) if value != null else default_value

func _weapon_magazine_size() -> int:
	return _resource_int(weapon, "magazine_size", 30)

func _weapon_reserve_ammo() -> int:
	return _resource_int(weapon, "reserve_ammo", 120)

func _weapon_damage() -> int:
	return _resource_int(weapon, "damage", 20)

func _weapon_reload_seconds() -> float:
	return _resource_float(weapon, "reload_seconds", 2.0)

func _weapon_range_meters() -> float:
	return _resource_float(weapon, "range_meters", 100.0)

func _weapon_moving_spread() -> float:
	return _resource_float(weapon, "moving_spread_degrees", 1.5)

func _weapon_hip_spread() -> float:
	return _resource_float(weapon, "hip_spread_degrees", 0.75)

func _weapon_recoil_degrees() -> float:
	return _resource_float(weapon, "recoil_degrees", 0.5)

func _weapon_display_name() -> String:
	return _resource_string(weapon, "display_name", "Weapon")

func _weapon_fire_interval_ms() -> int:
	var rounds_per_minute: float = _resource_float(
		weapon,
		"rounds_per_minute",
		500.0
	)
	if rounds_per_minute <= 0.0:
		return 120
	return maxi(1, int(round(60000.0 / rounds_per_minute)))

func _class_primary_weapon(class_id: int) -> Resource:
	match clampi(class_id, 0, 4):
		PlayerClass.SOLDIER:
			return SOLDIER_LMG
		PlayerClass.MEDIC:
			return MEDIC_SMG
		PlayerClass.ENGINEER:
			return ENGINEER_CARBINE
		PlayerClass.FIELD_OPS:
			return FIELD_OPS_RIFLE
		PlayerClass.SCOUT:
			return SCOUT_MARKSMAN
		_:
			return SERVICE_RIFLE

func _configure_class_loadout(
	reset_ammunition: bool,
	rebuild_view: bool = true
) -> void:
	var primary: Resource = _class_primary_weapon(player_class)
	weapon_slots = [primary, SERVICE_PISTOL]

	if reset_ammunition or weapon_magazines.size() != weapon_slots.size():
		weapon_magazines.clear()
		weapon_reserves.clear()

		for slot_value in weapon_slots:
			var slot_weapon: Resource = slot_value as Resource
			weapon_magazines.append(
				_resource_int(slot_weapon, "magazine_size", 30)
			)
			weapon_reserves.append(
				_resource_int(slot_weapon, "reserve_ammo", 120)
			)
	else:
		for index in weapon_slots.size():
			var maximum_magazine: int = _resource_int(
				weapon_slots[index],
				"magazine_size",
				30
			)
			var maximum_reserve: int = _resource_int(
				weapon_slots[index],
				"reserve_ammo",
				120
			)
			weapon_magazines[index] = mini(
				weapon_magazines[index],
				maximum_magazine
			)
			weapon_reserves[index] = mini(
				weapon_reserves[index],
				maximum_reserve
			)

	current_weapon_index = clampi(
		current_weapon_index,
		0,
		weapon_slots.size() - 1
	)
	_apply_weapon_index(current_weapon_index, rebuild_view)

func _initialize_loadout() -> void:
	current_weapon_index = 0
	_configure_class_loadout(true, false)

func _reset_loadout_ammo() -> void:
	current_weapon_index = 0
	_configure_class_loadout(true, true)

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

func _local_request_weapon_switch() -> void:
	if weapon_slots.is_empty():
		return

	var desired_index: int = posmod(
		current_weapon_index + 1,
		weapon_slots.size()
	)

	# Change the local model immediately; the server remains authoritative
	# and will confirm or correct the slot in the next snapshot.
	_apply_weapon_index(desired_index, true)
	var main_node: Node = get_parent()
	var local_peer_id: int = multiplayer.get_unique_id()
	if main_node != null:
		main_node.request_player_weapon.rpc_id(
			1,
			local_peer_id,
			desired_index
		)

func server_weapon_switch_request(desired_index: int) -> void:
	if not multiplayer.is_server():
		return
	if not alive or downed:
		return
	if desired_index < 0 or desired_index >= weapon_slots.size():
		return

	_apply_weapon_index(desired_index, false)
	confirm_weapon_switch.rpc_id(peer_id, desired_index)

@rpc("authority", "call_remote", "reliable")
func confirm_weapon_switch(weapon_index: int) -> void:
	if not _is_local_player():
		return
	if weapon_index != current_weapon_index:
		_apply_weapon_index(weapon_index, true)

@rpc("authority", "call_remote", "reliable")
func confirm_hit() -> void:
	if not _is_local_player():
		return
	hit_marker_until_ms = Time.get_ticks_msec() + 140
	if hit_marker != null:
		hit_marker.visible = true

func server_confirm_hit() -> void:
	if not multiplayer.is_server():
		return
	confirm_hit.rpc_id(peer_id)

func spawn_protection_remaining_ms() -> int:
	if not multiplayer.is_server():
		return replicated_spawn_protection_ms
	return maxi(
		0,
		spawn_protection_until_ms - Time.get_ticks_msec()
	)

func _activate_spawn_protection() -> void:
	if not multiplayer.is_server():
		return
	spawn_protection_until_ms = (
		Time.get_ticks_msec() + SPAWN_PROTECTION_MS
	)

func _cancel_spawn_protection() -> void:
	if not multiplayer.is_server():
		return
	spawn_protection_until_ms = 0

func _has_spawn_protection() -> bool:
	return spawn_protection_remaining_ms() > 0

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not alive or downed:
		return
	if _has_spawn_protection():
		return

	health = maxi(0, health - amount)

	var attacker_position: Vector3 = global_position
	if get_parent().players.has(attacker_id):
		var attacker: Node3D = get_parent().players[attacker_id] as Node3D
		if attacker != null:
			attacker_position = attacker.global_position
	damage_feedback.rpc_id(peer_id, attacker_position, amount)

	if health == 0:
		downed = true
		health = 1
		bleedout_finish_ms = Time.get_ticks_msec() + BLEEDOUT_MS
		is_reloading = false
		velocity = Vector3.ZERO
		get_parent().push_kill_feed.rpc(
			"%s downed %s" % [
				get_parent().player_names.get(attacker_id, "World"),
				player_name
			]
		)
		set_meta("last_attacker_id", attacker_id)

func _finish_death(attacker_override: int) -> void:
	if not multiplayer.is_server() or not alive: return
	var attacker_id := attacker_override if attacker_override != 0 else int(get_meta("last_attacker_id", 0))
	alive = false; downed = false; health = 0; deaths += 1; visible = false; velocity = Vector3.ZERO
	get_parent().register_elimination(peer_id, attacker_id)

@rpc("authority", "call_remote", "reliable")
func damage_feedback(attacker_position: Vector3, amount: int) -> void:
	if not _is_local_player():
		return

	damage_indicator_until_ms = Time.get_ticks_msec() + 420
	if damage_indicator == null:
		return

	var to_attacker: Vector3 = attacker_position - global_position
	to_attacker.y = 0.0
	var direction_text := "FRONT"

	if to_attacker.length() > 0.01:
		to_attacker = to_attacker.normalized()

		var forward: Vector3 = -global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()

		var right: Vector3 = global_transform.basis.x
		right.y = 0.0
		right = right.normalized()

		var forward_dot: float = forward.dot(to_attacker)
		var right_dot: float = right.dot(to_attacker)

		if absf(right_dot) > absf(forward_dot):
			direction_text = "RIGHT" if right_dot > 0.0 else "LEFT"
		else:
			direction_text = "FRONT" if forward_dot > 0.0 else "REAR"

	damage_indicator.text = "DAMAGE %s  -%d" % [direction_text, amount]
	damage_indicator.visible = true

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
	_apply_server_crouch(false)
	_activate_spawn_protection()
	alive = true
	downed = false
	is_reloading = false
	visible = true
	velocity = Vector3.ZERO
	input_vector = Vector2.ZERO

func server_interact_request() -> void:
	if not multiplayer.is_server() or not alive:
		return
	var now := Time.get_ticks_msec()
	if now < next_interact_time: return
	next_interact_time = now + 500
	if player_class == PlayerClass.MEDIC:
		for candidate in get_parent().players.values():
			if candidate != self and candidate.team == team and candidate.alive and candidate.downed and global_position.distance_to(candidate.global_position) <= REVIVE_RANGE:
				candidate.server_revive(peer_id); return
	if player_class == PlayerClass.ENGINEER and not downed:
		get_parent().server_engineer_interact(self)

func ability_cooldown_remaining_ms() -> int:
	if not multiplayer.is_server():
		return replicated_ability_cooldown_ms
	return maxi(0, next_ability_time - Time.get_ticks_msec())

func spotted_remaining_ms() -> int:
	if not multiplayer.is_server():
		return replicated_spotted_ms
	return maxi(0, spotted_until_ms - Time.get_ticks_msec())

func server_apply_spotted(duration_ms: int) -> void:
	if not multiplayer.is_server():
		return
	spotted_until_ms = maxi(
		spotted_until_ms,
		Time.get_ticks_msec() + maxi(0, duration_ms)
	)

func _build_spotted_marker() -> void:
	if DisplayServer.get_name() == "headless":
		return

	spotted_label = Label3D.new()
	spotted_label.name = "SpottedMarker"
	spotted_label.text = "SPOTTED"
	spotted_label.position = Vector3(0.0, 1.55, 0.0)
	spotted_label.font_size = 28
	spotted_label.outline_size = 8
	spotted_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	spotted_label.no_depth_test = true
	spotted_label.visible = false
	add_child(spotted_label)

func _update_spotted_marker() -> void:
	if spotted_label == null:
		return

	var local_team := -1
	var main: Node = get_parent()
	if main != null:
		var local_id: int = multiplayer.get_unique_id()
		if main.get("players") is Dictionary:
			var player_map: Dictionary = main.get("players")
			if player_map.has(local_id):
				var local_player: Node = player_map[local_id] as Node
				if local_player != null:
					local_team = int(local_player.get("team"))

	spotted_label.visible = (
		replicated_spotted_ms > 0
		and local_team >= 0
		and local_team != team
	)

func _ability_name() -> String:
	match player_class:
		PlayerClass.SOLDIER:
			return "Combat Resupply"
		PlayerClass.MEDIC:
			return "Healing Burst"
		PlayerClass.ENGINEER:
			return "Field Repair"
		PlayerClass.FIELD_OPS:
			return "Ammo Pulse"
		PlayerClass.SCOUT:
			return "Recon Pulse"
		_:
			return "Ability"

func server_ability_request() -> void:
	if not multiplayer.is_server() or not alive or downed:
		return

	var now: int = Time.get_ticks_msec()
	if now < next_ability_time:
		return

	next_ability_time = now + ABILITY_COOLDOWN_MS
	var main: Node = get_parent()

	match player_class:
		PlayerClass.SOLDIER:
			reserve_ammo = mini(
				reserve_ammo + 90,
				_weapon_reserve_ammo() + 120
			)
			grenades_remaining = mini(grenades_remaining + 1, 3)
			add_xp(3, "combat resupply")

		PlayerClass.MEDIC:
			var healed_count := 0
			for player_value in main.players.values():
				var teammate: Node3D = player_value as Node3D
				if teammate == null:
					continue
				if int(teammate.get("team")) != team:
					continue
				if not bool(teammate.get("alive")):
					continue
				if global_position.distance_to(teammate.global_position) > 10.0:
					continue

				var teammate_max: int = teammate.call(
					"_class_health",
					int(teammate.get("player_class"))
				)
				var current_health: int = int(teammate.get("health"))
				var new_health: int = mini(
					teammate_max,
					current_health + 40
				)
				if new_health > current_health:
					teammate.set("health", new_health)
					healed_count += 1

			if healed_count > 0:
				add_xp(healed_count * 4, "healing burst")

		PlayerClass.ENGINEER:
			health = mini(
				_class_health(player_class),
				health + 35
			)
			if main.has_method("server_engineer_interact"):
				for step in range(3):
					main.call("server_engineer_interact", self)
			add_xp(3, "field repair")

		PlayerClass.FIELD_OPS:
			var supplied_count := 0
			for player_value in main.players.values():
				var teammate: Node3D = player_value as Node3D
				if teammate == null:
					continue
				if int(teammate.get("team")) != team:
					continue
				if not bool(teammate.get("alive")):
					continue
				if global_position.distance_to(teammate.global_position) > 12.0:
					continue

				var current_reserve: int = int(
					teammate.get("reserve_ammo")
				)
				var maximum_reserve: int = int(
					teammate.call("_weapon_reserve_ammo")
				)
				var new_reserve: int = mini(
					maximum_reserve + 60,
					current_reserve + 70
				)
				if new_reserve > current_reserve:
					teammate.set("reserve_ammo", new_reserve)
					teammate.call("_store_current_weapon_ammo")
					supplied_count += 1

			if supplied_count > 0:
				add_xp(supplied_count * 3, "ammo pulse")

		PlayerClass.SCOUT:
			if main.has_method("server_scout_recon"):
				main.call(
					"server_scout_recon",
					self,
					36.0,
					SCOUT_SPOT_DURATION_MS
				)

func server_class_request(index: int) -> void:
	if not multiplayer.is_server():
		return
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
	if target_is_player and distance <= _weapon_range_meters():
		velocity.x = 0.0
		velocity.z = 0.0

		if bot_fire_accumulator <= 0.0 and _bot_has_line_of_sight(target):
			bot_fire_accumulator = maxf(
				0.12,
				float(_weapon_fire_interval_ms()) / 1000.0
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
		target.server_take_damage(_weapon_damage(), peer_id)

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
	_apply_server_crouch(false)
	_activate_spawn_protection()
	bleedout_finish_ms = 0
	show()

func server_set_team_and_class(
	new_team: int,
	new_class: int
) -> void:
	if not multiplayer.is_server():
		return

	team = clampi(new_team, 0, 1)
	player_class = clampi(new_class, 0, 4)
	server_apply_class(player_class)

	var main: Node = get_parent()
	if main != null and main.has_method("_get_spawn"):
		server_force_respawn(
			main.call(
				"_get_spawn",
				team,
				peer_id
			)
		)

func server_apply_class(class_id: int) -> void:
	if not multiplayer.is_server():
		return

	player_class = clampi(class_id, 0, 4)
	health = _class_health(player_class)
	next_ability_time = 0
	spotted_until_ms = 0
	current_weapon_index = 0
	_configure_class_loadout(true, false)

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

func _apply_crouch_visual(crouching: bool) -> void:
	is_crouching = crouching

	var body: MeshInstance3D = $Body as MeshInstance3D
	if body != null:
		body.scale.y = CROUCH_BODY_SCALE_Y if crouching else 1.0
		body.position.y = -0.30 if crouching else 0.0

	$Head.position.y = CROUCH_HEAD_Y if crouching else STANDING_HEAD_Y

func _apply_server_crouch(crouching: bool) -> void:
	is_crouching = crouching

	var collision: CollisionShape3D = $CollisionShape3D as CollisionShape3D
	if collision == null:
		return

	var capsule: CapsuleShape3D = collision.shape as CapsuleShape3D
	if capsule == null:
		return

	capsule.height = (
		CROUCH_CAPSULE_HEIGHT
		if crouching
		else STANDING_CAPSULE_HEIGHT
	)

	# Preserve approximately the same capsule bottom while changing height.
	collision.position.y = -0.325 if crouching else 0.0

	_apply_crouch_visual(crouching)

func _base_weapon_position() -> Vector3:
	return (
		Vector3(0.30, -0.27, -0.62)
		if current_weapon_index == 1
		else Vector3(0.34, -0.28, -0.72)
	)

func _apply_weapon_kick() -> void:
	if weapon_view == null:
		return
	var position := _base_weapon_position()
	position.z += weapon_kick_offset
	weapon_view.position = position

func _local_fire_feedback() -> void:
	if not _is_local_player():
		return

	var recoil_amount: float = maxf(
		1.35,
		_weapon_recoil_degrees() * 3.0
	)
	pitch = clampf(
		pitch - deg_to_rad(recoil_amount),
		-1.35,
		1.35
	)
	$Head.rotation.x = pitch

	weapon_kick_offset = 0.10
	_apply_weapon_kick()

	muzzle_flash_until_ms = Time.get_ticks_msec() + 55
	if muzzle_flash != null:
		muzzle_flash.visible = true

func _build_spawn_menu() -> void:
	var layer := CanvasLayer.new()
	layer.name = "SpawnMenuLayer"
	add_child(layer)

	spawn_menu = PanelContainer.new()
	spawn_menu.name = "SpawnMenu"
	spawn_menu.position = Vector2(390, 135)
	spawn_menu.custom_minimum_size = Vector2(500, 450)
	layer.add_child(spawn_menu)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 12)
	spawn_menu.add_child(root_box)

	var title := Label.new()
	title.text = "FRONTLINE: OBJECTIVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	root_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Choose team and class, then deploy"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_box.add_child(subtitle)

	var team_label := Label.new()
	team_label.text = "TEAM"
	team_label.add_theme_font_size_override("font_size", 20)
	root_box.add_child(team_label)

	var team_row := HBoxContainer.new()
	root_box.add_child(team_row)

	var attackers_button := Button.new()
	attackers_button.text = "Attackers"
	attackers_button.custom_minimum_size = Vector2(220, 45)
	attackers_button.pressed.connect(func():
		selected_team = 0
		_update_selection_status()
	)
	team_row.add_child(attackers_button)

	var defenders_button := Button.new()
	defenders_button.text = "Defenders"
	defenders_button.custom_minimum_size = Vector2(220, 45)
	defenders_button.pressed.connect(func():
		selected_team = 1
		_update_selection_status()
	)
	team_row.add_child(defenders_button)

	var class_label := Label.new()
	class_label.text = "CLASS"
	class_label.add_theme_font_size_override("font_size", 20)
	root_box.add_child(class_label)

	var class_names := [
		"Soldier",
		"Medic",
		"Engineer",
		"Field Ops",
		"Scout"
	]

	for class_index in class_names.size():
		var class_button := Button.new()
		class_button.text = class_names[class_index]
		class_button.custom_minimum_size = Vector2(450, 40)
		class_button.pressed.connect(func(index := class_index):
			selected_class = index
			_update_selection_status()
		)
		root_box.add_child(class_button)

	selection_status = Label.new()
	selection_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_status.add_theme_font_size_override("font_size", 18)
	root_box.add_child(selection_status)
	_update_selection_status()

	var deploy_button := Button.new()
	deploy_button.text = "DEPLOY"
	deploy_button.custom_minimum_size = Vector2(450, 52)
	deploy_button.add_theme_font_size_override("font_size", 22)
	deploy_button.pressed.connect(_submit_spawn_selection)
	root_box.add_child(deploy_button)

	var hint := Label.new()
	hint.text = "Press M anytime to reopen this menu"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_box.add_child(hint)

func _update_selection_status() -> void:
	if selection_status == null:
		return

	var team_name := "Attackers" if selected_team == 0 else "Defenders"
	var class_names := [
		"Soldier",
		"Medic",
		"Engineer",
		"Field Ops",
		"Scout"
	]
	var selected_class_name: String = class_names[
		clampi(selected_class, 0, class_names.size() - 1)
	]
	selection_status.text = "Selected: %s · %s" % [
		team_name,
		selected_class_name
	]

func _show_spawn_menu() -> void:
	if spawn_menu == null:
		return
	spawn_menu_open = true
	spawn_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _hide_spawn_menu() -> void:
	if spawn_menu == null:
		return
	if not has_deployed:
		return
	spawn_menu_open = false
	spawn_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _submit_spawn_selection() -> void:
	var main_node: Node = get_parent()
	if main_node == null:
		return

	var local_peer_id: int = multiplayer.get_unique_id()

	main_node.request_player_team_and_class.rpc_id(
		1,
		local_peer_id,
		selected_team,
		selected_class
	)

	has_deployed = true
	player_class = selected_class
	team = selected_team
	current_weapon_index = 0
	_configure_class_loadout(true, true)
	_hide_spawn_menu()

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
	var primary_profile: int = player_class
	weapon_view.position = _base_weapon_position()

	var receiver_length: float = 0.72
	var barrel_length: float = 0.55
	var receiver_height: float = 0.16
	var receiver_width: float = 0.16

	if is_pistol:
		receiver_length = 0.34
		barrel_length = 0.28
		receiver_height = 0.14
		receiver_width = 0.13
	else:
		match primary_profile:
			PlayerClass.SOLDIER:
				receiver_length = 0.88
				barrel_length = 0.68
				receiver_height = 0.19
				receiver_width = 0.19
			PlayerClass.MEDIC:
				receiver_length = 0.56
				barrel_length = 0.38
				receiver_height = 0.15
				receiver_width = 0.15
			PlayerClass.ENGINEER:
				receiver_length = 0.62
				barrel_length = 0.44
				receiver_height = 0.17
				receiver_width = 0.17
			PlayerClass.FIELD_OPS:
				receiver_length = 0.74
				barrel_length = 0.58
			PlayerClass.SCOUT:
				receiver_length = 0.92
				barrel_length = 0.82
				receiver_height = 0.13
				receiver_width = 0.14

	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.18, 0.19, 0.20)

	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.28, 0.16, 0.08)

	var receiver := MeshInstance3D.new()
	var receiver_mesh := BoxMesh.new()
	receiver_mesh.size = Vector3(
		receiver_width,
		receiver_height,
		receiver_length
	)
	receiver.mesh = receiver_mesh
	receiver.material_override = metal
	weapon_view.add_child(receiver)

	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.022 if is_pistol else 0.025
	barrel_mesh.bottom_radius = barrel_mesh.top_radius
	barrel_mesh.height = barrel_length
	barrel.mesh = barrel_mesh
	barrel.rotation_degrees.x = 90.0
	barrel.position.z = -(
		receiver_length * 0.5 + barrel_length * 0.35
	)
	barrel.material_override = metal
	weapon_view.add_child(barrel)

	if not is_pistol and player_class == PlayerClass.SCOUT:
		var scope := MeshInstance3D.new()
		var scope_mesh := CylinderMesh.new()
		scope_mesh.top_radius = 0.055
		scope_mesh.bottom_radius = 0.055
		scope_mesh.height = 0.28
		scope.mesh = scope_mesh
		scope.rotation_degrees.z = 90.0
		scope.position = Vector3(0.0, -0.12, -0.08)
		scope.material_override = metal
		weapon_view.add_child(scope)

	var grip := MeshInstance3D.new()
	var grip_mesh := BoxMesh.new()
	grip_mesh.size = Vector3(0.12, 0.25, 0.12) if is_pistol else Vector3(0.18, 0.22, 0.34)
	grip.mesh = grip_mesh
	grip.position = Vector3(0.0, 0.15, 0.10) if is_pistol else Vector3(0.0, 0.0, 0.42)
	grip.rotation_degrees.x = -15.0 if is_pistol else 0.0
	grip.material_override = wood
	weapon_view.add_child(grip)

	muzzle_flash = MeshInstance3D.new()
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.045 if is_pistol else 0.06
	flash_mesh.height = 0.09 if is_pistol else 0.12
	muzzle_flash.mesh = flash_mesh
	muzzle_flash.position = Vector3(
		0.0,
		0.0,
		-0.45 if is_pistol else -0.88
	)

	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color(1.0, 0.65, 0.12)
	flash_material.emission_enabled = true
	flash_material.emission = Color(1.0, 0.35, 0.02)
	muzzle_flash.material_override = flash_material
	muzzle_flash.visible = false
	weapon_view.add_child(muzzle_flash)


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

	damage_indicator = Label.new()
	damage_indicator.text = "DAMAGE"
	damage_indicator.position = Vector2(540, 90)
	damage_indicator.add_theme_font_size_override("font_size", 26)
	damage_indicator.visible = false
	layer.add_child(damage_indicator)

	scoreboard = Label.new(); scoreboard.position = Vector2(390, 150); scoreboard.add_theme_font_size_override("font_size", 18); scoreboard.visible = false; layer.add_child(scoreboard)
	feed = Label.new(); feed.position = Vector2(930, 24); feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; feed.custom_minimum_size = Vector2(320, 150); layer.add_child(feed)

func _update_hud() -> void:
	if hud == null:
		return

	var now: int = Time.get_ticks_msec()

	if hit_marker != null and hit_marker.visible and now >= hit_marker_until_ms:
		hit_marker.visible = false

	if damage_indicator != null and damage_indicator.visible and now >= damage_indicator_until_ms:
		damage_indicator.visible = false

	if muzzle_flash != null and muzzle_flash.visible and now >= muzzle_flash_until_ms:
		muzzle_flash.visible = false

	if weapon_kick_offset > 0.001:
		weapon_kick_offset = lerpf(
			weapon_kick_offset,
			0.0,
			clampf(get_process_delta_time() * 18.0, 0.0, 1.0)
		)
		_apply_weapon_kick()
	elif weapon_kick_offset != 0.0:
		weapon_kick_offset = 0.0
		_apply_weapon_kick()

	var names := ["Soldier", "Medic", "Engineer", "Field Ops", "Scout"]
	var main: Node = get_parent()

	var protocol_status := "Protocol pending"
	var input_ack: int = -1
	if main != null:
		protocol_status = str(main.get("protocol_message"))
		input_ack = int(main.get("last_server_input_ack"))
	protocol_status += " · input ack %d" % input_ack
	protocol_status += " · pos %.1f,%.1f · ammo %d" % [
		global_position.x,
		global_position.z,
		ammo_in_mag
	]

	var minutes := int(main.get("match_time_remaining")) / 60
	var seconds := int(main.get("match_time_remaining")) % 60
	var stance_text := "CROUCHED" if is_crouching else "STANDING"
	var life_text := "DOWNED" if downed else (
		"ALIVE"
		if alive
		else "RESPAWN IN %.1f · F cycles teammate" % float(
			main.get("spawn_wave_remaining")
		)
	)
	var objective_text: String = str(main.call("objective_status_text"))
	var primary_name: String = _resource_string(
		_class_primary_weapon(player_class),
		"display_name",
		"Primary"
	)
	var protection_seconds: float = float(
		replicated_spawn_protection_ms
	) / 1000.0
	var protection_text := (
		"PROTECTED %.1fs" % protection_seconds
		if replicated_spawn_protection_ms > 0
		else "Protection off"
	)
	var cooldown: float = float(
		replicated_ability_cooldown_ms
	) / 1000.0
	var ability_name: String = _ability_name()
	var ability_state := (
		"READY"
		if replicated_ability_cooldown_ms <= 0
		else "%.1fs" % cooldown
	)
	hud.text = "%s | %s | %s\n%s\nHP %d  Ammo %d/%d  %s [%d/%d]  Grenades %d  %s\nLoadout: %s + Service Pistol\n%s  Time %02d:%02d\nClass: %s  XP %d (%s)  Q: %s [%s]  G: grenade  X: switch  E: interact  M: spawn menu" % [
		player_name,
		"Attackers" if team == 0 else "Defenders",
		"%s · %s" % [life_text, stance_text],
		protocol_status,
		health,
		ammo_in_mag,
		reserve_ammo,
		(
			"RELOADING"
			if is_reloading
			else "%s%s" % [
				_weapon_display_name(),
				" (PISTOL)" if current_weapon_index == 1 else " (RIFLE)"
			]
		),
		current_weapon_index + 1,
		weapon_slots.size(),
		grenades_remaining,
		protection_text,
		primary_name,
		objective_text,
		minutes,
		seconds,
		names[player_class],
		xp,
		rank_name(),
		ability_name,
		ability_state
	]
	scoreboard.visible = Input.is_action_pressed("scoreboard")
	if scoreboard.visible:
		scoreboard.text = str(main.call("scoreboard_text"))
	feed.text = "\n".join(main.kill_feed)
