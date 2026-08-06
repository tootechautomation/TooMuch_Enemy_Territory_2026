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
const SNAPSHOT_LERP_SPEED := 20.0
const ABILITY_COOLDOWN_MS := 12000
const SCOUT_SPOT_DURATION_MS := 8000
const DEFAULT_FOV := 75.0
const ADS_FOV := 58.0
const SCOUT_ADS_FOV := 24.0
const ADS_MOVE_MULTIPLIER := 0.58
const ASSIST_WINDOW_MS := 10000
const FALL_DAMAGE_START_SPEED := 12.0
const FALL_DAMAGE_MAX_SPEED := 24.0
const MAX_STAMINA := 100.0
const STAMINA_DRAIN_PER_SECOND := 24.0
const STAMINA_REGEN_PER_SECOND := 18.0
const STAMINA_REGEN_DELAY_MS := 900
const SUPPRESSION_DURATION_MS := 1800
const HEAVY_FIRE_DURATION_MS := 9000
const MEDIC_REVIVE_PULSE_RADIUS := 12.0
const REVIVE_RANGE := 2.8
const BLEEDOUT_MS := 15000
const STANDING_HEAD_Y := 0.65
const CROUCH_HEAD_Y := 0.12
const STANDING_CAPSULE_HEIGHT := 1.8
const CROUCH_CAPSULE_HEIGHT := 1.15
const CROUCH_BODY_SCALE_Y := 0.64
const SPAWN_PROTECTION_MS := 5000

var tex_uniform_attackers: Texture2D
var tex_uniform_defenders: Texture2D
var tex_weapon_rifle: Texture2D
var tex_weapon_pistol: Texture2D
var tex_medal_elimination: Texture2D
var tex_medal_headshot: Texture2D
var tex_objective_marker: Texture2D
var tex_spawn_shield: Texture2D
var tex_muzzle_flash_ui: Texture2D

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
var aim_requested := false
var is_aiming := false
var last_received_sequence := 0
var local_sequence := 0
var next_fire_time := 0
var next_interact_time := 0
var next_ability_time := 0
var kills := 0
var deaths := 0
var assists := 0
var objective_points := 0
var round_xp := 0
var xp := 0
var is_bot := false
var interact_accumulator := 0.0
var bot_think_accumulator := 0.0
var bot_fire_accumulator := 0.0
var bot_ability_accumulator := 0.0
var bot_stuck_accumulator := 0.0
var bot_last_position := Vector3.ZERO
var bot_strafe_direction := 1.0
var bot_grenade_accumulator := 2.0
var bot_squad_role := 0
var bot_role_initialized := false
var target_position := Vector3.ZERO
var target_yaw := 0.0
var target_pitch := 0.0
var remote_smoothed_velocity := Vector3.ZERO
var previous_remote_position := Vector3.ZERO
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
var crosshair: Label
var scope_overlay: Control
var scope_reticle: Label
var world_nameplate: Label3D
var world_class_label: Label3D
var body_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var class_accent_mesh: MeshInstance3D
var last_visual_team := -1
var last_visual_class := -1
var revive_marker: Label3D
var objective_progress_bar: ProgressBar
var objective_progress_text: Label
var elimination_notice: Label
var elimination_notice_until_ms := 0
var tactical_indicator: Label
var damage_number: Label
var damage_number_until_ms := 0
var recent_damage: Dictionary = {}
var current_kill_streak := 0
var previous_vertical_velocity := 0.0
var rifle_fire_sound: AudioStream
var pistol_fire_sound: AudioStream
var dry_click_sound: AudioStream
var reload_sound: AudioStream
var footstep_sound: AudioStream
var hit_confirm_sound: AudioStream
var headshot_confirm_sound: AudioStream
var weapon_audio: AudioStreamPlayer
var reload_audio: AudioStreamPlayer
var footstep_audio: AudioStreamPlayer3D
var confirm_audio: AudioStreamPlayer
var footstep_accumulator := 0.0
var radar_panel: Control
var radar_objective: Label
var radar_actor_markers: Dictionary = {}
var radar_grenade_markers: Array[Label] = []
var stamina := MAX_STAMINA
var replicated_stamina := MAX_STAMINA
var stamina_regen_blocked_until_ms := 0
var suppressed_until_ms := 0
var replicated_suppression_ms := 0
var stamina_bar: ProgressBar
var suppression_overlay: ColorRect
var operations_label: Label
var command_post_bar: ProgressBar
var squad_ping_cooldown_until_ms := 0
var barricade_cooldown_until_ms := 0
var smoke_grenades := 1
var replicated_smoke_grenades := 1
var spectator_freecam := false
var spectator_freecam_position := Vector3.ZERO
var heavy_fire_until_ms := 0
var replicated_heavy_fire_ms := 0
var class_mode_label: Label
var rally_cooldown_until_ms := 0
var mission_banner: Label
var rank_progress_label: Label
var compass_label: Label
var medal_icon: TextureRect
var medal_label: Label
var medal_until_ms := 0
var directional_damage_labels: Dictionary = {}
var spawn_shield_icon: TextureRect
var spawn_shield_until_ms := 0
var muzzle_flash_sprite: TextureRect
var visual_animation_time := 0.0
var weapon_base_position := Vector3.ZERO
var weapon_base_rotation := Vector3.ZERO
var selection_status: Label
var local_next_fire_feedback_ms := 0
var grenades_remaining := 2
var next_grenade_time := 0
var is_crouching := false
var weapon_kick_offset := 0.0

var server_logged_first_input := false

func _load_optional_texture(path: String) -> Texture2D:
	if DisplayServer.get_name() == "headless":
		return null
	if not ResourceLoader.exists(path):
		push_warning("Optional texture not found: %s" % path)
		return null

	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D

	push_warning("Optional texture failed to load: %s" % path)
	return null

func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		tex_uniform_attackers = _load_optional_texture(
			"res://assets/textures/uniform_attackers.png"
		)
		tex_uniform_defenders = _load_optional_texture(
			"res://assets/textures/uniform_defenders.png"
		)
		tex_weapon_rifle = _load_optional_texture(
			"res://assets/textures/weapon_rifle.png"
		)
		tex_weapon_pistol = _load_optional_texture(
			"res://assets/textures/weapon_pistol.png"
		)
		tex_medal_elimination = _load_optional_texture(
			"res://assets/textures/medal_elimination.png"
		)
		tex_medal_headshot = _load_optional_texture(
			"res://assets/textures/medal_headshot.png"
		)
		tex_objective_marker = _load_optional_texture(
			"res://assets/textures/objective_marker.png"
		)
		tex_spawn_shield = _load_optional_texture(
			"res://assets/textures/spawn_shield.png"
		)
		tex_muzzle_flash_ui = _load_optional_texture(
			"res://assets/textures/muzzle_flash.png"
		)

	_initialize_loadout()
	if is_bot and not bot_role_initialized:
		bot_squad_role = posmod(peer_id, 4)
		bot_role_initialized = true
	bot_last_position = global_position
	_build_spotted_marker()
	_build_identity_visuals()
	_refresh_identity_visuals(true)
	target_position = global_position

	if _is_local_player() and DisplayServer.get_name() != "headless":
		var local_camera: Camera3D = $Head/Camera3D as Camera3D
		if local_camera != null:
			local_camera.current = true

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_build_first_person_weapon()
		_build_hud()
		_build_spawn_menu()
		_show_spawn_menu()
		call_deferred("_initialize_optional_client_systems")

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
		_update_identity_visibility()
		_update_footstep_audio(delta)
		_update_first_person_animation(delta)
		_update_world_character_animation(delta)
		_update_radar()
	elif not multiplayer.is_server():
		var position_alpha: float = (
			1.0 - exp(-SNAPSHOT_LERP_SPEED * delta)
		)
		var rotation_alpha: float = (
			1.0 - exp(-18.0 * delta)
		)
		var before_position: Vector3 = global_position
		global_position = global_position.lerp(
			target_position,
			position_alpha
		)
		rotation.y = lerp_angle(
			rotation.y,
			target_yaw,
			rotation_alpha
		)
		$Head.rotation.x = lerp_angle(
			$Head.rotation.x,
			target_pitch,
			rotation_alpha
		)
		if delta > 0.0001:
			var measured_velocity: Vector3 = (
				global_position - before_position
			) / delta
			remote_smoothed_velocity = (
				remote_smoothed_velocity.lerp(
					measured_velocity,
					1.0 - exp(-12.0 * delta)
				)
			)
			velocity = remote_smoothed_velocity
		_update_world_character_animation(delta)
		_update_identity_visibility()
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
		is_aiming = false
		_update_aim_view()
		return
	if not alive:
		is_aiming = false
		_update_aim_view()
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

	is_aiming = (
		Input.is_action_pressed("aim")
		and not downed
		and not is_reloading
	)
	_update_aim_view()

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
			Input.is_action_pressed("aim"),
			local_sequence
		)

	if not downed and Input.is_action_pressed("fire"):
		var camera := $Head/Camera3D as Camera3D
		if camera != null:
			var now: int = Time.get_ticks_msec()
			if now >= local_next_fire_feedback_ms:
				local_next_fire_feedback_ms = now + _weapon_fire_interval_ms()
				if ammo_in_mag > 0 and not is_reloading:
					_local_fire_feedback()
					_play_weapon_sound()
				else:
					_play_dry_click()
			if main_node != null:
				main_node.request_player_fire.rpc_id(
					1,
					local_peer_id,
					camera.global_position,
					-camera.global_transform.basis.z
				)

	if (
		not downed
		and Input.is_action_just_pressed("squad_ping")
		and Time.get_ticks_msec() >= squad_ping_cooldown_until_ms
	):
		var ping_camera: Camera3D = $Head/Camera3D as Camera3D
		if ping_camera != null and main_node != null:
			squad_ping_cooldown_until_ms = (
				Time.get_ticks_msec() + 1200
			)
			main_node.request_squad_ping.rpc_id(
				1,
				local_peer_id,
				-ping_camera.global_transform.basis.z
			)

	if not downed and player_class == PlayerClass.ENGINEER and Input.is_action_just_pressed("deploy_barricade") and Time.get_ticks_msec() >= barricade_cooldown_until_ms:
		if main_node != null:
			barricade_cooldown_until_ms = Time.get_ticks_msec() + 2500
			var deploy_position: Vector3 = global_position + (-global_transform.basis.z * 2.4)
			main_node.request_engineer_barricade.rpc_id(1, local_peer_id, deploy_position, rotation.y)

	if not downed and replicated_smoke_grenades > 0 and Input.is_action_just_pressed("throw_smoke"):
		var smoke_camera: Camera3D = $Head/Camera3D as Camera3D
		if smoke_camera != null and main_node != null:
			main_node.request_player_smoke.rpc_id(1, local_peer_id, smoke_camera.global_position, -smoke_camera.global_transform.basis.z)

	if (
		not downed
		and player_class == PlayerClass.FIELD_OPS
		and Input.is_action_just_pressed("deploy_rally")
		and Time.get_ticks_msec() >= rally_cooldown_until_ms
	):
		if main_node != null:
			rally_cooldown_until_ms = (
				Time.get_ticks_msec() + 8000
			)
			var rally_position: Vector3 = (
				global_position
				+ (-global_transform.basis.z * 2.2)
			)
			main_node.request_rally_point.rpc_id(
				1,
				local_peer_id,
				rally_position
			)

	if not downed and Input.is_action_just_pressed("reload"):
		if (
			reload_audio != null
			and reload_audio.stream != null
			and not reload_audio.playing
		):
			reload_audio.play()
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

func server_receive_input(move: Vector2, yaw: float, look_pitch: float, wants_jump: bool, wants_sprint: bool, wants_crouch: bool, wants_aim: bool, sequence: int) -> void:
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
	aim_requested = wants_aim

func _server_simulate(delta: float) -> void:
	var now: int = Time.get_ticks_msec()
	var was_on_floor: bool = is_on_floor()
	var falling_speed: float = -previous_vertical_velocity

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

	var wants_active_sprint: bool = (
		sprint_requested
		and input_vector.y < -0.2
		and not aim_requested
		and not crouch_requested
		and stamina > 1.0
	)

	if wants_active_sprint:
		stamina = maxf(
			0.0,
			stamina - STAMINA_DRAIN_PER_SECOND * delta
		)
		stamina_regen_blocked_until_ms = (
			now + STAMINA_REGEN_DELAY_MS
		)
	elif now >= stamina_regen_blocked_until_ms:
		stamina = minf(
			MAX_STAMINA,
			stamina + STAMINA_REGEN_PER_SECOND * delta
		)

	var move_speed: float = (
		CROUCH_SPEED
		if crouch_requested
		else (
			SPRINT_SPEED
			if wants_active_sprint
			else WALK_SPEED
		)
	)

	if aim_requested:
		move_speed *= ADS_MOVE_MULTIPLIER

	var direction: Vector3 = (
		transform.basis
		* Vector3(input_vector.x, 0.0, input_vector.y)
	).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	previous_vertical_velocity = velocity.y
	move_and_slide()

	if (
		not was_on_floor
		and is_on_floor()
		and falling_speed > FALL_DAMAGE_START_SPEED
	):
		var fall_ratio: float = clampf(
			(
				falling_speed - FALL_DAMAGE_START_SPEED
			)
			/ (
				FALL_DAMAGE_MAX_SPEED
				- FALL_DAMAGE_START_SPEED
			),
			0.0,
			1.0
		)
		var fall_damage: int = int(round(
			lerpf(8.0, 100.0, fall_ratio)
		))
		server_take_damage(fall_damage, 0)


func apply_player_snapshot(pos: Vector3, yaw: float, head_pitch: float, hp: int, magazine: int, reserve: int, is_alive: bool, is_downed: bool, reloading: bool, class_id: int, player_team: int, kill_count: int, death_count: int, experience: int, weapon_index: int, grenade_count: int, crouching: bool, spawn_protection_ms: int, ability_cooldown_ms: int, spotted_ms: int, stamina_value: float, suppression_ms: int, smoke_count: int, heavy_fire_ms: int) -> void:
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
	_refresh_identity_visuals()

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
	replicated_stamina = clampf(
		stamina_value,
		0.0,
		MAX_STAMINA
	)
	replicated_suppression_ms = maxi(0, suppression_ms)
	replicated_smoke_grenades = maxi(0, smoke_count)
	replicated_heavy_fire_ms = maxi(0, heavy_fire_ms)
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
	if class_accent_mesh != null:
		class_accent_mesh.visible = alive
	if weapon_view:
		weapon_view.visible = alive and not downed

	if revive_marker != null:
		var local_team := team
		var main_node: Node = get_parent()
		var local_id: int = multiplayer.get_unique_id()
		if main_node != null:
			var player_map: Dictionary = main_node.get("players")
			if player_map.has(local_id):
				var local_player: Node = player_map[local_id] as Node
				if local_player != null:
					local_team = int(local_player.get("team"))

		revive_marker.visible = (
			alive
			and downed
			and local_team == team
			and not _is_local_player()
		)

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

	if aim_requested:
		var ads_multiplier: float = (
			0.18
			if player_class == PlayerClass.SCOUT
			and current_weapon_index == 0
			else 0.42
		)
		spread *= ads_multiplier

	if suppression_remaining_ms() > 0:
		spread *= 1.65
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
	var hit: Dictionary = (
		get_world_3d().direct_space_state.intersect_ray(query)
	)
	var effect_end: Vector3 = (
		origin + shot_direction * _weapon_range_meters()
	)
	var hit_player := false
	var was_headshot := false

	if not hit.is_empty():
		effect_end = Vector3(hit.get("position", effect_end))

	if not hit.is_empty():
		var hit_collider: Object = hit.get("collider")
		if hit_collider != null and hit_collider.has_method("server_take_damage") and not hit_collider is CharacterBody3D:
			hit_collider.call("server_take_damage", _weapon_damage(), peer_id)

	if (
		not hit.is_empty()
		and hit.get("collider") is CharacterBody3D
	):
		var target: CharacterBody3D = (
			hit.get("collider") as CharacterBody3D
		)
		if target != null and target.has_method(
			"server_take_damage"
		):
			var target_team: int = int(target.get("team"))
			if target_team != team:
				hit_player = true
				var local_hit_height: float = (
					effect_end.y - target.global_position.y
				)
				was_headshot = local_hit_height >= 0.62
				var damage_amount: int = _weapon_damage()
				if was_headshot:
					damage_amount = int(round(
						float(damage_amount) * 1.75
					))
				target.call(
					"server_take_damage",
					damage_amount,
					peer_id
				)
				if was_headshot:
					confirm_headshot.rpc_id(peer_id)
				else:
					confirm_hit.rpc_id(peer_id)

	var main_node: Node = get_parent()
	if main_node != null and main_node.has_method(
		"show_shot_effect"
	):
		main_node.show_shot_effect.rpc(
			origin,
			effect_end,
			hit_player,
			was_headshot
		)

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
	aim_requested = false
	is_aiming = false
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
	var base_damage: int = _resource_int(weapon, "damage", 20)
	if heavy_fire_remaining_ms() > 0 and current_weapon_index == 0:
		base_damage = int(round(base_damage * 1.16))
	return base_damage

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
	var interval: int = maxi(1, int(round(60000.0 / rounds_per_minute)))
	if heavy_fire_remaining_ms() > 0 and current_weapon_index == 0:
		interval = maxi(55, int(round(interval * 0.72)))
	return interval

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
	aim_requested = false
	is_aiming = false
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
func _show_combat_medal(title: String, headshot: bool) -> void:
	if medal_icon == null or medal_label == null:
		return
	medal_icon.texture = (
		tex_medal_headshot if headshot else tex_medal_elimination
	)
	medal_label.text = title
	medal_icon.visible = medal_icon.texture != null
	medal_label.visible = true
	medal_until_ms = Time.get_ticks_msec() + 1250

func _show_spawn_presentation() -> void:
	if spawn_shield_icon == null:
		return
	spawn_shield_icon.texture = tex_spawn_shield
	spawn_shield_icon.visible = spawn_shield_icon.texture != null
	spawn_shield_until_ms = Time.get_ticks_msec() + 1800

func _update_objective_compass() -> void:
	if compass_label == null or not alive:
		return
	var main_node: Node = get_parent()
	if main_node == null:
		return

	var target: Node3D = (
		main_node.get_node_or_null("BridgeBuildSite") as Node3D
		if int(main_node.get("objective_stage")) == 0
		else main_node.get_node_or_null("Objective") as Node3D
	)
	if target == null:
		compass_label.text = ""
		return

	var offset: Vector3 = target.global_position - global_position
	offset.y = 0.0
	var distance: int = int(round(offset.length()))
	if offset.length() <= 0.01:
		compass_label.text = "◆ OBJECTIVE 0m"
		return

	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	var direction: Vector3 = offset.normalized()
	var fd: float = forward.dot(direction)
	var rd: float = right.dot(direction)
	var arrow := "◆"
	if absf(rd) > 0.38:
		arrow = "▶" if rd > 0.0 else "◀"
	elif fd < 0.0:
		arrow = "▼"
	compass_label.text = "%s OBJECTIVE %dm" % [arrow, distance]

func confirm_hit() -> void:
	if not _is_local_player():
		return
	_play_confirm_sound(false)
	hit_marker_until_ms = Time.get_ticks_msec() + 140
	if hit_marker != null:
		hit_marker.text = "×"
		hit_marker.position = Vector2(634, 344)
		hit_marker.visible = true

@rpc("authority", "call_remote", "reliable")
func confirm_headshot() -> void:
	if not _is_local_player():
		return

	_play_confirm_sound(true)
	hit_marker_until_ms = Time.get_ticks_msec() + 260
	if hit_marker != null:
		hit_marker.text = "HEADSHOT"
		hit_marker.position = Vector2(580, 332)
		hit_marker.visible = true

	_show_combat_medal("HEADSHOT", true)
	elimination_notice_until_ms = Time.get_ticks_msec() + 650
	if elimination_notice != null:
		elimination_notice.text = "HEADSHOT"
		elimination_notice.visible = true

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

func recent_damage_contributors() -> Dictionary:
	if not multiplayer.is_server():
		return {}

	var now: int = Time.get_ticks_msec()
	var result: Dictionary = {}
	var expired: Array[int] = []

	for attacker_id_value in recent_damage:
		var attacker_id: int = int(attacker_id_value)
		var entry: Dictionary = recent_damage[attacker_id]
		var timestamp: int = int(entry.get("time", 0))
		var total_damage: int = int(entry.get("damage", 0))

		if now - timestamp > ASSIST_WINDOW_MS:
			expired.append(attacker_id)
			continue
		if total_damage >= 20:
			result[attacker_id] = total_damage

	for attacker_id in expired:
		recent_damage.erase(attacker_id)

	return result

func server_register_elimination() -> void:
	if not multiplayer.is_server():
		return

	current_kill_streak += 1
	var message := "ELIMINATION"
	if current_kill_streak >= 5:
		message = "RAMPAGE x%d" % current_kill_streak
	elif current_kill_streak >= 3:
		message = "KILL STREAK x%d" % current_kill_streak

	combat_notice.rpc_id(peer_id, message)

func server_confirm_assist() -> void:
	if not multiplayer.is_server():
		return
	combat_notice.rpc_id(peer_id, "ASSIST +5 XP")

@rpc("authority", "call_remote", "reliable")
func confirm_damage_amount(
	amount: int,
	target_health: int
) -> void:
	if not _is_local_player():
		return
	if damage_number == null:
		return

	damage_number.text = "%d  ·  enemy HP %d" % [
		amount,
		maxi(0, target_health)
	]
	damage_number_until_ms = Time.get_ticks_msec() + 520
	damage_number.visible = true

@rpc("authority", "call_remote", "reliable")
func combat_notice(message: String) -> void:
	if not _is_local_player():
		return
	if elimination_notice == null:
		return

	elimination_notice.text = message
	_show_combat_medal(message, false)
	elimination_notice_until_ms = (
		Time.get_ticks_msec() + 1100
	)
	elimination_notice.visible = true

func heavy_fire_remaining_ms() -> int:
	if not multiplayer.is_server():
		return replicated_heavy_fire_ms
	return maxi(0, heavy_fire_until_ms - Time.get_ticks_msec())

func suppression_remaining_ms() -> int:
	if not multiplayer.is_server():
		return replicated_suppression_ms
	return maxi(
		0,
		suppressed_until_ms - Time.get_ticks_msec()
	)

func _apply_suppression(duration_ms: int = SUPPRESSION_DURATION_MS) -> void:
	if not multiplayer.is_server():
		return
	suppressed_until_ms = maxi(
		suppressed_until_ms,
		Time.get_ticks_msec() + duration_ms
	)

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not alive or downed:
		return
	if _has_spawn_protection():
		return

	health = maxi(0, health - amount)
	if attacker_id != peer_id and attacker_id != 0:
		_apply_suppression()

	if attacker_id != peer_id and attacker_id != 0:
		var existing: Dictionary = recent_damage.get(
			attacker_id,
			{"damage": 0, "time": 0}
		)
		existing["damage"] = (
			int(existing.get("damage", 0)) + amount
		)
		existing["time"] = Time.get_ticks_msec()
		recent_damage[attacker_id] = existing

		if get_parent().players.has(attacker_id):
			var damage_attacker: Node3D = (
				get_parent().players[attacker_id] as Node3D
			)
			if (
				damage_attacker != null
				and not bool(damage_attacker.get("is_bot"))
			):
				confirm_damage_amount.rpc_id(
					attacker_id,
					amount,
					health
				)

	var attacker_position: Vector3 = global_position
	if get_parent().players.has(attacker_id):
		var attacker: Node3D = get_parent().players[attacker_id] as Node3D
		if attacker != null:
			attacker_position = attacker.global_position
	damage_feedback.rpc_id(peer_id, attacker_position, amount)

	if health == 0:
		set_meta("last_attacker_id", attacker_id)

		if is_bot:
			_finish_death(attacker_id)
			return

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

func _finish_death(attacker_override: int) -> void:
	if not multiplayer.is_server() or not alive:
		return

	var attacker_id: int = (
		attacker_override
		if attacker_override != 0
		else int(get_meta("last_attacker_id", 0))
	)

	alive = false
	downed = false
	health = 0
	deaths += 1
	current_kill_streak = 0
	recent_damage.clear()
	visible = false
	velocity = Vector3.ZERO
	input_vector = Vector2.ZERO
	is_reloading = false
	aim_requested = false

	var collision: CollisionShape3D = (
		$CollisionShape3D as CollisionShape3D
	)
	if collision != null:
		collision.set_deferred("disabled", true)

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
	for arrow_value in directional_damage_labels.values():
		var arrow: Label = arrow_value as Label
		if arrow != null:
			arrow.visible = false
	var direction_arrow: Label = directional_damage_labels.get(
		direction_text
	) as Label
	if direction_arrow != null:
		direction_arrow.visible = true

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
	stamina = MAX_STAMINA
	suppressed_until_ms = 0
	heavy_fire_until_ms = 0
	smoke_grenades = 1
	recent_damage.clear()
	previous_vertical_velocity = 0.0
	_reset_loadout_ammo()
	grenades_remaining = 2
	_apply_server_crouch(false)
	_activate_spawn_protection()
	alive = true
	downed = false
	is_reloading = false
	visible = true

	var collision: CollisionShape3D = (
		$CollisionShape3D as CollisionShape3D
	)
	if collision != null:
		collision.set_deferred("disabled", false)

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

func _team_color(team_id: int) -> Color:
	return Color(0.14, 0.34, 0.82) if team_id == 0 else Color(0.82, 0.18, 0.14)

func _class_accent_color(class_id: int) -> Color:
	match class_id:
		PlayerClass.SOLDIER: return Color(0.78, 0.72, 0.22)
		PlayerClass.MEDIC: return Color(0.18, 0.82, 0.34)
		PlayerClass.ENGINEER: return Color(0.90, 0.48, 0.12)
		PlayerClass.FIELD_OPS: return Color(0.60, 0.30, 0.82)
		PlayerClass.SCOUT: return Color(0.12, 0.78, 0.78)
		_: return Color.WHITE

func _class_short_name(class_id: int) -> String:
	match class_id:
		PlayerClass.SOLDIER: return "SOLDIER"
		PlayerClass.MEDIC: return "MEDIC"
		PlayerClass.ENGINEER: return "ENGINEER"
		PlayerClass.FIELD_OPS: return "FIELD OPS"
		PlayerClass.SCOUT: return "SCOUT"
		_: return "CLASS"

func _build_identity_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var body: MeshInstance3D = $Body as MeshInstance3D
	if body != null:
		body_material = StandardMaterial3D.new()
		body_material.roughness = 0.82
		body.material_override = body_material

	class_accent_mesh = MeshInstance3D.new()
	class_accent_mesh.name = "ClassAccent"
	var accent_mesh := BoxMesh.new()
	accent_mesh.size = Vector3(0.56, 0.18, 0.18)
	class_accent_mesh.mesh = accent_mesh
	class_accent_mesh.position = Vector3(0.0, 0.38, 0.18)
	accent_material = StandardMaterial3D.new()
	accent_material.emission_enabled = true
	accent_material.emission_energy_multiplier = 0.35
	class_accent_mesh.material_override = accent_material
	add_child(class_accent_mesh)

	world_nameplate = Label3D.new()
	world_nameplate.name = "WorldNameplate"
	world_nameplate.position = Vector3(0.0, 1.62, 0.0)
	world_nameplate.font_size = 34
	world_nameplate.outline_size = 10
	world_nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world_nameplate.fixed_size = true
	world_nameplate.visible = false
	add_child(world_nameplate)

	world_class_label = Label3D.new()
	world_class_label.name = "WorldClassLabel"
	world_class_label.position = Vector3(0.0, 1.38, 0.0)
	world_class_label.font_size = 22
	world_class_label.outline_size = 8
	world_class_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world_class_label.fixed_size = true
	world_class_label.visible = false
	add_child(world_class_label)

	revive_marker = Label3D.new()
	revive_marker.name = "ReviveMarker"
	revive_marker.text = "REVIVE"
	revive_marker.position = Vector3(0.0, 1.30, 0.0)
	revive_marker.font_size = 32
	revive_marker.outline_size = 10
	revive_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	revive_marker.fixed_size = true
	revive_marker.modulate = Color(0.25, 1.0, 0.38)
	revive_marker.visible = false
	add_child(revive_marker)

func _refresh_identity_visuals(force: bool = false) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not force and team == last_visual_team and player_class == last_visual_class:
		return

	last_visual_team = team
	last_visual_class = player_class
	var team_color: Color = _team_color(team)
	var accent_color: Color = _class_accent_color(player_class)

	if body_material != null:
		var uniform_texture: Texture2D = (
			tex_uniform_attackers
			if team == 0
			else tex_uniform_defenders
		)
		if uniform_texture != null:
			body_material.albedo_texture = uniform_texture
		body_material.albedo_color = team_color.lightened(0.22)
		body_material.roughness = 0.82
		body_material.emission_enabled = true
		body_material.emission = team_color * 0.10

	if accent_material != null:
		accent_material.albedo_color = accent_color
		accent_material.emission = accent_color

	if world_nameplate != null:
		world_nameplate.text = player_name
		world_nameplate.modulate = team_color.lightened(0.35)

	if world_class_label != null:
		world_class_label.text = _class_short_name(player_class)
		world_class_label.modulate = accent_color.lightened(0.25)

func _update_identity_visibility() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if world_nameplate == null or world_class_label == null:
		return
	if _is_local_player():
		world_nameplate.visible = false
		world_class_label.visible = false
		return

	var main: Node = get_parent()
	if main == null:
		return
	var player_map: Dictionary = main.get("players")
	var local_id: int = multiplayer.get_unique_id()
	if not player_map.has(local_id):
		world_nameplate.visible = false
		world_class_label.visible = false
		return

	var local_player: Node3D = player_map[local_id] as Node3D
	if local_player == null:
		return

	var same_team: bool = int(local_player.get("team")) == team
	var distance: float = local_player.global_position.distance_to(global_position)
	var enemy_spotted: bool = replicated_spotted_ms > 0

	world_nameplate.visible = alive and not downed and (
		(same_team and distance <= 34.0)
		or (enemy_spotted and distance <= 50.0)
	)
	world_class_label.visible = alive and not downed and same_team and distance <= 24.0

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
			return "Heavy Fire"
		PlayerClass.MEDIC:
			return "Revive Pulse"
		PlayerClass.ENGINEER:
			return "Fortify"
		PlayerClass.FIELD_OPS:
			return "Artillery Strike"
		PlayerClass.SCOUT:
			return "Sensor Beacon"
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
	if main == null:
		return

	match player_class:
		PlayerClass.SOLDIER:
			heavy_fire_until_ms = now + HEAVY_FIRE_DURATION_MS
			reserve_ammo = mini(reserve_ammo + 60, _weapon_reserve_ammo() + 100)
			add_xp(4, "heavy fire")
			main.push_kill_feed.rpc("%s activated Heavy Fire" % player_name)

		PlayerClass.MEDIC:
			var revived_count := 0
			var healed_count := 0
			for player_value in main.players.values():
				var teammate: Node3D = player_value as Node3D
				if teammate == null or int(teammate.get("team")) != team:
					continue
				if global_position.distance_to(teammate.global_position) > MEDIC_REVIVE_PULSE_RADIUS:
					continue
				if bool(teammate.get("alive")) and bool(teammate.get("downed")):
					teammate.call("server_revive", peer_id)
					revived_count += 1
				elif bool(teammate.get("alive")):
					var maximum: int = int(teammate.call("_class_health", int(teammate.get("player_class"))))
					var current: int = int(teammate.get("health"))
					if current < maximum:
						teammate.set("health", mini(maximum, current + 32))
						healed_count += 1
			if main.has_method("create_supply_pack"):
				main.call("create_supply_pack", self, 0, 50)
			add_xp(revived_count * 12 + healed_count * 3, "revive pulse")
			main.push_kill_feed.rpc("%s used Revive Pulse" % player_name)

		PlayerClass.ENGINEER:
			health = mini(_class_health(player_class), health + 30)
			var repaired := 0
			if main.has_method("repair_nearby_barricades"):
				repaired = int(main.call("repair_nearby_barricades", self, 85))
			if main.has_method("server_engineer_interact"):
				for step in range(2):
					main.call("server_engineer_interact", self)
			add_xp(4 + repaired * 3, "fortify")
			main.push_kill_feed.rpc("%s reinforced field defenses" % player_name)

		PlayerClass.FIELD_OPS:
			var target_position: Vector3 = global_position + (-global_transform.basis.z * 22.0)
			target_position.y = 0.15
			var ray_start: Vector3 = $Head.global_position
			var ray_end: Vector3 = ray_start + (-$Head.global_transform.basis.z * 50.0)
			var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
			query.exclude = [self]
			var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
			if not hit.is_empty():
				target_position = Vector3(hit.get("position", target_position))
			if main.has_method("server_call_artillery"):
				main.call("server_call_artillery", self, target_position)
			if main.has_method("create_supply_pack"):
				main.call("create_supply_pack", self, 1, 85)
			add_xp(5, "artillery call")

		PlayerClass.SCOUT:
			if main.has_method("create_sensor_beacon"):
				main.call("create_sensor_beacon", self)
			if main.has_method("server_scout_recon"):
				main.call("server_scout_recon", self, 28.0, 3500)
			add_xp(4, "sensor beacon")
			main.push_kill_feed.rpc("%s deployed a sensor beacon" % player_name)

func server_class_request(index: int) -> void:
	if not multiplayer.is_server():
		return
	player_class = clampi(index, 0, 4); health = mini(health, _class_health(player_class))


func _server_bot_tick(delta: float) -> void:
	var main: Node = get_parent()
	if main == null:
		return

	if not alive:
		velocity = Vector3.ZERO
		return

	if downed or bool(main.get("match_over")):
		velocity = Vector3.ZERO
		return

	var now: int = Time.get_ticks_msec()

	if is_reloading and now >= reload_finish_ms:
		_finish_reload()

	bot_fire_accumulator = maxf(
		0.0,
		bot_fire_accumulator - delta
	)
	bot_ability_accumulator = maxf(
		0.0,
		bot_ability_accumulator - delta
	)
	bot_grenade_accumulator = maxf(
		0.0,
		bot_grenade_accumulator - delta
	)

	var target_player: Node3D = null
	var movement_goal := Vector3.ZERO
	var has_movement_goal := false

	if player_class == PlayerClass.MEDIC:
		var downed_teammate: Node3D = main.call(
			"nearest_downed_teammate",
			self
		) as Node3D
		if downed_teammate != null:
			var revive_distance: float = global_position.distance_to(
				downed_teammate.global_position
			)
			if revive_distance <= REVIVE_RANGE:
				downed_teammate.call(
					"server_revive",
					peer_id
				)
				return
			movement_goal = downed_teammate.global_position
			has_movement_goal = true

	if (
		player_class == PlayerClass.ENGINEER
		and not has_movement_goal
	):
		var objective_goal: Vector3 = Vector3(
			main.call("bot_goal_position", self)
		)
		var objective_distance: float = global_position.distance_to(
			objective_goal
		)
		if objective_distance <= 3.4:
			main.call("server_engineer_interact", self)
		else:
			movement_goal = objective_goal
			has_movement_goal = true

	target_player = main.call("nearest_enemy", self) as Node3D

	if target_player != null:
		var enemy_distance: float = global_position.distance_to(
			target_player.global_position
		)
		var combat_range: float = minf(
			_weapon_range_meters(),
			28.0 if player_class != PlayerClass.SCOUT else 42.0
		)

		if (
			enemy_distance <= combat_range
			and _bot_has_line_of_sight(target_player)
		):
			_bot_face_position(target_player.global_position)

			if (
				bot_grenade_accumulator <= 0.0
				and grenades_remaining > 0
				and enemy_distance >= 8.0
				and enemy_distance <= 22.0
				and randf() <= 0.18
			):
				bot_grenade_accumulator = 7.0
				var grenade_direction: Vector3 = (
					target_player.global_position
					+ Vector3.UP * 0.8
					- $Head.global_position
				).normalized()
				server_throw_grenade_request(
					grenade_direction
				)

			var desired_spacing: float = (
				18.0
				if player_class == PlayerClass.SCOUT
				else 10.0
			)

			if enemy_distance < desired_spacing * 0.65:
				var retreat: Vector3 = (
					global_position
					- target_player.global_position
				)
				retreat.y = 0.0
				if retreat.length() > 0.01:
					movement_goal = (
						global_position
						+ retreat.normalized() * 4.0
					)
					has_movement_goal = true
			elif enemy_distance > desired_spacing:
				movement_goal = target_player.global_position
				has_movement_goal = true
			else:
				var right: Vector3 = global_transform.basis.x
				movement_goal = (
					global_position
					+ right * bot_strafe_direction * 3.0
				)
				has_movement_goal = true

			if bot_fire_accumulator <= 0.0:
				bot_fire_accumulator = maxf(
					0.10,
					float(_weapon_fire_interval_ms())
					/ 1000.0
				)
				_server_bot_fire(target_player)
		elif not has_movement_goal:
			movement_goal = target_player.global_position
			has_movement_goal = true

	if not has_movement_goal:
		movement_goal = Vector3(
			main.call("bot_goal_position", self)
		)

		var artillery_danger: Variant = (
			main.call("_artillery_danger_position")
			if main.has_method("_artillery_danger_position")
			else null
		)
		if artillery_danger is Vector3:
			var danger: Vector3 = artillery_danger as Vector3
			if global_position.distance_to(danger) <= 10.0:
				var escape: Vector3 = (
					global_position - danger
				)
				escape.y = 0.0
				if escape.length() > 0.01:
					movement_goal = (
						global_position
						+ escape.normalized() * 9.0
					)

		# Deterministic bot squad roles spread the team across lanes.
		match bot_squad_role:
			0:
				movement_goal.z -= 4.5
			1:
				movement_goal.z += 4.5
			2:
				movement_goal.x -= 2.5
			3:
				movement_goal.x += 2.5

		has_movement_goal = true

	if bot_ability_accumulator <= 0.0:
		bot_ability_accumulator = 2.5
		_bot_try_ability()

	if has_movement_goal:
		_bot_move_toward(movement_goal, delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	_bot_update_stuck_state(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _bot_face_position(world_position: Vector3) -> void:
	var flat_direction: Vector3 = world_position - global_position
	flat_direction.y = 0.0
	if flat_direction.length() <= 0.01:
		return
	look_at(
		global_position + flat_direction.normalized(),
		Vector3.UP
	)

func _bot_move_toward(
	world_position: Vector3,
	delta: float
) -> void:
	var flat_direction: Vector3 = world_position - global_position
	flat_direction.y = 0.0
	var distance: float = flat_direction.length()

	if distance <= 0.65:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	flat_direction = flat_direction.normalized()
	_bot_face_position(world_position)

	var bot_speed: float = (
		4.4
		if player_class == PlayerClass.SCOUT
		else 5.2
	)
	velocity.x = flat_direction.x * bot_speed
	velocity.z = flat_direction.z * bot_speed

	if is_on_floor() and _bot_obstacle_ahead(flat_direction):
		velocity.y = JUMP_SPEED

func _bot_obstacle_ahead(direction: Vector3) -> bool:
	var space_state: PhysicsDirectSpaceState3D = (
		get_world_3d().direct_space_state
	)

	var low_from: Vector3 = global_position + Vector3.UP * 0.35
	var low_to: Vector3 = low_from + direction * 0.9
	var low_query := PhysicsRayQueryParameters3D.create(
		low_from,
		low_to
	)
	low_query.exclude = [self]
	var low_hit: Dictionary = space_state.intersect_ray(low_query)

	if low_hit.is_empty():
		return false

	var high_from: Vector3 = global_position + Vector3.UP * 1.25
	var high_to: Vector3 = high_from + direction * 0.9
	var high_query := PhysicsRayQueryParameters3D.create(
		high_from,
		high_to
	)
	high_query.exclude = [self]
	var high_hit: Dictionary = space_state.intersect_ray(
		high_query
	)

	return high_hit.is_empty()

func _bot_update_stuck_state(delta: float) -> void:
	var moved_distance: float = global_position.distance_to(
		bot_last_position
	)

	if moved_distance < 0.04 and Vector2(
		velocity.x,
		velocity.z
	).length() > 0.5:
		bot_stuck_accumulator += delta
	else:
		bot_stuck_accumulator = 0.0
		bot_last_position = global_position

	if bot_stuck_accumulator >= 1.1:
		bot_stuck_accumulator = 0.0
		bot_strafe_direction *= -1.0
		rotation.y += deg_to_rad(
			90.0 * bot_strafe_direction
		)
		if is_on_floor():
			velocity.y = JUMP_SPEED

func _bot_try_ability() -> void:
	if Time.get_ticks_msec() < next_ability_time:
		return

	match player_class:
		PlayerClass.SOLDIER:
			if reserve_ammo < int(
				_weapon_reserve_ammo() * 0.5
			):
				server_ability_request()

		PlayerClass.MEDIC:
			var needs_healing := health < int(
				_class_health(player_class) * 0.7
			)
			if not needs_healing:
				for player_value in get_parent().players.values():
					var teammate: Node3D = player_value as Node3D
					if teammate == null:
						continue
					if int(teammate.get("team")) != team:
						continue
					if int(teammate.get("health")) < int(
						teammate.call(
							"_class_health",
							int(teammate.get("player_class"))
						)
					):
						needs_healing = true
						break
			if needs_healing:
				server_ability_request()

		PlayerClass.ENGINEER:
			var should_fortify := health < int(
				_class_health(player_class) * 0.85
			)
			if not should_fortify:
				should_fortify = randf() <= 0.28
			if should_fortify:
				server_ability_request()

		PlayerClass.FIELD_OPS:
			if reserve_ammo < int(
				_weapon_reserve_ammo() * 0.65
			):
				server_ability_request()

		PlayerClass.SCOUT:
			var enemy: Node3D = get_parent().call(
				"nearest_enemy",
				self
			) as Node3D
			if enemy != null:
				server_ability_request()

func _bot_has_line_of_sight(target: Node3D) -> bool:
	var from := global_position + Vector3.UP * 0.8
	var to := target.global_position + Vector3.UP * 0.8
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var main_node: Node = get_parent()
	if main_node != null and main_node.has_method("line_blocked_by_smoke"):
		if bool(main_node.call("line_blocked_by_smoke", from, to)):
			return false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == target

func _server_bot_fire(target: Node3D) -> void:
	if is_reloading or target == null:
		return

	if ammo_in_mag <= 0:
		_server_start_reload()
		return

	_cancel_spawn_protection()
	aim_requested = (
		player_class == PlayerClass.SCOUT
		or global_position.distance_to(
			target.global_position
		) > 14.0
	)

	ammo_in_mag -= 1
	_store_current_weapon_ammo()

	var main_node: Node = get_parent()
	var skill_multiplier: float = 1.0
	if main_node != null:
		skill_multiplier = float(main_node.get("bot_skill"))

	var accuracy_scale: float = clampf(
		(
			0.88
			if aim_requested
			else 0.70
		) * skill_multiplier,
		0.35,
		0.97
	)
	var shot_origin: Vector3 = $Head.global_position
	var shot_end: Vector3 = target.global_position + Vector3.UP * 0.75
	var hit_target: bool = randf() <= accuracy_scale
	var bot_headshot: bool = (
		hit_target
		and randf() <= (
			0.18
			if player_class == PlayerClass.SCOUT
			else 0.07
		)
	)

	if hit_target and target.has_method("server_take_damage"):
		var bot_damage: int = _weapon_damage()
		if bot_headshot:
			bot_damage = int(round(float(bot_damage) * 1.75))
		target.call(
			"server_take_damage",
			bot_damage,
			peer_id
		)

	if main_node != null and main_node.has_method(
		"show_shot_effect"
	):
		main_node.show_shot_effect.rpc(
			shot_origin,
			shot_end,
			hit_target,
			bot_headshot
		)

func server_force_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	global_position = spawn_position
	velocity = Vector3.ZERO
	alive = true
	downed = false
	health = _class_health(player_class)
	stamina = MAX_STAMINA
	suppressed_until_ms = 0
	heavy_fire_until_ms = 0
	smoke_grenades = 1
	_reset_loadout_ammo()
	grenades_remaining = 2
	_apply_server_crouch(false)
	_activate_spawn_protection()
	bleedout_finish_ms = 0

	var collision: CollisionShape3D = (
		$CollisionShape3D as CollisionShape3D
	)
	if collision != null:
		collision.set_deferred("disabled", false)

	show()
	show_spawn_presentation.rpc_id(peer_id)

@rpc("authority", "call_remote", "reliable")
func show_spawn_presentation() -> void:
	if _is_local_player():
		_show_spawn_presentation()

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
	_refresh_identity_visuals(true)
	next_ability_time = 0
	spotted_until_ms = 0
	current_weapon_index = 0
	_configure_class_loadout(true, false)

func add_xp(amount: int, reason: String = "") -> void:
	if not multiplayer.is_server():
		return

	var safe_amount: int = maxi(0, amount)
	xp += safe_amount
	round_xp += safe_amount

	var normalized_reason: String = reason.to_lower()
	if normalized_reason == "assist":
		assists += 1

	if (
		"objective" in normalized_reason
		or "bridge" in normalized_reason
		or "fortif" in normalized_reason
		or "command post" in normalized_reason
		or "supply depot" in normalized_reason
		or "rally" in normalized_reason
		or "artillery" in normalized_reason
		or "revive" in normalized_reason
	):
		objective_points += safe_amount

	if reason != "":
		print(
			"%s gained %d XP: %s"
			% [player_name, safe_amount, reason]
		)

func rank_level() -> int:
	if xp >= 600:
		return 5
	if xp >= 300:
		return 4
	if xp >= 180:
		return 3
	if xp >= 100:
		return 2
	if xp >= 40:
		return 1
	return 0

func rank_name() -> String:
	match rank_level():
		5:
			return "Major"
		4:
			return "Captain"
		3:
			return "Lieutenant"
		2:
			return "Sergeant"
		1:
			return "Corporal"
		_:
			return "Recruit"

func next_rank_xp() -> int:
	match rank_level():
		0:
			return 40
		1:
			return 100
		2:
			return 180
		3:
			return 300
		4:
			return 600
		_:
			return 600

func rank_progress_text() -> String:
	if rank_level() >= 5:
		return "%s · MAX RANK · %d XP" % [rank_name(), xp]
	return "%s · %d/%d XP" % [
		rank_name(),
		xp,
		next_rank_xp()
	]

func rank_health_bonus() -> int:
	return rank_level() * 2

func rank_reserve_bonus() -> int:
	return rank_level() * 8

func _class_health(class_id: int) -> int:
	var base_health := 100
	match class_id:
		PlayerClass.SOLDIER:
			base_health = 120
		PlayerClass.MEDIC:
			base_health = 110
		PlayerClass.SCOUT:
			base_health = 90
		_:
			base_health = 100
	return base_health + rank_health_bonus()

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
	if camera == null:
		return
	if alive:
		spectator_target_id = 0
		spectator_index = -1
		spectator_freecam = false
		camera.position = Vector3.ZERO
		camera.rotation = Vector3.ZERO
		return
	if Input.is_action_just_pressed("spectator_freecam"):
		spectator_freecam = not spectator_freecam
		if spectator_freecam:
			spectator_freecam_position = camera.global_position
	if spectator_freecam:
		var delta: float = get_process_delta_time()
		var free_move := Input.get_vector("move_left","move_right","move_forward","move_back")
		var movement: Vector3 = camera.global_transform.basis.x * free_move.x + (-camera.global_transform.basis.z) * -free_move.y
		if Input.is_action_pressed("jump"):
			movement += Vector3.UP
		if Input.is_action_pressed("crouch"):
			movement -= Vector3.UP
		if movement.length() > 0.01:
			spectator_freecam_position += movement.normalized() * 12.0 * delta
		camera.global_position = spectator_freecam_position
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
	if muzzle_flash_sprite != null:
		muzzle_flash_sprite.texture = tex_muzzle_flash_ui
		muzzle_flash_sprite.visible = muzzle_flash_sprite.texture != null

	_spawn_local_shell_effect()

func _spawn_local_shell_effect() -> void:
	if weapon_view == null or not _is_local_player():
		return

	var shell := MeshInstance3D.new()
	shell.name = "ShellEffect"
	var shell_mesh := CylinderMesh.new()
	shell_mesh.top_radius = 0.012
	shell_mesh.bottom_radius = 0.012
	shell_mesh.height = 0.055
	shell.mesh = shell_mesh
	shell.position = Vector3(0.14, -0.02, -0.10)
	shell.rotation_degrees = Vector3(0.0, 0.0, 90.0)

	var shell_material := StandardMaterial3D.new()
	shell_material.albedo_color = Color(0.78, 0.58, 0.18)
	shell_material.metallic = 0.75
	shell.material_override = shell_material
	weapon_view.add_child(shell)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		shell,
		"position",
		Vector3(0.42, 0.18, 0.16),
		0.22
	)
	tween.tween_property(
		shell,
		"rotation_degrees",
		Vector3(220.0, 160.0, 320.0),
		0.22
	)
	tween.chain().tween_callback(shell.queue_free)

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
	_refresh_identity_visuals(true)
	current_weapon_index = 0
	_configure_class_loadout(true, true)
	_hide_spawn_menu()

func _is_scout_scope_active() -> bool:
	return (
		is_aiming
		and player_class == PlayerClass.SCOUT
		and current_weapon_index == 0
	)

func _update_aim_view() -> void:
	if not _is_local_player():
		return

	var camera: Camera3D = $Head/Camera3D as Camera3D
	if camera == null:
		return

	var target_fov: float = DEFAULT_FOV
	if is_aiming:
		target_fov = (
			SCOUT_ADS_FOV
			if _is_scout_scope_active()
			else ADS_FOV
		)

	camera.fov = lerpf(
		camera.fov,
		target_fov,
		clampf(get_process_delta_time() * 14.0, 0.0, 1.0)
	)

	if weapon_view != null:
		var target_position: Vector3 = _base_weapon_position()
		if is_aiming:
			target_position.x = 0.0
			target_position.y += 0.04
			target_position.z -= 0.08
		weapon_view.position = weapon_view.position.lerp(
			target_position,
			clampf(get_process_delta_time() * 16.0, 0.0, 1.0)
		)

	if scope_overlay != null:
		scope_overlay.visible = _is_scout_scope_active()

	if crosshair != null:
		crosshair.visible = not _is_scout_scope_active()

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
	var weapon_texture: Texture2D = (
		tex_weapon_pistol
		if is_pistol
		else tex_weapon_rifle
	)
	if weapon_texture != null:
		metal.albedo_texture = weapon_texture
	metal.albedo_color = Color(0.72, 0.74, 0.76)
	metal.roughness = 0.48

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


func _initialize_optional_client_systems() -> void:
	if not _is_local_player():
		return

	_build_audio_players()
	if radar_panel != null:
		radar_panel.visible = true

func _safe_load_audio(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("Optional audio asset missing: %s" % path)
		return null

	var resource: Resource = load(path)
	if resource is AudioStream:
		return resource as AudioStream

	push_warning("Invalid optional audio asset: %s" % path)
	return null

func _build_audio_players() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if weapon_audio != null:
		return

	rifle_fire_sound = _safe_load_audio("res://audio/rifle_fire.wav")
	pistol_fire_sound = _safe_load_audio("res://audio/pistol_fire.wav")
	dry_click_sound = _safe_load_audio("res://audio/dry_click.wav")
	reload_sound = _safe_load_audio("res://audio/reload.wav")
	footstep_sound = _safe_load_audio("res://audio/footstep.wav")
	hit_confirm_sound = _safe_load_audio("res://audio/hit_confirm.wav")
	headshot_confirm_sound = _safe_load_audio(
		"res://audio/headshot_confirm.wav"
	)

	weapon_audio = AudioStreamPlayer.new()
	weapon_audio.volume_db = -5.0
	add_child(weapon_audio)

	reload_audio = AudioStreamPlayer.new()
	reload_audio.stream = reload_sound
	reload_audio.volume_db = -7.0
	add_child(reload_audio)

	footstep_audio = AudioStreamPlayer3D.new()
	footstep_audio.stream = footstep_sound
	footstep_audio.max_distance = 18.0
	footstep_audio.volume_db = -10.0
	add_child(footstep_audio)

	confirm_audio = AudioStreamPlayer.new()
	confirm_audio.volume_db = -8.0
	add_child(confirm_audio)

func _play_weapon_sound() -> void:
	if weapon_audio == null:
		return
	var selected_stream: AudioStream = (
		pistol_fire_sound
		if current_weapon_index == 1
		else rifle_fire_sound
	)
	if selected_stream == null:
		return
	weapon_audio.stream = selected_stream
	weapon_audio.pitch_scale = randf_range(0.96, 1.04)
	weapon_audio.play()

func _play_dry_click() -> void:
	if weapon_audio == null:
		return
	if dry_click_sound == null:
		return
	weapon_audio.stream = dry_click_sound
	weapon_audio.pitch_scale = 1.0
	weapon_audio.play()

func _update_footstep_audio(delta: float) -> void:
	if footstep_audio == null or not alive or downed or not is_on_floor():
		footstep_accumulator = 0.0
		return
	var speed: float = Vector2(velocity.x, velocity.z).length()
	if speed < 1.0:
		footstep_accumulator = 0.0
		return
	var interval: float = 0.29 if speed >= 8.0 else (0.40 if speed >= 5.0 else 0.52)
	footstep_accumulator += delta
	if footstep_accumulator >= interval:
		footstep_accumulator = 0.0
		footstep_audio.pitch_scale = randf_range(0.92, 1.08)
		footstep_audio.play()

func _play_confirm_sound(headshot: bool) -> void:
	if confirm_audio == null:
		return
	var selected_stream: AudioStream = (
		headshot_confirm_sound
		if headshot
		else hit_confirm_sound
	)
	if selected_stream == null:
		return
	confirm_audio.stream = selected_stream
	confirm_audio.play()

func _build_hud() -> void:
	var layer := CanvasLayer.new(); add_child(layer)
	hud = Label.new(); hud.position = Vector2(18, 18); hud.add_theme_font_size_override("font_size", 18); layer.add_child(hud)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.position = Vector2(638, 350)
	crosshair.add_theme_font_size_override("font_size", 24)
	layer.add_child(crosshair)

	scope_overlay = Control.new()
	scope_overlay.name = "ScoutScopeOverlay"
	scope_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scope_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scope_overlay.visible = false
	layer.add_child(scope_overlay)

	var scope_top := ColorRect.new()
	scope_top.color = Color(0.0, 0.0, 0.0, 0.88)
	scope_top.position = Vector2(0, 0)
	scope_top.size = Vector2(1280, 205)
	scope_overlay.add_child(scope_top)

	var scope_bottom := ColorRect.new()
	scope_bottom.color = Color(0.0, 0.0, 0.0, 0.88)
	scope_bottom.position = Vector2(0, 515)
	scope_bottom.size = Vector2(1280, 205)
	scope_overlay.add_child(scope_bottom)

	var scope_left := ColorRect.new()
	scope_left.color = Color(0.0, 0.0, 0.0, 0.88)
	scope_left.position = Vector2(0, 205)
	scope_left.size = Vector2(435, 310)
	scope_overlay.add_child(scope_left)

	var scope_right := ColorRect.new()
	scope_right.color = Color(0.0, 0.0, 0.0, 0.88)
	scope_right.position = Vector2(845, 205)
	scope_right.size = Vector2(435, 310)
	scope_overlay.add_child(scope_right)

	scope_reticle = Label.new()
	scope_reticle.text = "───┼───\n   │"
	scope_reticle.position = Vector2(566, 314)
	scope_reticle.add_theme_font_size_override("font_size", 34)
	scope_overlay.add_child(scope_reticle)

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

	compass_label = Label.new()
	compass_label.position = Vector2(430, 42)
	compass_label.custom_minimum_size = Vector2(420, 30)
	compass_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	compass_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(compass_label)

	medal_icon = TextureRect.new()
	medal_icon.position = Vector2(596, 115)
	medal_icon.size = Vector2(88, 88)
	medal_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	medal_icon.visible = false
	layer.add_child(medal_icon)

	medal_label = Label.new()
	medal_label.position = Vector2(520, 202)
	medal_label.custom_minimum_size = Vector2(240, 30)
	medal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	medal_label.add_theme_font_size_override("font_size", 22)
	medal_label.visible = false
	layer.add_child(medal_label)

	spawn_shield_icon = TextureRect.new()
	spawn_shield_icon.position = Vector2(18, 175)
	spawn_shield_icon.size = Vector2(56, 56)
	spawn_shield_icon.visible = false
	layer.add_child(spawn_shield_icon)

	muzzle_flash_sprite = TextureRect.new()
	muzzle_flash_sprite.position = Vector2(603, 319)
	muzzle_flash_sprite.size = Vector2(74, 74)
	muzzle_flash_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	muzzle_flash_sprite.visible = false
	layer.add_child(muzzle_flash_sprite)

	for direction_name in ["FRONT", "RIGHT", "REAR", "LEFT"]:
		var arrow := Label.new()
		arrow.add_theme_font_size_override("font_size", 34)
		arrow.visible = false
		layer.add_child(arrow)
		directional_damage_labels[direction_name] = arrow

	directional_damage_labels["FRONT"].text = "▼"
	directional_damage_labels["FRONT"].position = Vector2(629, 105)
	directional_damage_labels["RIGHT"].text = "◀"
	directional_damage_labels["RIGHT"].position = Vector2(1130, 345)
	directional_damage_labels["REAR"].text = "▲"
	directional_damage_labels["REAR"].position = Vector2(629, 610)
	directional_damage_labels["LEFT"].text = "▶"
	directional_damage_labels["LEFT"].position = Vector2(115, 345)

	objective_progress_text = Label.new()
	objective_progress_text.position = Vector2(430, 625)
	objective_progress_text.custom_minimum_size = Vector2(420, 28)
	objective_progress_text.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	objective_progress_text.add_theme_font_size_override(
		"font_size",
		18
	)
	layer.add_child(objective_progress_text)

	objective_progress_bar = ProgressBar.new()
	objective_progress_bar.position = Vector2(430, 655)
	objective_progress_bar.size = Vector2(420, 24)
	objective_progress_bar.min_value = 0.0
	objective_progress_bar.max_value = 100.0
	objective_progress_bar.show_percentage = true
	layer.add_child(objective_progress_bar)

	stamina_bar = ProgressBar.new()
	stamina_bar.position = Vector2(18, 148)
	stamina_bar.size = Vector2(230, 18)
	stamina_bar.min_value = 0.0
	stamina_bar.max_value = MAX_STAMINA
	stamina_bar.value = MAX_STAMINA
	stamina_bar.show_percentage = false
	layer.add_child(stamina_bar)

	operations_label = Label.new()
	operations_label.position = Vector2(420, 92)
	operations_label.custom_minimum_size = Vector2(440, 28)
	operations_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	operations_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(operations_label)

	class_mode_label = Label.new()
	class_mode_label.position = Vector2(445, 150)
	class_mode_label.custom_minimum_size = Vector2(390, 26)
	class_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_mode_label.add_theme_font_size_override("font_size", 18)
	layer.add_child(class_mode_label)

	mission_banner = Label.new()
	mission_banner.position = Vector2(330, 238)
	mission_banner.custom_minimum_size = Vector2(620, 42)
	mission_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_banner.add_theme_font_size_override("font_size", 25)
	mission_banner.visible = false
	layer.add_child(mission_banner)

	rank_progress_label = Label.new()
	rank_progress_label.position = Vector2(18, 248)
	rank_progress_label.custom_minimum_size = Vector2(390, 26)
	rank_progress_label.add_theme_font_size_override(
		"font_size",
		18
	)
	layer.add_child(rank_progress_label)

	command_post_bar = ProgressBar.new()
	command_post_bar.position = Vector2(440, 122)
	command_post_bar.size = Vector2(400, 18)
	command_post_bar.min_value = -100.0
	command_post_bar.max_value = 100.0
	command_post_bar.value = 0.0
	command_post_bar.show_percentage = false
	layer.add_child(command_post_bar)

	suppression_overlay = ColorRect.new()
	suppression_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	suppression_overlay.color = Color(0.55, 0.05, 0.02, 0.16)
	suppression_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	suppression_overlay.visible = false
	layer.add_child(suppression_overlay)

	elimination_notice = Label.new()
	elimination_notice.position = Vector2(540, 285)
	elimination_notice.custom_minimum_size = Vector2(200, 45)
	elimination_notice.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	elimination_notice.add_theme_font_size_override(
		"font_size",
		28
	)
	elimination_notice.visible = false
	layer.add_child(elimination_notice)

	damage_number = Label.new()
	damage_number.position = Vector2(555, 390)
	damage_number.custom_minimum_size = Vector2(220, 32)
	damage_number.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	damage_number.add_theme_font_size_override(
		"font_size",
		22
	)
	damage_number.visible = false
	layer.add_child(damage_number)

	tactical_indicator = Label.new()
	tactical_indicator.position = Vector2(390, 54)
	tactical_indicator.custom_minimum_size = Vector2(500, 42)
	tactical_indicator.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	tactical_indicator.add_theme_font_size_override(
		"font_size",
		22
	)
	layer.add_child(tactical_indicator)

	radar_panel = Control.new()
	radar_panel.name = "TacticalRadar"
	radar_panel.position = Vector2(1035, 480)
	radar_panel.size = Vector2(220, 220)
	radar_panel.visible = false
	layer.add_child(radar_panel)

	var radar_background := ColorRect.new()
	radar_background.color = Color(0.02, 0.04, 0.06, 0.78)
	radar_background.size = Vector2(220, 220)
	radar_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radar_panel.add_child(radar_background)

	var radar_border := Label.new()
	radar_border.text = "TACTICAL MAP\n┌──────────────┐\n│              │\n│              │\n│              │\n│      ▲       │\n│              │\n│              │\n│              │\n└──────────────┘"
	radar_border.position = Vector2(10, 4)
	radar_border.add_theme_font_size_override("font_size", 15)
	radar_panel.add_child(radar_border)

	radar_objective = Label.new()
	radar_objective.text = "◆"
	radar_objective.add_theme_font_size_override("font_size", 18)
	radar_objective.modulate = Color(1.0, 0.78, 0.12)
	radar_panel.add_child(radar_objective)

	scoreboard = Label.new()
	scoreboard.position = Vector2(210, 100)
	scoreboard.custom_minimum_size = Vector2(860, 520)
	scoreboard.add_theme_font_size_override("font_size", 17)
	scoreboard.visible = false
	layer.add_child(scoreboard)
	feed = Label.new(); feed.position = Vector2(930, 24); feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; feed.custom_minimum_size = Vector2(320, 150); layer.add_child(feed)

func _radar_position(world_position: Vector3, radius_meters: float = 42.0) -> Vector2:
	var relative: Vector3 = world_position - global_position
	relative.y = 0.0
	var local_x: float = relative.dot(global_transform.basis.x)
	var local_forward: float = relative.dot(-global_transform.basis.z)
	var scale_factor: float = 88.0 / radius_meters
	return Vector2(
		110.0 + clampf(local_x * scale_factor, -88.0, 88.0),
		110.0 - clampf(local_forward * scale_factor, -88.0, 88.0)
	)

func _get_or_create_radar_actor(actor_id: int) -> Label:
	if radar_actor_markers.has(actor_id):
		return radar_actor_markers[actor_id] as Label
	var marker := Label.new()
	marker.text = "●"
	marker.add_theme_font_size_override("font_size", 15)
	radar_panel.add_child(marker)
	radar_actor_markers[actor_id] = marker
	return marker

func _update_radar() -> void:
	if (
		radar_panel == null
		or not radar_panel.visible
		or not _is_local_player()
	):
		return

	var main_node: Node = get_parent()
	if main_node == null:
		return

	var players_variant: Variant = main_node.get("players")
	var grenades_variant: Variant = main_node.get("grenades")
	if not players_variant is Dictionary:
		return
	if not grenades_variant is Dictionary:
		return

	var objective_position: Vector3 = global_position
	if int(main_node.get("objective_stage")) == 0:
		var build_site: Node3D = main_node.get_node_or_null(
			"BridgeBuildSite"
		) as Node3D
		if build_site != null:
			objective_position = build_site.global_position
	else:
		var objective_node: Node3D = main_node.get_node_or_null(
			"Objective"
		) as Node3D
		if objective_node != null:
			objective_position = objective_node.global_position

	if radar_objective != null:
		radar_objective.position = (
			_radar_position(objective_position)
			- Vector2(7, 10)
		)

	var active_ids: Dictionary = {}
	var player_map: Dictionary = players_variant as Dictionary

	for actor_value in player_map.values():
		var actor: Node3D = actor_value as Node3D
		if actor == null or actor == self:
			continue
		if not bool(actor.get("alive")):
			continue

		var actor_id: int = int(actor.get("peer_id"))
		var same_team: bool = int(actor.get("team")) == team
		var spotted_enemy := false

		if actor.has_method("spotted_remaining_ms"):
			spotted_enemy = (
				int(actor.call("spotted_remaining_ms")) > 0
			)

		if not same_team and not spotted_enemy:
			continue

		var marker: Label = _get_or_create_radar_actor(actor_id)
		if marker == null:
			continue

		marker.position = (
			_radar_position(actor.global_position)
			- Vector2(6, 9)
		)
		marker.modulate = (
			Color(0.18, 0.72, 1.0)
			if same_team
			else Color(1.0, 0.18, 0.12)
		)
		marker.visible = true
		active_ids[actor_id] = true

	for actor_id_value in radar_actor_markers:
		var actor_id: int = int(actor_id_value)
		if active_ids.has(actor_id):
			continue
		var stale_marker: Label = (
			radar_actor_markers[actor_id] as Label
		)
		if stale_marker != null:
			stale_marker.visible = false

	for old_marker in radar_grenade_markers:
		if old_marker != null and is_instance_valid(old_marker):
			old_marker.queue_free()
	radar_grenade_markers.clear()

	var grenade_map: Dictionary = grenades_variant as Dictionary
	for grenade_value in grenade_map.values():
		var grenade_node: Node3D = grenade_value as Node3D
		if grenade_node == null:
			continue
		if int(grenade_node.get("owner_team")) == team:
			continue

		var grenade_marker := Label.new()
		grenade_marker.text = "!"
		grenade_marker.modulate = Color(1.0, 0.28, 0.05)
		grenade_marker.add_theme_font_size_override("font_size", 18)
		grenade_marker.position = (
			_radar_position(grenade_node.global_position)
			- Vector2(5, 10)
		)
		grenade_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		radar_panel.add_child(grenade_marker)
		radar_grenade_markers.append(grenade_marker)

func _update_first_person_animation(delta: float) -> void:
	if weapon_view == null or not _is_local_player():
		return
	visual_animation_time += delta
	var speed: float = Vector2(velocity.x, velocity.z).length()
	var moving: bool = speed > 0.8 and is_on_floor()
	var sprinting: bool = moving and sprint_requested and replicated_stamina > 1.0 and not aim_requested
	var target_position: Vector3 = weapon_base_position
	var target_rotation: Vector3 = weapon_base_rotation
	if moving:
		var frequency: float = 11.0 if sprinting else 7.5
		var amount: float = 0.035 if sprinting else 0.020
		target_position.x += sin(visual_animation_time * frequency) * amount
		target_position.y += absf(cos(visual_animation_time * frequency)) * amount * 0.65
		target_rotation.z += sin(visual_animation_time * frequency) * 0.018
	if sprinting:
		target_position.y -= 0.12
		target_position.z += 0.16
		target_rotation.x += 0.28
		target_rotation.z -= 0.12
	elif aim_requested:
		target_position.y += 0.02
		target_position.z -= 0.06
	else:
		target_rotation.y += sin(visual_animation_time * 1.4) * 0.008
		target_rotation.x += cos(visual_animation_time * 1.1) * 0.006
	weapon_view.position = weapon_view.position.lerp(target_position, clampf(delta * 10.0,0.0,1.0))
	weapon_view.rotation = weapon_view.rotation.lerp(target_rotation, clampf(delta * 9.0,0.0,1.0))

func _update_world_character_animation(delta: float) -> void:
	if class_accent_mesh == null:
		return

	var speed: float = Vector2(
		velocity.x,
		velocity.z
	).length()
	var animation_clock: float = (
		float(Time.get_ticks_msec()) / 1000.0
	)
	var speed_ratio: float = clampf(
		speed / SPRINT_SPEED,
		0.0,
		1.0
	)

	var target_roll := 0.0
	var target_yaw_offset := 0.0
	var target_vertical_offset := 0.0

	if alive and speed > 0.45:
		var stride_frequency: float = lerpf(
			5.5,
			9.0,
			speed_ratio
		)
		target_roll = (
			sin(animation_clock * stride_frequency)
			* lerpf(0.025, 0.075, speed_ratio)
		)
		target_yaw_offset = (
			cos(animation_clock * stride_frequency * 0.5)
			* 0.018
		)
		target_vertical_offset = (
			absf(sin(animation_clock * stride_frequency))
			* lerpf(0.008, 0.026, speed_ratio)
		)

	class_accent_mesh.rotation.z = lerpf(
		class_accent_mesh.rotation.z,
		target_roll,
		1.0 - exp(-10.0 * delta)
	)
	class_accent_mesh.rotation.y = lerpf(
		class_accent_mesh.rotation.y,
		target_yaw_offset,
		1.0 - exp(-8.0 * delta)
	)
	class_accent_mesh.position.y = lerpf(
		class_accent_mesh.position.y,
		target_vertical_offset,
		1.0 - exp(-12.0 * delta)
	)

func _update_hud() -> void:
	if hud == null:
		return

	var now: int = Time.get_ticks_msec()
	_update_objective_compass()

	if medal_label != null and now >= medal_until_ms:
		medal_label.visible = false
		if medal_icon != null:
			medal_icon.visible = false

	if spawn_shield_icon != null and now >= spawn_shield_until_ms:
		spawn_shield_icon.visible = false

	if stamina_bar != null:
		stamina_bar.value = replicated_stamina
	if suppression_overlay != null:
		suppression_overlay.visible = replicated_suppression_ms > 0

	if hit_marker != null and hit_marker.visible and now >= hit_marker_until_ms:
		hit_marker.visible = false
		hit_marker.text = "×"
		hit_marker.position = Vector2(634, 344)

	if (
		elimination_notice != null
		and elimination_notice.visible
		and now >= elimination_notice_until_ms
	):
		elimination_notice.visible = false

	if (
		damage_number != null
		and damage_number.visible
		and now >= damage_number_until_ms
	):
		damage_number.visible = false

	if damage_indicator != null and damage_indicator.visible and now >= damage_indicator_until_ms:
		damage_indicator.visible = false
		for arrow_value in directional_damage_labels.values():
			var arrow: Label = arrow_value as Label
			if arrow != null:
				arrow.visible = false

	if muzzle_flash != null and muzzle_flash.visible and now >= muzzle_flash_until_ms:
		muzzle_flash.visible = false
	if muzzle_flash_sprite != null and now >= muzzle_flash_until_ms:
		muzzle_flash_sprite.visible = false

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
	if main != null:
		protocol_status = str(main.get("protocol_message"))

	if operations_label != null and main != null:
		var post_control: int = int(main.get("command_post_control"))
		var post_state := (
			"NEUTRAL"
			if post_control < 0
			else (
				"ATTACKERS"
				if post_control == 0
				else "DEFENDERS"
			)
		)
		if bool(main.get("command_post_contested")):
			post_state = "CONTESTED"
		var overtime_suffix := (
			" · OVERTIME"
			if bool(main.get("overtime_active"))
			else ""
		)
		var depot_control: int = int(
			main.get("supply_depot_control")
		)
		var depot_status := "DEPOT N"
		if bool(main.get("supply_depot_contested")):
			depot_status = "DEPOT X"
		elif depot_control == 0:
			depot_status = "DEPOT ATK"
		elif depot_control == 1:
			depot_status = "DEPOT DEF"

		var gun_status := "GUNS OFFLINE"
		if post_control == 0:
			gun_status = "GUNS ATK"
		elif post_control == 1:
			gun_status = "GUNS DEF"

		operations_label.text = (
			"ATK %d · CP %s · %s · %s · DEF %d%s"
			% [
				int(main.get("attacker_tickets")),
				post_state,
				gun_status,
				depot_status,
				int(main.get("defender_tickets")),
				overtime_suffix
			]
		)
	if command_post_bar != null and main != null:
		command_post_bar.value = float(
			main.get("command_post_progress")
		)

	if rank_progress_label != null:
		rank_progress_label.text = rank_progress_text()

	if mission_banner != null and main != null:
		var banner_until: int = int(
			main.get("mission_banner_until_ms")
		)
		mission_banner.visible = now < banner_until
		if mission_banner.visible:
			mission_banner.text = str(
				main.get("mission_banner_text")
			)

	if class_mode_label != null:
		var ability_state := "READY" if replicated_ability_cooldown_ms <= 0 else "%.1fs" % (float(replicated_ability_cooldown_ms) / 1000.0)
		var active_mode := ""
		if replicated_heavy_fire_ms > 0:
			active_mode = " · HEAVY FIRE %.1fs" % (float(replicated_heavy_fire_ms) / 1000.0)
		class_mode_label.text = "%s [%s]%s" % [_ability_name(), ability_state, active_mode]

	var minutes := int(main.get("match_time_remaining")) / 60
	var seconds := int(main.get("match_time_remaining")) % 60
	var stance_text := "CROUCHED" if is_crouching else "STANDING"
	var combat_state := (
		"SUPPRESSED"
		if replicated_suppression_ms > 0
		else "READY"
	)
	var life_text := "DOWNED" if downed else (
		"ALIVE"
		if alive
		else "RESPAWN IN %.1f · F cycles teammate" % float(
			main.get("spawn_wave_remaining")
		)
	)
	var objective_text: String = str(main.call("objective_status_text"))

	var active_target := Vector3.ZERO
	if int(main.get("objective_stage")) == 0:
		var build_site: Node3D = main.get_node_or_null(
			"BridgeBuildSite"
		) as Node3D
		if build_site != null:
			active_target = build_site.global_position
	else:
		var objective_node: Node3D = main.get_node_or_null(
			"Objective"
		) as Node3D
		if objective_node != null:
			active_target = objective_node.global_position

	var to_objective: Vector3 = active_target - global_position
	to_objective.y = 0.0
	var objective_distance: float = to_objective.length()
	var direction_name := "AHEAD"

	if objective_distance > 0.01:
		to_objective = to_objective.normalized()
		var forward: Vector3 = -global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right: Vector3 = global_transform.basis.x
		right.y = 0.0
		right = right.normalized()

		var forward_dot: float = forward.dot(to_objective)
		var right_dot: float = right.dot(to_objective)
		if absf(right_dot) > absf(forward_dot):
			direction_name = (
				"RIGHT" if right_dot > 0.0 else "LEFT"
			)
		elif forward_dot < 0.0:
			direction_name = "BEHIND"

	var grenade_warning := ""
	var nearest_grenade_distance := INF
	var grenade_map: Dictionary = main.get("grenades")
	for grenade_value in grenade_map.values():
		var grenade: Node3D = grenade_value as Node3D
		if grenade == null:
			continue
		if int(grenade.get("owner_team")) == team:
			continue
		var grenade_distance: float = global_position.distance_to(
			grenade.global_position
		)
		nearest_grenade_distance = minf(
			nearest_grenade_distance,
			grenade_distance
		)

	if nearest_grenade_distance <= 7.5:
		grenade_warning = "  ·  GRENADE %.1fm!" % (
			nearest_grenade_distance
		)

	if tactical_indicator != null:
		tactical_indicator.text = (
			"OBJECTIVE %s · %.0fm%s"
			% [
				direction_name,
				objective_distance,
				grenade_warning
			]
		)

	var progress_value := 0.0
	var progress_title := "OBJECTIVE"
	var current_stage: int = int(main.get("objective_stage"))
	if current_stage == 0:
		progress_title = "BRIDGE CONSTRUCTION"
		progress_value = (
			100.0
			* float(main.get("bridge_progress"))
			/ float(maxi(1, int(main.get("bridge_required"))))
		)
	elif bool(main.get("dynamite_armed")):
		progress_title = "DEFUSE PROGRESS"
		progress_value = (
			100.0
			* float(main.get("defuse_progress"))
			/ float(maxi(1, int(main.get("defuse_required"))))
		)
	else:
		progress_title = "BUNKER DAMAGE"
		progress_value = 100.0 - float(
			main.get("objective_health")
		)

	if objective_progress_bar != null:
		objective_progress_bar.value = clampf(
			progress_value,
			0.0,
			100.0
		)
	if objective_progress_text != null:
		objective_progress_text.text = progress_title

	var interaction_prompt: String = str(
		main.call("interaction_prompt_for", self)
	)
	if interaction_prompt == "":
		interaction_prompt = "Follow the active objective marker"
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
	hud.text = "%s | %s | %s\n%s · %s · Stamina %d%%\nHP %d  Ammo %d/%d  %s [%d/%d]  Grenades %d  Smoke %d  %s\nLoadout: %s + Service Pistol\n%s\n%s  Time %02d:%02d\nClass: %s  XP %d (%s)  Q: %s [%s]  RMB: aim/zoom  G: grenade  X: switch  E: interact  M: spawn menu  MMB: ping  B: smoke  C: barricade  V: rally  F: freecam\nBlue=Attackers  Red=Defenders  Accent=Class" % [
		player_name,
		"Attackers" if team == 0 else "Defenders",
		"%s · %s" % [life_text, stance_text],
		protocol_status,
		combat_state,
		int(round(replicated_stamina)),
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
		replicated_smoke_grenades,
		protection_text,
		primary_name,
		interaction_prompt,
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
