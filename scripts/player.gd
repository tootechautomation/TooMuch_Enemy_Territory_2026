extends CharacterBody3D

const ExternalAssetRegistryScript = preload(
	"res://scripts/assets/asset_registry.gd"
)
const ExternalAssetLoaderScript = preload(
	"res://scripts/assets/external_asset_loader.gd"
)
const HumanoidAnimationControllerScript = preload(
	"res://scripts/characters/humanoid_animation_controller.gd"
)
const ExternalAssetValidatorScript = preload(
	"res://scripts/assets/external_asset_validator.gd"
)
const RealAssetAdapterScript = preload(
	"res://scripts/assets/real_asset_adapter.gd"
)

const RadarCompassScript = preload("res://scripts/radar_compass.gd")
const FirstPersonWeaponFidelityScript = preload(
	"res://scripts/visuals/first_person_weapon_fidelity.gd"
)
const ThirdPersonPoseFidelityScript = preload(
	"res://scripts/visuals/third_person_pose_fidelity.gd"
)
const CombatCameraFeedbackScript = preload(
	"res://scripts/visuals/combat_camera_feedback.gd"
)
const TeamIdentityHUDScript = preload(
	"res://scripts/visuals/team_identity_hud.gd"
)
const WeaponHandlingFeedbackScript = preload(
	"res://scripts/visuals/weapon_handling_feedback.gd"
)
const FirstPersonArmsFallbackScript = preload(
	"res://scripts/visuals/first_person_arms_fallback.gd"
)


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
var tex_uniform_normal: Texture2D
var tex_uniform_roughness: Texture2D
var tex_weapon_rifle: Texture2D
var tex_weapon_pistol: Texture2D
var tex_medal_elimination: Texture2D
var tex_medal_headshot: Texture2D
var tex_objective_marker: Texture2D
var tex_spawn_shield: Texture2D
var tex_muzzle_flash_ui: Texture2D
var fp_rifle_scene: PackedScene
var fp_pistol_scene: PackedScene
var allied_character_scene: PackedScene
var axis_character_scene: PackedScene
var external_character_model: Node3D
var external_character_animator: AnimationPlayer
var external_character_animation: StringName = &""
var external_animation_controller
var external_weapon_socket: Node3D
var external_model_loaded := false
var external_weapon_model: Node3D
var external_weapon_index := -1
var external_weapon_team := -1
var fp_gunmetal_albedo: Texture2D
var fp_gunmetal_normal: Texture2D
var fp_gunmetal_roughness: Texture2D
var fp_wood_albedo: Texture2D
var fp_wood_normal: Texture2D
var fp_wood_roughness: Texture2D

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
var next_resupply_time := 0
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
var bot_next_jump_ms := 0
var bot_entrance_clearance_until_ms := 0
var bot_last_recovery_ms := 0
var out_of_bounds_recovery_cooldown_ms := 0
var bot_waypoint_index := 0
var bot_route: Array[Vector3] = []
var bot_tactical_goal := Vector3.ZERO
var bot_tactical_goal_until_ms := 0
var bot_cover_refresh_ms := 0
var bot_last_threat_position := Vector3.ZERO
var bot_last_support_ms := 0
var bot_hold_position_until_ms := 0
var bot_squad_support_refresh_ms := 0
var bot_cached_squad_goal := Vector3.ZERO
var bot_active_move_goal := Vector3.ZERO
var bot_has_active_move_goal := false
var bot_hard_stuck_seconds := 0.0
var bot_last_route_distance := INF
var bot_route_stall_seconds := 0.0
var bot_emergency_nudge_ms := 0
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
var weapon_slot_teams: Array[int] = []
var current_weapon_index := 0
var hit_marker: Label
var hit_marker_until_ms := 0
var muzzle_flash: MeshInstance3D
var muzzle_flash_until_ms := 0
var visual_reload_progress := 0.0
var visual_was_reloading := false
var visual_was_on_floor := true
var visual_previous_vertical_velocity := 0.0
var visual_landing_impulse := 0.0
var active_muzzle_light: OmniLight3D
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
var wall_sweep_margin := 0.12
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
var combat_camera_feedback: Node
var team_identity_hud: Node
var footstep_accumulator := 0.0
var current_surface_name := "ground"
var landing_was_airborne := false
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
var reinforcement_death_panel: PanelContainer
var reinforcement_death_label: Label
var class_role_panel: PanelContainer
var class_role_label: Label
var class_role_prompt: Label
var rank_progress_label: Label
var tactical_map_panel: PanelContainer
var tactical_map_label: Label
var tactical_map_open := false
var tactical_map_toggle_latched := false
var scoreboard_key_held := false
var cinema_mode_enabled := false
var f6_presentation_mode: int = 2
var current_vehicle_id: int = -1
var current_vehicle_seat: int = -1
var vehicle_camera_active := false
var vehicle_hud_panel: PanelContainer
var vehicle_hud_label: Label
var vehicle_gunsight: Label
var direct_map_key_latched := false
var et_hud_root: Control
var et_status_label: Label
var et_health_label: Label
var et_stamina_label: Label
var et_rank_label: Label
var et_ammo_label: Label
var et_weapon_label: Label
var et_grenade_label: Label
var et_objective_label: Label
var et_timer_label: Label
var et_team_label: Label
var et_crosshair_ring: Label
var scoreboard_panel: PanelContainer
var hud_canvas_layer: CanvasLayer
var hud_base_resolution := Vector2(1280.0, 720.0)
var hud_last_viewport_size := Vector2.ZERO
var radar_frame_texture: Texture2D
var radar_frame_rect: Control
var et_compass_label: Label
var et_objective_distance_label: Label
var et_objective_arrow_label: Label
var et_route_hint_label: Label
var collision_debug_notice_until_ms := 0
var visual_stride_phase := 0.0
var visual_last_speed := 0.0
var visual_previous_planar_velocity := Vector3.ZERO
var visual_forward_motion := 0.0
var visual_strafe_motion := 0.0
var visual_turn_motion := 0.0
var visual_acceleration_motion := 0.0
var visual_last_body_yaw := 0.0
var visual_yaw_initialized := false
var visual_world_was_grounded := true
var visual_world_airborne := 0.0
var visual_world_vertical_motion := 0.0
var visual_world_takeoff_impulse := 0.0
var visual_world_landing_impulse := 0.0
var visual_world_stance_blend := 0.0
var visual_world_aim_blend := 0.0
var visual_world_aim_hold := 0.0
var visual_world_fire_recoil := 0.0
var visual_world_reload_progress := 0.0
var visual_world_was_reloading := false
var visual_damage_reaction := 0.0
var visual_damage_side := 1.0
var visual_revive_recovery := 0.0
var visual_incapacitation_impact := 0.0
var visual_snapshot_initialized := false
var bot_route_index := 0
var bot_route_repath_ms := 0
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
var weapon_handling_feedback: Node
var first_person_arms_fallback: Node3D
var selection_status: Label
var local_next_fire_feedback_ms := 0
var grenades_remaining := 2
var next_grenade_time := 0
var is_crouching := false
var weapon_kick_offset := 0.0
var recoil_rotation_impulse := Vector3.ZERO
var recoil_position_impulse := Vector3.ZERO
var muzzle_smoke_texture: Texture2D
var visual_weapon_heat := 0.0
var visual_last_shot_ms := 0
var camera_inertia := Vector2.ZERO
var previous_look_input := Vector2.ZERO
var profile_mouse_sensitivity := 0.0025
var profile_field_of_view := 75.0
var profile_hud_scale := 1.0

var server_logged_first_input := false

func _load_optional_scene(path: String) -> PackedScene:
	if DisplayServer.get_name() == "headless":
		return null
	if not ResourceLoader.exists(path):
		push_warning("Optional first-person model not imported: %s" % path)
		return null
	var resource: Resource = load(path)
	if resource is PackedScene:
		return resource as PackedScene
	return null

func _apply_first_person_materials(root: Node) -> void:
	var gun_material := StandardMaterial3D.new()
	gun_material.albedo_texture = fp_gunmetal_albedo
	gun_material.normal_enabled = fp_gunmetal_normal != null
	gun_material.normal_texture = fp_gunmetal_normal
	gun_material.roughness_texture = fp_gunmetal_roughness
	gun_material.roughness = 0.42
	gun_material.metallic = 0.45
	var wood_material := StandardMaterial3D.new()
	wood_material.albedo_texture = fp_wood_albedo
	wood_material.normal_enabled = fp_wood_normal != null
	wood_material.normal_texture = fp_wood_normal
	wood_material.roughness_texture = fp_wood_roughness
	wood_material.roughness = 0.72
	for child in root.get_children():
		if child is MeshInstance3D:
			var mesh_child := child as MeshInstance3D
			var lower_name: String = mesh_child.name.to_lower()
			if "stock" in lower_name or "grip" in lower_name or "fore" in lower_name:
				mesh_child.material_override = wood_material
			elif "hand" not in lower_name and "finger" not in lower_name and "sleeve" not in lower_name:
				mesh_child.material_override = gun_material
		_apply_first_person_materials(child)

func _first_person_muzzle_position() -> Vector3:
	if weapon_view != null:
		var imported_root := weapon_view.get_node_or_null(
			"ImportedFirstPersonRig"
		) as Node3D
		if imported_root != null:
			for socket_name in [
				"MuzzleSocket",
				"Muzzle",
				"BarrelEnd",
				"muzzle",
				"barrel_end"
			]:
				var socket := imported_root.find_child(
					socket_name,
					true,
					false
				) as Node3D
				if socket != null:
					return weapon_view.to_local(socket.global_position)
	if current_weapon_index == 1:
		return Vector3(0.0, 0.0, -0.45)
	match player_class:
		PlayerClass.SOLDIER:
			return Vector3(0.0, 0.0, -1.06)
		PlayerClass.MEDIC:
			return Vector3(0.0, 0.0, -0.65)
		PlayerClass.ENGINEER:
			return Vector3(0.0, 0.0, -0.73)
		PlayerClass.FIELD_OPS:
			return Vector3(0.0, 0.0, -0.91)
		PlayerClass.SCOUT:
			return Vector3(0.0, 0.0, -1.21)
	return Vector3(0.0, 0.0, -0.88)

func _first_person_flash_radius() -> float:
	if current_weapon_index == 1:
		return 0.042
	match player_class:
		PlayerClass.SOLDIER:
			return 0.070
		PlayerClass.MEDIC:
			return 0.050
		PlayerClass.ENGINEER:
			return 0.052
		PlayerClass.FIELD_OPS:
			return 0.058
		PlayerClass.SCOUT:
			return 0.055
	return 0.055

func _first_person_heat_gain() -> float:
	if current_weapon_index == 1:
		return 0.12
	match player_class:
		PlayerClass.SOLDIER:
			return 0.19
		PlayerClass.MEDIC:
			return 0.15
		PlayerClass.ENGINEER:
			return 0.14
		PlayerClass.FIELD_OPS:
			return 0.13
		PlayerClass.SCOUT:
			return 0.24
	return 0.15

func _initialize_first_person_arms_fallback() -> void:
	if not _is_local_player():
		return
	if weapon_view == null:
		return
	if first_person_arms_fallback != null:
		return

	first_person_arms_fallback = FirstPersonArmsFallbackScript.new()
	first_person_arms_fallback.name = "FirstPersonArmsFallbackController"
	add_child(first_person_arms_fallback)
	first_person_arms_fallback.call(
		"initialize",
		self,
		weapon_view
	)


func _refresh_first_person_arms_pose() -> void:
	if first_person_arms_fallback != null:
		first_person_arms_fallback.call(
			"apply_weapon_slot",
			current_weapon_index
		)


func _weapon_visual_team(slot_index: int) -> int:
	if slot_index >= 0 and slot_index < weapon_slot_teams.size():
		return clampi(weapon_slot_teams[slot_index], 0, 1)
	return team


func _build_imported_first_person_weapon(
	is_pistol: bool
) -> bool:
	var pickup_slot: int = 1 if is_pistol else 0
	var visual_team: int = _weapon_visual_team(pickup_slot)
	var selected_scene: PackedScene = (
		ExternalAssetRegistryScript.weapon_scene(
			visual_team,
			pickup_slot
		)
	)
	if selected_scene == null:
		selected_scene = fp_pistol_scene if is_pistol else fp_rifle_scene
	if selected_scene == null:
		return false

	var instance: Node = selected_scene.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return false

	# Keep camera pose and imported-file transforms on separate nodes. This lets
	# us normalize arbitrary FBX pivots/axes without flattening their hierarchy.
	var holder := Node3D.new()
	holder.name = "ImportedFirstPersonRig"
	holder.position = (
		Vector3(0.02, -0.015, 0.15)
		if is_pistol
		else Vector3(0.04, -0.025, 0.24)
	)
	weapon_view.add_child(holder)

	var imported_model := instance as Node3D
	imported_model.name = "ImportedWeaponModel"
	imported_model.position = Vector3.ZERO
	imported_model.rotation = Vector3.ZERO
	imported_model.scale = Vector3.ONE
	holder.add_child(imported_model)

	var adaptation: Dictionary = RealAssetAdapterScript.adapt_weapon(
		imported_model,
		0.38 if is_pistol else 0.92
	)
	if not bool(adaptation.get("valid", false)):
		holder.queue_free()
		return false

	var auto_rotation := Vector3(
		adaptation.get("orientation_degrees", Vector3.ZERO)
	)
	# Axis detection tells us which local axis is the weapon's length, but it
	# cannot tell which END of that axis is the muzzle. Keep per-asset forward
	# corrections explicit so one CGTrader model cannot break all the others.
	var asset_forward_yaw := 0.0
	var selected_path := selected_scene.resource_path.to_lower()

	# These are the ONLY imported assets that need an explicit muzzle-end flip.
	# Axis Walther P38 intentionally receives NO extra yaw. That restores the
	# pre-Allied-pistol-fix behavior where the P38 rendered correctly.
	if (
		"m1a1_thompson" in selected_path
		or "tt_pistol" in selected_path
	):
		asset_forward_yaw = 180.0

	# Small presentation tilt only; the large axis correction is model-specific.
	holder.rotation_degrees = auto_rotation + Vector3(
		2.0 if is_pistol else 1.5,
		asset_forward_yaw,
		-3.0 if is_pistol else -4.0
	)

	# v8.63: force the Axis Walther P38 itself to rotate 180 degrees AFTER the
	# generic FBX adaptation/holder rotation. The previous filename/yaw approach
	# could be cancelled by the P38 FBX's authored axis correction. Applying the
	# flip to ImportedWeaponModel guarantees that only the P38 mesh reverses.

	_apply_first_person_materials(imported_model)

	muzzle_flash = MeshInstance3D.new()
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = _first_person_flash_radius()
	flash_mesh.height = flash_mesh.radius * 2.15
	muzzle_flash.mesh = flash_mesh
	muzzle_flash.position = _first_person_muzzle_position()
	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color(1.0, 0.70, 0.14)
	flash_material.emission_enabled = true
	flash_material.emission = Color(1.0, 0.38, 0.03)
	muzzle_flash.material_override = flash_material
	muzzle_flash.visible = false
	weapon_view.add_child(muzzle_flash)
	return true

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

func apply_local_profile_settings(settings: Dictionary) -> void:
	if not _is_local_player():
		return

	profile_mouse_sensitivity = clampf(
		float(settings.get("mouse_sensitivity", 0.0025)),
		0.0005,
		0.0100
	)
	profile_field_of_view = clampf(
		float(settings.get("field_of_view", 75.0)),
		60.0,
		110.0
	)
	profile_hud_scale = clampf(
		float(settings.get("hud_scale", 1.0)),
		0.70,
		1.40
	)
	var team_preference := int(
		settings.get("preferred_team", selected_team)
	)
	var class_preference := int(
		settings.get("preferred_class", selected_class)
	)
	var main_node: Node = get_parent()
	if main_node != null:
		var address_control = main_node.get("connection_address")
		var port_control = main_node.get("connection_port")
		if address_control != null and port_control != null:
			var preference_key := "%s:%d" % [
				str(address_control.text),
				int(port_control.value)
			]
			var preferences: Dictionary = Dictionary(
				settings.get("server_preferences", {})
			)
			if preferences.has(preference_key):
				var server_data: Dictionary = Dictionary(
					preferences[preference_key]
				)
				team_preference = int(
					server_data.get("team", team_preference)
				)
				class_preference = int(
					server_data.get("class", class_preference)
				)

	selected_team = clampi(team_preference, 0, 1)
	selected_class = clampi(class_preference, 0, 4)

	var camera: Camera3D = get_node_or_null(
		"Head/Camera3D"
	) as Camera3D
	if camera != null and not is_aiming:
		camera.fov = profile_field_of_view

	_apply_resolution_safe_hud()
	_update_selection_status()

func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		weapon_handling_feedback = WeaponHandlingFeedbackScript.new()
		weapon_handling_feedback.name = "WeaponHandlingFeedback"
		add_child(weapon_handling_feedback)
		weapon_handling_feedback.call("initialize", self)

		call_deferred("_initialize_first_person_arms_fallback")

	safe_margin = 0.08
	max_slides = 8
	floor_snap_length = 0.35
	floor_stop_on_slope = true
	if DisplayServer.get_name() != "headless":
		tex_uniform_attackers = _load_optional_texture(
			"res://assets/cc0/ambientcg/Fabric083/Fabric083_Color.jpg"
		)
		tex_uniform_defenders = _load_optional_texture(
			"res://assets/cc0/ambientcg/Fabric083/Fabric083_Color.jpg"
		)
		tex_uniform_normal = _load_optional_texture(
			"res://assets/cc0/ambientcg/Fabric083/Fabric083_NormalGL.jpg"
		)
		tex_uniform_roughness = _load_optional_texture(
			"res://assets/cc0/ambientcg/Fabric083/Fabric083_Roughness.jpg"
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
		fp_rifle_scene = _load_optional_scene(
			"res://assets/models/fp_service_rifle.glb"
		)
		fp_pistol_scene = _load_optional_scene(
			"res://assets/models/fp_service_pistol.glb"
		)
		allied_character_scene = _load_optional_scene(
			"res://assets/models/allied_soldier.glb"
		)
		axis_character_scene = _load_optional_scene(
			"res://assets/models/axis_soldier.glb"
		)
		fp_gunmetal_albedo = _load_optional_texture("res://assets/pbr/gunmetal_albedo.png")
		fp_gunmetal_normal = _load_optional_texture("res://assets/pbr/gunmetal_normal.png")
		fp_gunmetal_roughness = _load_optional_texture("res://assets/pbr/gunmetal_roughness.png")
		fp_wood_albedo = _load_optional_texture("res://assets/pbr/wood_albedo.png")
		fp_wood_normal = _load_optional_texture("res://assets/pbr/wood_normal.png")
		fp_wood_roughness = _load_optional_texture("res://assets/pbr/wood_roughness.png")
		muzzle_smoke_texture = _load_optional_texture("res://assets/fx/muzzle_smoke.png")

	_initialize_loadout()
	if _is_local_player():
		var main_node: Node = get_parent()
		if (
			main_node != null
			and main_node.has_method(
				"get_local_profile_settings"
			)
		):
			apply_local_profile_settings(
				Dictionary(
					main_node.call(
						"get_local_profile_settings"
					)
				)
			)
	if is_bot and not bot_role_initialized:
		bot_squad_role = posmod(peer_id, 4)
		bot_role_initialized = true
	bot_last_position = global_position
	_build_spotted_marker()
	_build_identity_visuals()
	_build_external_character_model()
	_refresh_identity_visuals(true)
	_apply_first_person_body_visibility()
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

func _input(event: InputEvent) -> void:
	if not _is_local_player():
		return
	if DisplayServer.get_name() == "headless":
		return
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	var key_code: Key = (
		key_event.physical_keycode
		if key_event.physical_keycode != 0
		else key_event.keycode
	)

	# Dedicated vehicle E interaction. This bypasses the generic interaction
	# hold timer, which made vehicle entry unreliable when UI/gameplay focus
	# changed. The server still validates range and seat availability.
	if (
		key_code == KEY_E
		and key_event.pressed
		and not key_event.echo
	):
		var main_node: Node = get_parent()
		if (
			main_node != null
			and main_node.has_method("request_vehicle_interact")
		):
			main_node.request_vehicle_interact.rpc_id(1)
			get_viewport().set_input_as_handled()
			return

	# TAB is a hold-to-view scoreboard control. Use _input rather than only
	# _unhandled_input because focused menus/Controls may consume Tab for focus.
	if key_code == KEY_TAB:
		scoreboard_key_held = key_event.pressed
		get_viewport().set_input_as_handled()
		return

	# F6: Cinema -> Low/Laptop -> Balanced -> High -> Cinema.
	if key_code == KEY_F6 and key_event.pressed and not key_event.echo:
		f6_presentation_mode = (f6_presentation_mode + 1) % 4
		var main_node: Node = get_parent()

		if f6_presentation_mode == 0:
			cinema_mode_enabled = true
			_apply_cinema_mode_visibility()
			if main_node != null and main_node.has_method("set_local_cinema_mode"):
				main_node.call("set_local_cinema_mode", true)
			if selection_status != null:
				selection_status.text = "CINEMA MODE · F6 LOW/LAPTOP"
		else:
			cinema_mode_enabled = false
			_apply_cinema_mode_visibility()
			if main_node != null and main_node.has_method("set_local_cinema_mode"):
				main_node.call("set_local_cinema_mode", false)

			var quality_preset: int = f6_presentation_mode - 1
			if main_node != null:
				var quality_value: Variant = main_node.get("visual_quality_manager")
				if quality_value != null:
					var quality_manager: Node = quality_value as Node
					if quality_manager != null:
						quality_manager.call("set_quality", quality_preset)

			if selection_status != null:
				var mode_name: String = "LOW / LAPTOP"
				if quality_preset == 1:
					mode_name = "BALANCED"
				elif quality_preset == 2:
					mode_name = "HIGH"
				selection_status.text = "VIDEO %s · F6 NEXT MODE" % mode_name

		get_viewport().set_input_as_handled()
		return


func _unhandled_input(event: InputEvent) -> void:
	if not _is_local_player():
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		var key_code: Key = (
			key_event.physical_keycode
			if key_event.physical_keycode != 0
			else key_event.keycode
		)

		if (
			key_code == KEY_K
			and key_event.pressed
			and not key_event.echo
		):
			_set_tactical_map_open(not tactical_map_open)
			get_viewport().set_input_as_handled()


	if event is InputEventMouseMotion and alive and not downed:
		rotation.y -= event.relative.x * profile_mouse_sensitivity
		pitch = clampf(
			pitch - event.relative.y * profile_mouse_sensitivity,
			-1.35,
			1.35
		)
		$Head.rotation.x = pitch

	if event.is_action_pressed("spectator_next") and not alive:
		_cycle_spectator_target()

	if event.is_action_pressed("ui_cancel"):
		if tactical_map_open:
			_set_tactical_map_open(false)
			return
		if spawn_menu_open and has_deployed:
			_hide_spawn_menu()
			return
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and current_vehicle_id >= 0:
		if _server_lock_to_vehicle():
			return
		# Invalid/stale occupancy must not freeze normal infantry movement.
		current_vehicle_id = -1
		current_vehicle_seat = -1
		velocity = Vector3.ZERO
		var recovery_collision := $CollisionShape3D as CollisionShape3D
		if recovery_collision != null:
			recovery_collision.set_deferred("disabled", false)
		visible = true

	if multiplayer.is_server() and is_bot:
		_server_bot_tick(delta)
		return

	if _is_local_player():
		_poll_spawn_menu_toggle()
		_collect_and_send_input()
		_update_spectator_camera()
		_update_vehicle_camera()
		_update_hud()
		_update_vehicle_hud()
		_enforce_vehicle_first_person_visibility()
		_update_class_role_hud()
		_update_reinforcement_death_panel()
		_apply_cinema_mode_visibility()
		_update_combat_camera_feedback(delta)
		_update_team_identity_hud()
		_apply_first_person_body_visibility()
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

func _set_tactical_map_open(open_value: bool) -> void:
	tactical_map_open = open_value
	if tactical_map_panel != null:
		tactical_map_panel.visible = tactical_map_open

	if tactical_map_open:
		if spawn_menu_open and has_deployed:
			_hide_spawn_menu()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if spawn_menu_open
			else Input.MOUSE_MODE_CAPTURED
	)

func _poll_spawn_menu_toggle() -> void:
	var map_pressed: bool = Input.is_action_pressed(
		"tactical_map"
	)
	if map_pressed and not tactical_map_toggle_latched:
		tactical_map_toggle_latched = true
		# Physical K is handled in _unhandled_input. This fallback supports
		# remapped inputs and controllers only.
		if not Input.is_physical_key_pressed(KEY_K):
			_set_tactical_map_open(not tactical_map_open)
	elif not map_pressed:
		tactical_map_toggle_latched = false

	var menu_pressed: bool = Input.is_action_pressed(
		"spawn_menu"
	)
	if menu_pressed and not menu_toggle_latched:
		menu_toggle_latched = true

		# Opening class selection always dismisses the tactical map.
		if tactical_map_open:
			_set_tactical_map_open(false)

		if spawn_menu_open:
			if has_deployed:
				_hide_spawn_menu()
		else:
			_show_spawn_menu()
	elif not menu_pressed:
		menu_toggle_latched = false

func _collect_and_send_input() -> void:
	if spawn_menu_open or tactical_map_open:
		is_aiming = false
		_update_aim_view()
		return
	if not alive:
		is_aiming = false
		_update_aim_view()
		return

	local_sequence += 1

	if current_vehicle_id >= 0:
		var vehicle_move := Input.get_vector(
			"move_left",
			"move_right",
			"move_forward",
			"move_back"
		)
		var vehicle_throttle := -vehicle_move.y
		var vehicle_steering := vehicle_move.x
		var vehicle_pitch := 0.0

		if Input.is_action_pressed("jump"):
			vehicle_pitch = -1.0
		elif Input.is_action_pressed("crouch"):
			vehicle_pitch = 1.0

		var vehicle_main := get_parent()
		if vehicle_main != null:
			if current_vehicle_seat == 0:
				vehicle_main.submit_vehicle_input.rpc_id(
					1,
					multiplayer.get_unique_id(),
					current_vehicle_id,
					vehicle_throttle,
					vehicle_steering,
					vehicle_pitch,
					Input.is_action_pressed("fire")
				)
			else:
				var gunner_yaw := vehicle_steering
				vehicle_main.submit_vehicle_gunner_input.rpc_id(
					1,
					current_vehicle_id,
					gunner_yaw,
					Input.is_action_pressed("fire")
				)

		is_aiming = false
		_update_aim_view()

		# E enter/exit is handled in raw _input() by the dedicated vehicle RPC.
		interact_accumulator = 0.0
		return

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

func _server_forward_wall_probe(
	horizontal_motion: Vector3
) -> float:
	if horizontal_motion.length_squared() <= 0.000001:
		return 1.0

	var direction := horizontal_motion.normalized()
	var probe_distance := horizontal_motion.length() + 0.48
	var space_state := get_world_3d().direct_space_state
	var minimum_fraction := 1.0

	var probe_heights: Array[float] = [
		0.35,
		0.95,
		1.45
	]
	for probe_height: float in probe_heights:
		var origin: Vector3 = (
			global_position
			+ Vector3.UP * float(probe_height)
		)
		var query := PhysicsRayQueryParameters3D.create(
			origin,
			origin + direction * probe_distance
		)
		query.exclude = [self]
		query.collision_mask = 1
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var hit := space_state.intersect_ray(query)
		if hit.is_empty():
			continue

		var hit_position := Vector3(
			hit.get("position", origin)
		)
		var distance: float = origin.distance_to(
			hit_position
		)
		var safe_distance := maxf(0.0, distance - 0.38)
		minimum_fraction = minf(
			minimum_fraction,
			clampf(
				safe_distance
				/ maxf(horizontal_motion.length(), 0.001),
				0.0,
				1.0
			)
		)

	return minimum_fraction

func _server_wall_safety_sweep(
	horizontal_motion: Vector3
) -> Vector3:
	if horizontal_motion.length_squared() <= 0.000001:
		return horizontal_motion

	var query := PhysicsShapeQueryParameters3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	query.shape = capsule
	query.transform = Transform3D(
		global_transform.basis,
		global_position + Vector3.UP * 0.86
	)
	query.motion = horizontal_motion
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [self]

	var cast_result: Array = (
		get_world_3d().direct_space_state.cast_motion(query)
	)
	if cast_result.size() < 2:
		return horizontal_motion

	var safe_fraction := clampf(
		float(cast_result[0]) - wall_sweep_margin,
		0.0,
		1.0
	)
	return horizontal_motion * safe_fraction

func _server_simulate(delta: float) -> void:
	_server_check_out_of_bounds_recovery()
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

	var intended_horizontal := Vector3(
		velocity.x,
		0.0,
		velocity.z
	) * delta
	var safe_horizontal := _server_wall_safety_sweep(
		intended_horizontal
	)
	if intended_horizontal.length_squared() > 0.000001:
		var sweep_ratio := clampf(
			safe_horizontal.length()
			/ intended_horizontal.length(),
			0.0,
			1.0
		)
		var probe_ratio := _server_forward_wall_probe(
			intended_horizontal
		)
		var movement_ratio := minf(
			sweep_ratio,
			probe_ratio
		)
		velocity.x *= movement_ratio
		velocity.z *= movement_ratio

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
	var previous_health: int = health
	var previous_alive: bool = alive
	var previous_downed: bool = downed
	target_position = pos; target_yaw = yaw; target_pitch = head_pitch
	if _is_local_player(): global_position = pos
	health = hp
	alive = is_alive
	downed = is_downed
	if visual_snapshot_initialized:
		if hp < previous_health and previous_alive:
			_register_visual_damage(previous_health - hp, peer_id + hp)
		if not previous_downed and is_downed:
			visual_incapacitation_impact = 1.0
		elif previous_downed and not is_downed and is_alive:
			_register_visual_revive()
	else:
		visual_snapshot_initialized = true
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
	_apply_first_person_body_visibility()

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
		weapon_slot_teams = [team, team]

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

	if weapon_slot_teams.size() != weapon_slots.size():
		weapon_slot_teams = [team, team]

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
	if DisplayServer.get_name() != "headless":
		_refresh_external_weapon_model()
	_refresh_first_person_arms_pose()

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

func server_equip_battlefield_weapon(
	slot_index: int,
	resource_path: String,
	source_team: int,
	picked_magazine: int,
	picked_reserve: int
) -> bool:
	if not multiplayer.is_server() or not alive or downed:
		return false
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return false
	if not ResourceLoader.exists(resource_path):
		return false

	var loaded: Resource = load(resource_path)
	if loaded == null:
		return false

	_store_current_weapon_ammo()

	weapon_slots[slot_index] = loaded
	weapon_slot_teams[slot_index] = clampi(source_team, 0, 1)

	var max_mag: int = _resource_int(loaded, "magazine_size", 30)
	var max_reserve: int = _resource_int(loaded, "reserve_ammo", 120)
	weapon_magazines[slot_index] = clampi(picked_magazine, 0, max_mag)
	weapon_reserves[slot_index] = clampi(picked_reserve, 0, max_reserve)

	_apply_weapon_index(slot_index, false)

	confirm_battlefield_weapon_pickup.rpc_id(
		peer_id,
		slot_index,
		resource_path,
		weapon_slot_teams[slot_index],
		weapon_magazines[slot_index],
		weapon_reserves[slot_index]
	)
	return true


func server_receive_resupply() -> bool:
	if not multiplayer.is_server() or not alive or downed:
		return false

	var now: int = Time.get_ticks_msec()
	if now < next_resupply_time:
		return false

	if current_weapon_index < 0 or current_weapon_index >= weapon_slots.size():
		return false

	_store_current_weapon_ammo()

	var current_weapon: Resource = weapon_slots[current_weapon_index] as Resource
	var max_reserve: int = _resource_int(
		current_weapon,
		"reserve_ammo",
		120
	)
	var magazine_size: int = _resource_int(
		current_weapon,
		"magazine_size",
		30
	)

	# Each station use grants roughly two magazines worth of reserve ammunition.
	var old_reserve: int = weapon_reserves[current_weapon_index]
	var ammo_grant: int = maxi(12, magazine_size * 2)
	var new_reserve: int = mini(
		max_reserve,
		old_reserve + ammo_grant
	)

	var changed: bool = new_reserve > old_reserve

	if changed:
		weapon_reserves[current_weapon_index] = new_reserve
		reserve_ammo = new_reserve

	var old_grenades: int = grenades_remaining
	var old_smoke: int = smoke_grenades

	grenades_remaining = mini(2, grenades_remaining + 1)
	smoke_grenades = mini(1, smoke_grenades + 1)

	if grenades_remaining != old_grenades or smoke_grenades != old_smoke:
		changed = true

	if not changed:
		return false

	next_resupply_time = now + 8000

	confirm_station_resupply.rpc_id(
		peer_id,
		current_weapon_index,
		new_reserve,
		new_reserve - old_reserve,
		grenades_remaining,
		smoke_grenades
	)
	return true


@rpc("authority", "call_remote", "reliable")
func confirm_station_resupply(
	slot_index: int,
	new_reserve: int,
	ammo_added: int,
	new_grenades: int,
	new_smoke: int
) -> void:
	if not _is_local_player():
		return

	if slot_index >= 0 and slot_index < weapon_reserves.size():
		weapon_reserves[slot_index] = new_reserve
	if slot_index == current_weapon_index:
		reserve_ammo = new_reserve

	grenades_remaining = new_grenades
	smoke_grenades = new_smoke

	if selection_status != null:
		var parts: Array[String] = []
		if ammo_added > 0:
			parts.append("AMMO +%d" % ammo_added)
		if new_grenades > 0:
			parts.append("GRENADES %d/2" % new_grenades)
		if new_smoke > 0:
			parts.append("SMOKE %d/1" % new_smoke)
		selection_status.text = "RESUPPLIED · " + " · ".join(parts)


func server_add_battlefield_ammo(
	amount: int,
	slot_index: int = -1
) -> bool:
	if not multiplayer.is_server() or not alive or downed:
		return false

	var target_slot: int = (
		current_weapon_index
		if slot_index < 0
		else slot_index
	)
	if target_slot < 0 or target_slot >= weapon_slots.size():
		return false

	_store_current_weapon_ammo()

	var max_reserve: int = _resource_int(
		weapon_slots[target_slot],
		"reserve_ammo",
		120
	)
	var old_reserve: int = weapon_reserves[target_slot]
	var new_reserve: int = mini(
		max_reserve,
		old_reserve + maxi(0, amount)
	)
	if new_reserve <= old_reserve:
		return false

	weapon_reserves[target_slot] = new_reserve
	if target_slot == current_weapon_index:
		reserve_ammo = new_reserve

	confirm_battlefield_ammo_pickup.rpc_id(
		peer_id,
		target_slot,
		new_reserve,
		new_reserve - old_reserve
	)
	return true


func server_absorb_matching_dropped_weapon(
	slot_index: int,
	resource_path: String,
	dropped_magazine: int,
	dropped_reserve: int
) -> bool:
	if not multiplayer.is_server() or not alive or downed:
		return false
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return false

	var existing: Resource = weapon_slots[slot_index] as Resource
	if existing == null:
		return false
	if existing.resource_path != resource_path:
		return false

	# Matching dropped weapon becomes an ammo source. Include both the rounds
	# left in its magazine and its remaining reserve ammunition.
	var transferable: int = (
		maxi(0, dropped_magazine)
		+ maxi(0, dropped_reserve)
	)
	if transferable <= 0:
		return false

	return server_add_battlefield_ammo(
		transferable,
		slot_index
	)


func _battlefield_slot_name(slot_index: int) -> String:
	return "PRIMARY" if slot_index == 0 else "SECONDARY"


func _battlefield_weapon_name(
	source_team: int,
	slot_index: int
) -> String:
	if slot_index == 1:
		return "TT PISTOL" if source_team == 0 else "P38"
	return "THOMPSON" if source_team == 0 else "MP40"


@rpc("authority", "call_remote", "reliable")
func confirm_battlefield_weapon_pickup(
	slot_index: int,
	resource_path: String,
	source_team: int,
	picked_magazine: int,
	picked_reserve: int
) -> void:
	if not _is_local_player():
		return
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return
	if not ResourceLoader.exists(resource_path):
		return

	var loaded: Resource = load(resource_path)
	if loaded == null:
		return

	_store_current_weapon_ammo()
	weapon_slots[slot_index] = loaded

	if weapon_slot_teams.size() != weapon_slots.size():
		weapon_slot_teams = [team, team]
	weapon_slot_teams[slot_index] = clampi(source_team, 0, 1)

	weapon_magazines[slot_index] = picked_magazine
	weapon_reserves[slot_index] = picked_reserve

	_apply_weapon_index(slot_index, true)
	_clear_external_weapon_model()
	_refresh_external_weapon_model()

	if selection_status != null:
		selection_status.text = (
			"%s EQUIPPED · %s · %d/%d"
			% [
				_battlefield_slot_name(slot_index),
				_battlefield_weapon_name(source_team, slot_index),
				picked_magazine,
				picked_reserve
			]
		)


@rpc("authority", "call_remote", "reliable")
func confirm_battlefield_ammo_pickup(
	slot_index: int,
	new_reserve: int,
	added_amount: int
) -> void:
	if not _is_local_player():
		return
	if slot_index >= 0 and slot_index < weapon_reserves.size():
		weapon_reserves[slot_index] = new_reserve
	if slot_index == current_weapon_index:
		reserve_ammo = new_reserve

	if selection_status != null:
		selection_status.text = (
			"%s AMMO +%d · RESERVE %d"
			% [
				_battlefield_slot_name(slot_index),
				added_amount,
				new_reserve
			]
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
		hit_marker.position = Vector2(638, 346)
		hit_marker.visible = true

@rpc("authority", "call_remote", "reliable")
func confirm_headshot() -> void:
	if not _is_local_player():
		return

	_play_confirm_sound(true)
	hit_marker_until_ms = Time.get_ticks_msec() + 260
	if hit_marker != null:
		hit_marker.text = "×"
		hit_marker.position = Vector2(638, 346)
		hit_marker.visible = true

	_show_combat_medal("HEADSHOT", true)
	elimination_notice_until_ms = Time.get_ticks_msec() + 650
	if elimination_notice != null:
		elimination_notice.text = "HEADSHOT +25"
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

	_register_visual_damage(amount, attacker_id)
	health = maxi(0, health - amount)
	if attacker_id != peer_id and attacker_id != 0:
		_apply_suppression()
		if is_bot and get_parent().players.has(attacker_id):
			var threat: Node3D = (
				get_parent().players[attacker_id] as Node3D
			)
			if threat != null:
				bot_last_threat_position = threat.global_position

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
		visual_incapacitation_impact = 1.0
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

	# Drop both weapon slots plus a small ammo pouch at the death position.
	# This occurs before the player is hidden/respawned.
	var main_node: Node = get_parent()
	if (
		main_node != null
		and main_node.has_method("server_spawn_player_death_drops")
	):
		_store_current_weapon_ammo()
		main_node.call("server_spawn_player_death_drops", self)

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
	_register_visual_revive()
	health = maxi(45, int(_class_health(player_class) * 0.4))
	bleedout_finish_ms = 0
	if get_parent().players.has(reviver_id):
		get_parent().players[reviver_id].add_xp(15, "revive")
	get_parent().push_kill_feed.rpc("%s was revived" % player_name)

func server_respawn(spawn_position: Vector3) -> void:
	if not multiplayer.is_server():
		return
	# Always return to infantry state before applying spawn physics.
	current_vehicle_id = -1
	vehicle_camera_active = false
	velocity = Vector3.ZERO
	var safe_spawn_position := spawn_position + Vector3.UP * 0.35
	global_position = safe_spawn_position
	target_position = safe_spawn_position
	health = _class_health(player_class)
	stamina = MAX_STAMINA
	suppressed_until_ms = 0
	heavy_fire_until_ms = 0
	smoke_grenades = 1
	recent_damage.clear()
	previous_vertical_velocity = 0.0
	_reset_loadout_ammo()
	grenades_remaining = 2
	bot_last_threat_position = Vector3.ZERO
	bot_tactical_goal = Vector3.ZERO
	bot_tactical_goal_until_ms = 0
	bot_cover_refresh_ms = 0
	bot_hold_position_until_ms = 0
	bot_route.clear()
	bot_waypoint_index = 0
	bot_cached_squad_goal = Vector3.ZERO
	bot_squad_support_refresh_ms = 0
	bot_active_move_goal = Vector3.ZERO
	bot_has_active_move_goal = false
	bot_hard_stuck_seconds = 0.0
	bot_last_route_distance = INF
	bot_route_stall_seconds = 0.0
	bot_emergency_nudge_ms = 0
	_apply_server_crouch(false)
	_activate_spawn_protection()
	alive = true
	downed = false

	var respawn_collision: CollisionShape3D = (
		$CollisionShape3D as CollisionShape3D
	)
	if respawn_collision != null:
		respawn_collision.set_deferred("disabled", false)
	show()
	visual_damage_reaction = 0.0
	visual_revive_recovery = 0.0
	visual_incapacitation_impact = 0.0
	visual_previous_planar_velocity = Vector3.ZERO
	visual_forward_motion = 0.0
	visual_strafe_motion = 0.0
	visual_turn_motion = 0.0
	visual_acceleration_motion = 0.0
	visual_last_body_yaw = rotation.y
	visual_yaw_initialized = true
	visual_world_was_grounded = true
	visual_world_airborne = 0.0
	visual_world_vertical_motion = 0.0
	visual_world_takeoff_impulse = 0.0
	visual_world_landing_impulse = 0.0
	visual_world_stance_blend = 1.0 if is_crouching else 0.0
	visual_world_aim_blend = 0.0
	visual_world_aim_hold = 0.0
	visual_world_fire_recoil = 0.0
	visual_world_reload_progress = 0.0
	visual_world_was_reloading = false
	if tactical_map_open:
		_set_tactical_map_open(false)
	is_reloading = false
	visible = true

	var collision: CollisionShape3D = (
		$CollisionShape3D as CollisionShape3D
	)
	if collision != null:
		collision.set_deferred("disabled", false)

	velocity = Vector3.ZERO
	input_vector = Vector2.ZERO

func server_set_vehicle_state(
	vehicle_id: int,
	position: Vector3,
	seat_id: int
) -> void:
	if not multiplayer.is_server():
		return

	current_vehicle_id = vehicle_id
	current_vehicle_seat = seat_id
	velocity = Vector3.ZERO

	var collision := $CollisionShape3D as CollisionShape3D
	if collision != null:
		collision.set_deferred("disabled", vehicle_id >= 0)

	if vehicle_id >= 0:
		global_position = position
		visible = false
	else:
		current_vehicle_id = -1
		current_vehicle_seat = -1
		global_position = position + Vector3.UP * 0.20
		velocity = Vector3.ZERO
		var exit_collision := $CollisionShape3D as CollisionShape3D
		if exit_collision != null:
			exit_collision.set_deferred("disabled", false)
		visible = true


func _server_lock_to_vehicle() -> bool:
	if not multiplayer.is_server():
		return false
	if current_vehicle_id < 0:
		return false

	var main_node: Node = get_parent()
	if (
		main_node == null
		or not main_node.has_method("vehicle_seat_position")
	):
		return false

	var seat := Vector3(
		main_node.call(
			"vehicle_seat_position",
			current_vehicle_id
		)
	)
	if seat == Vector3.ZERO:
		return false

	velocity = Vector3.ZERO
	global_position = seat
	return true


func client_set_vehicle_state(
	vehicle_id: int,
	position: Vector3,
	seat_id: int
) -> void:
	current_vehicle_id = vehicle_id
	current_vehicle_seat = seat_id
	vehicle_camera_active = vehicle_id >= 0

	if vehicle_id >= 0:
		global_position = position
		if _is_local_player():
			_set_first_person_view_visible(false)
	else:
		global_position = position
		visible = true
		if _is_local_player():
			_set_first_person_view_visible(true)
			_rebuild_first_person_weapon()
			_refresh_first_person_arms_pose()


func _set_first_person_view_visible(show_value: bool) -> void:
	if weapon_view != null:
		weapon_view.visible = show_value
	if first_person_arms_fallback != null:
		first_person_arms_fallback.visible = show_value


func _enforce_vehicle_first_person_visibility() -> void:
	if not _is_local_player():
		return

	var should_show: bool = current_vehicle_id < 0

	if weapon_view != null:
		weapon_view.visible = should_show

	if first_person_arms_fallback != null:
		first_person_arms_fallback.visible = should_show

	# Imported weapon child meshes may be toggled separately by weapon-refresh
	# code. Force them off while seated.
	if not should_show and weapon_view != null:
		for child: Node in weapon_view.find_children("*", "", true):
			if child is GeometryInstance3D:
				(child as GeometryInstance3D).visible = false



func _update_vehicle_hud() -> void:
	if vehicle_hud_panel == null:
		return

	var show_hud := (
		current_vehicle_id >= 0
		and not cinema_mode_enabled
		and not scoreboard.visible
	)
	vehicle_hud_panel.visible = show_hud
	if vehicle_gunsight != null:
		vehicle_gunsight.visible = false

	if not show_hud or vehicle_hud_label == null:
		return

	var main_node := get_parent()
	if main_node == null:
		return
	var vehicles_value: Variant = main_node.get("vehicles")
	if not vehicles_value is Dictionary:
		return

	var vehicle_dict: Dictionary = vehicles_value
	var vehicle: Node = vehicle_dict.get(current_vehicle_id) as Node
	if vehicle == null:
		return

	var hp := int(vehicle.get("health"))
	var max_hp := maxi(1, int(vehicle.get("max_health")))
	var speed := int(round(float(vehicle.call("current_speed_kph"))))
	var weapon_text := "UNARMED"
	var type_id := int(vehicle.get("vehicle_type"))
	var seat_name := "DRIVER" if current_vehicle_seat == 0 else "GUNNER"

	if vehicle_gunsight != null:
		vehicle_gunsight.visible = (
			type_id == 2
			or current_vehicle_seat == 1
		)

	if type_id == 0 and current_vehicle_seat == 1:
		weapon_text = "A/D AIM · MOUSE1 MG"
	elif type_id == 1:
		weapon_text = (
			"A/D AIM · MOUSE1 CANNON"
			if current_vehicle_seat == 1
			else "W/S DRIVE · A/D STEER"
		)
	elif type_id == 2:
		weapon_text = "MOUSE1 MACHINE GUNS"

	vehicle_hud_label.text = (
		"%s · %s · HP %d/%d · %d KM/H\n%s · E EXIT"
		% [
			str(vehicle.call("display_name")),
			seat_name,
			hp,
			max_hp,
			speed,
			weapon_text
		]
	)


func _update_vehicle_camera() -> void:
	if not _is_local_player() or current_vehicle_id < 0:
		return

	var main_node := get_parent()
	if main_node == null:
		return

	var vehicles_value: Variant = main_node.get("vehicles")
	if not vehicles_value is Dictionary:
		return

	var vehicle_dict: Dictionary = vehicles_value
	if not vehicle_dict.has(current_vehicle_id):
		return

	var vehicle: Node3D = vehicle_dict.get(current_vehicle_id) as Node3D
	var camera := $Head/Camera3D as Camera3D
	if vehicle == null or camera == null:
		return

	var target: Transform3D = vehicle.call("camera_anchor")
	camera.global_transform = camera.global_transform.interpolate_with(
		target,
		0.22
	)


func server_interact_request() -> void:
	if not multiplayer.is_server() or not alive:
		return
	var now := Time.get_ticks_msec()
	if now < next_interact_time:
		return
	next_interact_time = now + 350

	var main_node: Node = get_parent()

	if (
		main_node != null
		and main_node.has_method("server_try_vehicle_interact")
		and bool(main_node.call("server_try_vehicle_interact", self))
	):
		return

	# Battlefield weapon/ammo pickups use the existing INTERACT action.
	if (
		main_node != null
		and main_node.has_method("server_try_battlefield_pickup")
		and bool(main_node.call("server_try_battlefield_pickup", self))
	):
		return

	# Fixed ammunition stations use the same INTERACT action, but only after
	# nearby dropped equipment has been given priority.
	if (
		main_node != null
		and main_node.has_method("server_try_resupply_station")
		and bool(main_node.call("server_try_resupply_station", self))
	):
		return

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

func _build_external_character_model() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	external_model_loaded = false
	external_character_animator = null
	external_animation_controller = null

	var scene: PackedScene = (
		ExternalAssetRegistryScript.available_character(team)
	)
	if scene == null:
		return false

	_clear_external_weapon_model()
	if external_character_model != null:
		external_character_model.queue_free()

	var model_config: Dictionary = (
		ExternalAssetRegistryScript.character_config(team)
	)
	external_character_model = (
		ExternalAssetLoaderScript.instantiate_scene(
			self,
			scene,
			"ExternalCharacterModel",
			Vector3(model_config.get(
				"offset",
				Vector3(0.0, -1.0, 0.0)
			)),
			float(model_config.get("rotation_y", 0.0)),
			Vector3(model_config.get("scale", Vector3.ONE))
		)
	)
	if external_character_model == null:
		return false

	var asset_adaptation: Dictionary = (
		RealAssetAdapterScript.adapt_character(
			external_character_model,
			team
		)
	)
	if not bool(asset_adaptation.get("valid", false)):
		print(
			"External character rejected peer=%d %s"
			% [peer_id, asset_adaptation]
		)
		external_character_model.queue_free()
		external_character_model = null
		return false

	ExternalAssetLoaderScript.configure_character_model(
		external_character_model
	)
	external_character_animator = (
		ExternalAssetLoaderScript.animation_player(
			external_character_model
		)
	)
	external_animation_controller = (
		HumanoidAnimationControllerScript.new()
	)
	external_animation_controller.configure(
		external_character_animator
	)
	external_weapon_socket = (
		RealAssetAdapterScript.find_character_socket(
			external_character_model
		)
	)
	external_model_loaded = true
	var character_validation: Dictionary = (
		ExternalAssetValidatorScript.validate_character(
			external_character_model
		)
	)
	print(
		"External character peer=%d team=%d adaptation=%s validation=%s"
		% [
			peer_id,
			team,
			asset_adaptation,
			character_validation
		]
	)
	var main_node: Node = get_parent()
	if (
		main_node != null
		and main_node.get("external_lod_controller") != null
	):
		var lod_controller = main_node.get(
			"external_lod_controller"
		)
		if lod_controller.has_method("register_external"):
			lod_controller.call(
				"register_external",
				external_character_model
			)
	_refresh_external_weapon_model()

	var fallback_body: Node3D = get_node_or_null("Body") as Node3D
	var fallback_character: Node3D = (
		get_node_or_null("CharacterVisual") as Node3D
	)
	if fallback_body != null:
		fallback_body.visible = false
	if fallback_character != null:
		fallback_character.visible = false
	return true

func _clear_external_weapon_model() -> void:
	if external_weapon_model != null:
		external_weapon_model.queue_free()
	external_weapon_model = null
	external_weapon_index = -1
	external_weapon_team = -1

func _refresh_external_weapon_model() -> void:
	if external_character_model == null:
		_clear_external_weapon_model()
		return
	if external_weapon_socket == null:
		_clear_external_weapon_model()
		return
	var visual_team: int = _weapon_visual_team(current_weapon_index)
	if (
		external_weapon_index == current_weapon_index
		and external_weapon_team == visual_team
	):
		return

	_clear_external_weapon_model()
	var scene: PackedScene = (
		ExternalAssetRegistryScript.weapon_scene(
			visual_team,
			current_weapon_index
		)
	)
	if scene == null:
		return

	external_weapon_model = (
		ExternalAssetLoaderScript.attach_scene_to_socket(
			external_weapon_socket,
			scene,
			(
				"ExternalServicePistol"
				if current_weapon_index == 1
				else "ExternalPrimaryWeapon"
			),
			Vector3.ZERO,
			Vector3.ZERO,
			Vector3.ONE
		)
	)
	if external_weapon_model != null:
		RealAssetAdapterScript.adapt_weapon(
			external_weapon_model,
			0.29 if current_weapon_index == 1 else 0.88
		)
		external_weapon_index = current_weapon_index
		external_weapon_team = visual_team

func _update_external_character_animation() -> void:
	if external_character_model == null:
		return
	_refresh_external_weapon_model()

	external_character_model.visible = (
		not _is_local_player()
		and alive
	)
	if external_animation_controller == null:
		return

	var speed: float = Vector2(
		velocity.x,
		velocity.z
	).length()
	var animation_state: String = (
		external_animation_controller.resolve_state(
			alive,
			downed,
			is_reloading,
			is_crouching,
			speed,
			Time.get_ticks_msec() < muzzle_flash_until_ms,
			player_class == PlayerClass.ENGINEER
			and aim_requested
		)
	)
	external_character_animation = (
		external_animation_controller.set_state(
			animation_state
		)
	)

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
	world_nameplate.font_size = 18
	world_nameplate.outline_size = 5
	world_nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world_nameplate.fixed_size = false
	world_nameplate.visible = false
	add_child(world_nameplate)

	world_class_label = Label3D.new()
	world_class_label.name = "WorldClassLabel"
	world_class_label.position = Vector3(0.0, 1.38, 0.0)
	world_class_label.font_size = 14
	world_class_label.outline_size = 4
	world_class_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world_class_label.fixed_size = false
	world_class_label.visible = false
	add_child(world_class_label)

	revive_marker = Label3D.new()
	revive_marker.name = "ReviveMarker"
	revive_marker.text = "REVIVE"
	revive_marker.position = Vector3(0.0, 1.30, 0.0)
	revive_marker.font_size = 18
	revive_marker.outline_size = 5
	revive_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	revive_marker.fixed_size = false
	revive_marker.modulate = Color(0.25, 1.0, 0.38)
	revive_marker.visible = false
	add_child(revive_marker)

func _refresh_identity_visuals(force: bool = false) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not force and team == last_visual_team and player_class == last_visual_class:
		return

	var team_changed: bool = team != last_visual_team
	last_visual_team = team
	last_visual_class = player_class
	if team_changed:
		_build_external_character_model()
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
			body_material.albedo_color = (
				Color(0.34, 0.38, 0.22)
				if team == 0
				else Color(0.34, 0.35, 0.31)
			)
			body_material.roughness = 0.94
			body_material.metallic = 0.0
			body_material.emission_enabled = false
			if tex_uniform_normal != null:
				body_material.normal_enabled = true
				body_material.normal_texture = tex_uniform_normal
				body_material.normal_scale = 0.48
			if tex_uniform_roughness != null:
				body_material.roughness_texture = tex_uniform_roughness
				body_material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

	if accent_material != null:
		accent_material.albedo_color = accent_color
		accent_material.emission = accent_color

	if world_nameplate != null:
		world_nameplate.text = player_name
		world_nameplate.modulate = team_color.lightened(0.35)

	if world_class_label != null:
		world_class_label.text = _class_short_name(player_class)
		world_class_label.modulate = accent_color.lightened(0.25)

func _apply_first_person_body_visibility() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var local_view: bool = _is_local_player()
	var body_node: Node3D = get_node_or_null("Body") as Node3D
	var character_visual: Node3D = (
		get_node_or_null("CharacterVisual") as Node3D
	)
	var fallback_visible := (
		not local_view
		and alive
		and not external_model_loaded
	)

	if body_node != null:
		body_node.visible = fallback_visible
	if character_visual != null:
		character_visual.visible = fallback_visible
	if class_accent_mesh != null:
		class_accent_mesh.visible = not local_view and alive

	if local_view:
		if world_nameplate != null:
			world_nameplate.visible = false
		if world_class_label != null:
			world_class_label.visible = false
		if spotted_label != null:
			spotted_label.visible = false
		if revive_marker != null:
			revive_marker.visible = false

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
	world_nameplate.text = ("◆ " if same_team else "") + player_name
	var distance: float = local_player.global_position.distance_to(global_position)
	var enemy_spotted: bool = replicated_spotted_ms > 0

	world_nameplate.visible = alive and not downed and (
		(same_team and distance <= 28.0)
		or (enemy_spotted and distance <= 34.0)
	)
	world_class_label.visible = alive and not downed and same_team and distance <= 20.0

func _build_spotted_marker() -> void:
	if DisplayServer.get_name() == "headless":
		return

	spotted_label = Label3D.new()
	spotted_label.name = "SpottedMarker"
	spotted_label.text = "SPOTTED"
	spotted_label.position = Vector3(0.0, 1.55, 0.0)
	spotted_label.font_size = 16
	spotted_label.outline_size = 4
	spotted_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	spotted_label.no_depth_test = false
	spotted_label.fixed_size = false
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


func _bot_nearest_wounded_teammate() -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for player_value in get_parent().players.values():
		var teammate: Node3D = player_value as Node3D
		if teammate == null or teammate == self:
			continue
		if int(teammate.get("team")) != team:
			continue
		if not bool(teammate.get("alive")):
			continue
		if bool(teammate.get("downed")):
			continue
		var teammate_health: int = int(teammate.get("health"))
		var teammate_class: int = int(
			teammate.get("player_class")
		)
		var maximum_health: int = int(
			teammate.call("_class_health", teammate_class)
		)
		if teammate_health >= int(maximum_health * 0.72):
			continue
		var distance: float = global_position.distance_to(
			teammate.global_position
		)
		if distance < best_distance:
			best_distance = distance
			best = teammate
	return best

func _bot_nearest_support_cluster() -> Vector3:
	var accumulated := Vector3.ZERO
	var count := 0
	for player_value in get_parent().players.values():
		var teammate: Node3D = player_value as Node3D
		if teammate == null or teammate == self:
			continue
		if int(teammate.get("team")) != team:
			continue
		if not bool(teammate.get("alive")):
			continue
		if bool(teammate.get("downed")):
			continue
		var distance: float = global_position.distance_to(
			teammate.global_position
		)
		if distance > 24.0:
			continue
		accumulated += teammate.global_position
		count += 1
	if count == 0:
		return global_position
	return accumulated / float(count)

func _bot_class_tactical_goal(main: Node) -> Vector3:
	if (
		main == null
		or not main.has_method("bot_tactical_anchor")
	):
		return Vector3(main.call("bot_goal_position", self))

	var anchor: Vector3 = Vector3(
		main.call(
			"bot_tactical_anchor",
			self,
			player_class,
			bot_squad_role
		)
	)

	match player_class:
		PlayerClass.MEDIC:
			var wounded: Node3D = _bot_nearest_wounded_teammate()
			if wounded != null:
				return wounded.global_position
		PlayerClass.FIELD_OPS:
			var cluster: Vector3 = _bot_nearest_support_cluster()
			if cluster.distance_to(global_position) > 3.0:
				return cluster
		PlayerClass.SCOUT:
			# Scouts hold their assigned sightline unless threatened.
			if Time.get_ticks_msec() < bot_hold_position_until_ms:
				return global_position
		_:
			pass

	return anchor

func _bot_suppression_goal(main: Node) -> Variant:
	if suppression_remaining_ms() <= 0:
		return null
	if bot_last_threat_position == Vector3.ZERO:
		return null
	if main == null or not main.has_method("bot_cover_position"):
		return null

	var now: int = Time.get_ticks_msec()
	if (
		now >= bot_cover_refresh_ms
		or bot_tactical_goal == Vector3.ZERO
	):
		bot_tactical_goal = Vector3(
			main.call(
				"bot_cover_position",
				self,
				bot_last_threat_position
			)
		)
		bot_cover_refresh_ms = now + 1400

	return bot_tactical_goal

func _bot_should_hold_fire(target: Node3D) -> bool:
	if target == null:
		return true
	var distance: float = global_position.distance_to(
		target.global_position
	)
	if player_class == PlayerClass.MEDIC and health < 35:
		return true
	if player_class == PlayerClass.ENGINEER:
		var main: Node = get_parent()
		if main != null:
			var objective_goal: Vector3 = Vector3(
				main.call("bot_goal_position", self)
			)
			if global_position.distance_to(objective_goal) < 4.2:
				return false
	if player_class == PlayerClass.SCOUT and distance < 5.0:
		return true
	return false

func _bot_squad_support_goal(main: Node) -> Variant:
	if (
		main == null
		or not main.has_method("bot_squad_support_goal")
	):
		return null

	var now: int = Time.get_ticks_msec()
	if (
		now >= bot_squad_support_refresh_ms
		or bot_cached_squad_goal == Vector3.ZERO
	):
		var result: Variant = main.call(
			"bot_squad_support_goal",
			self,
			player_class
		)
		if result is Vector3:
			bot_cached_squad_goal = Vector3(result)
		else:
			bot_cached_squad_goal = Vector3.ZERO
		bot_squad_support_refresh_ms = now + 1200

	if bot_cached_squad_goal == Vector3.ZERO:
		return null
	return bot_cached_squad_goal

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

	var suppression_goal: Variant = _bot_suppression_goal(main)
	if suppression_goal is Vector3:
		movement_goal = Vector3(suppression_goal)
		has_movement_goal = true

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

		if not has_movement_goal:
			var wounded_teammate: Node3D = (
				_bot_nearest_wounded_teammate()
			)
			if wounded_teammate != null:
				var wounded_distance: float = (
					global_position.distance_to(
						wounded_teammate.global_position
					)
				)
				if wounded_distance > 4.2:
					movement_goal = (
						wounded_teammate.global_position
					)
					has_movement_goal = true
				elif bot_ability_accumulator <= 0.0:
					bot_ability_accumulator = 2.0
					_bot_try_ability()

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

	target_player = main.call(
		"bot_shared_enemy",
		self
	) as Node3D

	if target_player != null:
		var enemy_distance: float = global_position.distance_to(
			target_player.global_position
		)
		if enemy_distance > 48.0:
			target_player = null

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
			if main.has_method("report_squad_enemy"):
				main.call(
					"report_squad_enemy",
					self,
					target_player
				)
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
				24.0
				if player_class == PlayerClass.SCOUT
				else (
					13.0
					if player_class == PlayerClass.FIELD_OPS
					else 10.0
				)
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

			if (
				bot_fire_accumulator <= 0.0
				and not _bot_should_hold_fire(target_player)
			):
				bot_fire_accumulator = maxf(
					0.10,
					float(_weapon_fire_interval_ms())
					/ 1000.0
				)
				_server_bot_fire(target_player)
				if player_class == PlayerClass.SCOUT:
					bot_hold_position_until_ms = now + 1800
		elif not has_movement_goal:
			movement_goal = target_player.global_position
			has_movement_goal = true

	if not has_movement_goal:
		var objective_goal: Vector3 = Vector3(
			main.call("bot_goal_position", self)
		)
		var routed_goal: Vector3 = Vector3(
			main.call(
				"bot_route_waypoint",
				self,
				bot_route_index
			)
		)

		if global_position.distance_to(routed_goal) <= 3.25:
			bot_route_index += 1
			routed_goal = Vector3(
				main.call(
					"bot_route_waypoint",
					self,
					bot_route_index
				)
			)

		movement_goal = (
			objective_goal
			if global_position.distance_to(objective_goal) <= 20.0
			else routed_goal
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

	bot_has_active_move_goal = has_movement_goal
	if has_movement_goal:
		bot_active_move_goal = movement_goal
	else:
		bot_active_move_goal = global_position

	_bot_drive_with_server_movement(delta)

func _bot_face_position(world_position: Vector3) -> void:
	var flat_direction: Vector3 = world_position - global_position
	flat_direction.y = 0.0
	if flat_direction.length() <= 0.01:
		return
	var desired_yaw: float = atan2(
		-flat_direction.x,
		-flat_direction.z
	)
	rotation.y = lerp_angle(
		rotation.y,
		desired_yaw,
		0.28
	)

func _bot_initialize_route() -> void:
	if not bot_route.is_empty():
		return

	if team == 0:
		bot_route = [
			Vector3(-48.0, 1.0, -10.0),
			Vector3(-42.0, 1.0, -15.0),
			Vector3(-35.0, 1.0, -22.0),
			Vector3(-24.0, 1.0, -15.0),
			Vector3(-14.0, 1.0, -8.0),
			Vector3(-6.0, 1.0, 0.0),
			Vector3(10.0, 1.0, 8.0),
			Vector3(28.0, 1.0, 20.0)
		]
	else:
		bot_route = [
			Vector3(48.0, 1.0, 10.0),
			Vector3(42.0, 1.0, 16.0),
			Vector3(36.0, 1.0, 22.0),
			Vector3(28.0, 1.0, 14.0),
			Vector3(20.0, 1.0, 8.0),
			Vector3(10.0, 1.0, 2.0),
			Vector3(-6.0, 1.0, -4.0),
			Vector3(-22.0, 1.0, -12.0)
		]

	bot_waypoint_index = 0

func _bot_route_goal(fallback_goal: Vector3) -> Vector3:
	_bot_initialize_route()
	if bot_route.is_empty():
		return fallback_goal

	var waypoint: Vector3 = bot_route[bot_waypoint_index]
	var safety_iterations := 0
	while (
		global_position.distance_to(waypoint) < 4.0
		and safety_iterations < bot_route.size()
	):
		bot_waypoint_index = mini(
			bot_waypoint_index + 1,
			bot_route.size() - 1
		)
		waypoint = bot_route[bot_waypoint_index]
		safety_iterations += 1

	# Use the objective directly once the bot has reached the central lanes.
	if global_position.distance_to(fallback_goal) < 18.0:
		return fallback_goal
	return waypoint

func _server_check_out_of_bounds_recovery() -> void:
	if not multiplayer.is_server():
		return

	var now: int = Time.get_ticks_msec()
	if now < out_of_bounds_recovery_cooldown_ms:
		return
	if global_position.y > -12.0:
		return

	out_of_bounds_recovery_cooldown_ms = now + 2500

	var main_node: Node = get_parent()
	if (
		main_node == null
		or not main_node.has_method(
			"server_recover_out_of_bounds_player"
		)
	):
		return

	var recovered: Vector3 = Vector3(
		main_node.call(
			"server_recover_out_of_bounds_player",
			peer_id,
			team,
			global_position
		)
	)
	if recovered.distance_to(global_position) > 1.0:
		global_position = recovered
		velocity = Vector3.ZERO
		bot_last_position = recovered
		if is_bot:
			bot_route.clear()
			bot_waypoint_index = 0

func _bot_try_stuck_recovery() -> void:
	var now: int = Time.get_ticks_msec()
	if now < bot_last_recovery_ms + 5000:
		return
	bot_last_recovery_ms = now

	var main_node: Node = get_parent()
	if (
		main_node == null
		or not main_node.has_method("server_recover_stuck_player")
	):
		return

	var recovered: Vector3 = Vector3(
		main_node.call(
			"server_recover_stuck_player",
			peer_id,
			team,
			global_position
		)
	)
	if recovered.distance_to(global_position) > 1.0:
		global_position = recovered
		velocity = Vector3.ZERO
		bot_last_position = recovered

func _bot_drive_with_server_movement(delta: float) -> void:
	if not bot_has_active_move_goal:
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	var world_direction: Vector3 = (
		bot_active_move_goal - global_position
	)
	world_direction.y = 0.0
	var distance: float = world_direction.length()

	if distance <= 0.75:
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	world_direction = world_direction.normalized()
	var desired_yaw: float = atan2(
		-world_direction.x,
		-world_direction.z
	)
	rotation.y = lerp_angle(rotation.y, desired_yaw, 0.35)

	var move_speed: float = (
		SPRINT_SPEED
		if distance > 8.0
		else WALK_SPEED
	)
	velocity.x = world_direction.x * move_speed
	velocity.z = world_direction.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif (
		Time.get_ticks_msec() >= bot_next_jump_ms
		and _bot_obstacle_ahead(world_direction)
	):
		velocity.y = JUMP_SPEED
		bot_next_jump_ms = Time.get_ticks_msec() + 1800

	var before_position: Vector3 = global_position
	move_and_slide()
	var moved: float = before_position.distance_to(global_position)

	if moved >= 0.015:
		bot_hard_stuck_seconds = 0.0
		bot_route_stall_seconds = 0.0
		bot_last_route_distance = distance
		bot_last_position = global_position
		return

	bot_hard_stuck_seconds += delta
	if distance >= bot_last_route_distance - 0.05:
		bot_route_stall_seconds += delta
	else:
		bot_route_stall_seconds = 0.0
	bot_last_route_distance = distance

	if bot_hard_stuck_seconds >= 1.5:
		bot_hard_stuck_seconds = 0.0
		bot_strafe_direction *= -1.0
		var lateral := Vector3(
			-world_direction.z,
			0.0,
			world_direction.x
		) * bot_strafe_direction
		global_position += lateral * 0.75
		velocity = Vector3.ZERO

	if (
		bot_route_stall_seconds >= 3.5
		and Time.get_ticks_msec() >= bot_emergency_nudge_ms
	):
		bot_route_stall_seconds = 0.0
		bot_emergency_nudge_ms = Time.get_ticks_msec() + 5000
		var recovery_before: Vector3 = global_position
		_bot_try_stuck_recovery()

		# If validated recovery returns the same point, advance a small amount
		# toward the route goal. This is server-authoritative and bounded.
		if global_position.distance_to(recovery_before) < 0.25:
			global_position += world_direction * 1.25
			velocity = Vector3.ZERO

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

	var now: int = Time.get_ticks_msec()
	if (
		is_on_floor()
		and now >= bot_next_jump_ms
		and _bot_obstacle_ahead(flat_direction)
	):
		velocity.y = JUMP_SPEED
		bot_next_jump_ms = now + 1800

func _bot_obstacle_ahead(direction: Vector3) -> bool:
	var space_state: PhysicsDirectSpaceState3D = (
		get_world_3d().direct_space_state
	)

	var low_from: Vector3 = global_position + Vector3.UP * 0.35
	var low_to: Vector3 = low_from + direction * 1.15
	var low_query := PhysicsRayQueryParameters3D.create(
		low_from,
		low_to
	)
	low_query.exclude = [self]
	low_query.collision_mask = 1
	low_query.collide_with_bodies = true
	low_query.collide_with_areas = false
	var low_hit: Dictionary = space_state.intersect_ray(low_query)

	if low_hit.is_empty():
		return false

	var high_from: Vector3 = global_position + Vector3.UP * 1.25
	var high_to: Vector3 = high_from + direction * 1.15
	var high_query := PhysicsRayQueryParameters3D.create(
		high_from,
		high_to
	)
	high_query.exclude = [self]
	high_query.collision_mask = 1
	high_query.collide_with_bodies = true
	high_query.collide_with_areas = false
	var high_hit: Dictionary = space_state.intersect_ray(
		high_query
	)

	if not high_hit.is_empty():
		return false

	var low_position: Vector3 = Vector3(
		low_hit.get("position", low_to)
	)
	var obstacle_height: float = low_position.y - global_position.y
	return obstacle_height <= 0.75

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

		var lateral: Vector3 = transform.basis.x * bot_strafe_direction
		velocity.x = lateral.x * 3.8
		velocity.z = lateral.z * 3.8
		rotation.y += deg_to_rad(
			55.0 * bot_strafe_direction
		)

		if global_position.distance_to(bot_last_position) < 0.20:
			_bot_try_stuck_recovery()
		else:
			bot_last_position = global_position

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
	var base_position := Vector3(0.24, -0.30, -0.86)
	if current_weapon_index != 1:
		match player_class:
			PlayerClass.SOLDIER:
				base_position = Vector3(0.31, -0.34, -1.15)
			PlayerClass.MEDIC:
				base_position = Vector3(0.27, -0.30, -1.00)
			PlayerClass.ENGINEER:
				base_position = Vector3(0.28, -0.31, -1.03)
			PlayerClass.FIELD_OPS:
				base_position = Vector3(0.29, -0.32, -1.08)
			PlayerClass.SCOUT:
				base_position = Vector3(0.27, -0.29, -1.14)
	var fov_clearance: float = clampf(
		(profile_field_of_view - 75.0) / 35.0,
		-1.0,
		1.0
	)
	base_position.x += fov_clearance * 0.025
	base_position.z -= fov_clearance * 0.04
	return base_position

func _aim_weapon_position() -> Vector3:
	# v8.61 uses shoulder zoom rather than center-screen iron-sight ADS.
	# The camera still zooms to ADS_FOV/SCOUT_ADS_FOV, but the weapon drops
	# lower/right so it does not cover the crosshair or the target.
	if current_weapon_index == 1:
		return Vector3(0.20, -0.40, -0.94)

	match player_class:
		PlayerClass.SOLDIER:
			return Vector3(0.27, -0.46, -1.20)
		PlayerClass.MEDIC:
			return Vector3(0.24, -0.42, -1.08)
		PlayerClass.ENGINEER:
			return Vector3(0.25, -0.43, -1.11)
		PlayerClass.FIELD_OPS:
			return Vector3(0.26, -0.44, -1.15)
		PlayerClass.SCOUT:
			# Scout retains strong optical zoom but the rifle also lowers enough
			# that the persistent crosshair remains unobstructed.
			return Vector3(0.23, -0.41, -1.20)

	return Vector3(0.25, -0.43, -1.12)


func _aim_weapon_rotation() -> Vector3:
	# Slight downward/outward cant reinforces the lowered shoulder position
	# without rotating imported weapon geometry into a new orientation.
	if current_weapon_index == 1:
		return Vector3(0.055, 0.0, -0.030)

	match player_class:
		PlayerClass.SOLDIER:
			return Vector3(0.065, 0.0, -0.045)
		PlayerClass.MEDIC:
			return Vector3(0.060, 0.0, -0.040)
		PlayerClass.ENGINEER:
			return Vector3(0.060, 0.0, -0.040)
		PlayerClass.FIELD_OPS:
			return Vector3(0.062, 0.0, -0.042)
		PlayerClass.SCOUT:
			return Vector3(0.050, 0.0, -0.035)

	return Vector3(0.060, 0.0, -0.040)


func _apply_weapon_kick() -> void:
	if weapon_view == null:
		return
	var position: Vector3 = (
		_aim_weapon_position()
		if is_aiming
		else _base_weapon_position()
	)
	position.z += weapon_kick_offset
	weapon_view.position = position

func _local_fire_feedback() -> void:
	if weapon_handling_feedback != null:
		var feedback_camera: Camera3D = $Head/Camera3D as Camera3D
		if feedback_camera != null:
			weapon_handling_feedback.call(
				"eject_casing",
				feedback_camera,
				current_weapon_index == 1
			)

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
	recoil_position_impulse += Vector3(randf_range(-0.018,0.018),randf_range(-0.010,0.015),0.09)
	recoil_rotation_impulse += Vector3(deg_to_rad(randf_range(1.0,2.5)),deg_to_rad(randf_range(-0.9,0.9)),deg_to_rad(randf_range(-0.7,0.7)))
	_apply_weapon_kick()
	visual_weapon_heat = clampf(
		visual_weapon_heat + _first_person_heat_gain(),
		0.0,
		1.0
	)
	visual_last_shot_ms = Time.get_ticks_msec()

	muzzle_flash_until_ms = Time.get_ticks_msec() + 55
	if muzzle_flash != null:
		var flash_scale: float = randf_range(0.82, 1.18)
		muzzle_flash.scale = Vector3.ONE * flash_scale
		muzzle_flash.rotation_degrees.z = randf_range(0.0, 360.0)
		muzzle_flash.visible = true
	if muzzle_flash_sprite != null:
		muzzle_flash_sprite.visible = false

	_spawn_local_shell_effect()
	_spawn_muzzle_smoke()
	_spawn_muzzle_light()

func _spawn_muzzle_light() -> void:
	if weapon_view == null or not _is_local_player():
		return

	if active_muzzle_light != null and is_instance_valid(
		active_muzzle_light
	):
		active_muzzle_light.queue_free()

	active_muzzle_light = OmniLight3D.new()
	active_muzzle_light.name = "MuzzleLight"
	active_muzzle_light.position = _first_person_muzzle_position()
	active_muzzle_light.light_color = Color(1.0, 0.42, 0.08)
	active_muzzle_light.light_energy = lerpf(
		2.4,
		4.2,
		_first_person_flash_radius() / 0.070
	)
	active_muzzle_light.omni_range = lerpf(3.0, 5.0, visual_weapon_heat)
	active_muzzle_light.shadow_enabled = false
	weapon_view.add_child(active_muzzle_light)

	var tween := create_tween()
	tween.tween_property(
		active_muzzle_light,
		"light_energy",
		0.0,
		0.065
	)
	tween.tween_callback(active_muzzle_light.queue_free)

func _spawn_muzzle_smoke() -> void:
	if weapon_view == null or muzzle_smoke_texture == null or not _is_local_player():
		return
	var smoke_layers: int = 2 if visual_weapon_heat >= 0.58 else 1
	for layer_index in range(smoke_layers):
		var smoke := Sprite3D.new()
		smoke.name = "MuzzleSmoke%d" % layer_index
		smoke.texture = muzzle_smoke_texture
		smoke.pixel_size = lerpf(0.0016, 0.0028, visual_weapon_heat)
		smoke.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		smoke.position = _first_person_muzzle_position() + Vector3(
			randf_range(-0.018, 0.018),
			randf_range(-0.008, 0.018),
			-float(layer_index) * 0.035
		)
		var smoke_alpha: float = lerpf(0.36, 0.68, visual_weapon_heat)
		smoke.modulate = Color(0.78, 0.79, 0.76, smoke_alpha)
		smoke.rotation_degrees.z = randf_range(0.0, 360.0)
		weapon_view.add_child(smoke)
		var duration: float = lerpf(0.30, 0.58, visual_weapon_heat)
		var drift := Vector3(
			randf_range(-0.08, 0.08),
			lerpf(0.14, 0.26, visual_weapon_heat),
			randf_range(-0.16, -0.08)
		)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(smoke, "position", smoke.position + drift, duration)
		tween.tween_property(
			smoke,
			"scale",
			Vector3.ONE * lerpf(1.8, 3.2, visual_weapon_heat),
			duration
		)
		tween.tween_property(
			smoke,
			"modulate",
			Color(0.78, 0.79, 0.76, 0.0),
			duration
		)
		tween.chain().tween_callback(smoke.queue_free)

func _spawn_local_shell_effect() -> void:
	if weapon_view == null or not _is_local_player():
		return

	var shell := MeshInstance3D.new()
	shell.name = "ShellEffect"
	var shell_mesh := CylinderMesh.new()
	var shell_radius: float = 0.009 if current_weapon_index == 1 else 0.011
	if current_weapon_index == 0 and player_class == PlayerClass.SOLDIER:
		shell_radius = 0.013
	shell_mesh.top_radius = shell_radius
	shell_mesh.bottom_radius = shell_radius
	shell_mesh.height = shell_radius * 4.4
	shell.mesh = shell_mesh
	shell.position = (
		Vector3(0.10, -0.025, -0.04)
		if current_weapon_index == 1
		else Vector3(0.13, -0.025, -0.08)
	)
	shell.rotation_degrees = Vector3(0.0, 0.0, 90.0)

	var shell_material := StandardMaterial3D.new()
	shell_material.albedo_color = Color(0.78, 0.58, 0.18)
	shell_material.metallic = 0.75
	shell.material_override = shell_material
	weapon_view.add_child(shell)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	var shell_target: Vector3 = shell.position + Vector3(
		randf_range(0.24, 0.38),
		randf_range(0.14, 0.24),
		randf_range(0.12, 0.24)
	)
	tween.tween_property(
		shell,
		"position",
		shell_target,
		0.26
	)
	tween.tween_property(
		shell,
		"rotation_degrees",
		Vector3(
			randf_range(180.0, 300.0),
			randf_range(120.0, 240.0),
			randf_range(260.0, 420.0)
		),
		0.26
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
	hint.text = (
		"Press M anytime to reopen · F8 player settings"
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_box.add_child(hint)

	var main_node: Node = get_parent()
	if (
		main_node != null
		and main_node.has_method("get_local_profile_settings")
	):
		var settings: Dictionary = Dictionary(
			main_node.call("get_local_profile_settings")
		)
		selected_team = clampi(
			int(settings.get("preferred_team", selected_team)),
			0,
			1
		)
		selected_class = clampi(
			int(settings.get("preferred_class", selected_class)),
			0,
			4
		)
		_update_selection_status()

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

	var target_fov: float = profile_field_of_view
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

	if scope_overlay != null:
		scope_overlay.visible = _is_scout_scope_active()

	# v8.61 shoulder-zoom: keep the aiming reticle visible while Mouse2 is held.
	# Zoom improves target acquisition without forcing an obstructive iron-sight
	# view or removing the player's center reference.
	if crosshair != null:
		crosshair.visible = alive and not downed
	if et_crosshair_ring != null:
		et_crosshair_ring.visible = alive and not downed

func _build_first_person_weapon() -> void:
	weapon_view = Node3D.new()
	weapon_view.name = "FirstPersonWeapon"
	$Head/Camera3D.add_child(weapon_view)
	_rebuild_first_person_weapon()

func _first_person_skin_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.58, 0.39, 0.27)
	material.roughness = 0.88
	return material

func _safe_first_person_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _first_person_sleeve_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var imported_albedo: Texture2D = null
	var imported_normal: Texture2D = null
	var imported_roughness: Texture2D = null
	if team == 0:
		imported_albedo = _safe_first_person_texture(
			"res://assets/external/characters/private contractor1_body_BaseColor.jpg"
		)
		imported_normal = _safe_first_person_texture(
			"res://assets/external/characters/private contractor1_body_Normal.jpg"
		)
		imported_roughness = _safe_first_person_texture(
			"res://assets/external/characters/private contractor1_body_Roughness.jpg"
		)
	else:
		imported_albedo = _safe_first_person_texture(
			"res://assets/external/characters/Textures/Textures/Jacket/Jacket_BaseColor.jpg"
		)
		imported_normal = _safe_first_person_texture(
			"res://assets/external/characters/Textures/Textures/Jacket/Jacket_Normal.jpg"
		)
	if imported_albedo != null:
		material.albedo_texture = imported_albedo
	else:
		material.albedo_texture = (
			tex_uniform_attackers if team == 0 else tex_uniform_defenders
		)
	material.albedo_color = Color(0.72, 0.72, 0.68) if team == 0 else Color(0.60, 0.62, 0.56)
	material.roughness = 0.92
	material.metallic = 0.0
	if imported_normal != null:
		material.normal_enabled = true
		material.normal_texture = imported_normal
		material.normal_scale = 0.72
	elif tex_uniform_normal != null:
		material.normal_enabled = true
		material.normal_texture = tex_uniform_normal
		material.normal_scale = 0.48
	if imported_roughness != null:
		material.roughness_texture = imported_roughness
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	elif tex_uniform_roughness != null:
		material.roughness_texture = tex_uniform_roughness
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	return material

func _first_person_glove_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var glove_albedo: Texture2D = null
	var glove_normal: Texture2D = null
	var glove_roughness: Texture2D = null
	if team == 0:
		glove_albedo = _safe_first_person_texture(
			"res://assets/external/characters/private_contractor1_gloves_BaseColor.jpg"
		)
		glove_normal = _safe_first_person_texture(
			"res://assets/external/characters/private_contractor1_gloves_Normal.jpg"
		)
		glove_roughness = _safe_first_person_texture(
			"res://assets/external/characters/private_contractor1_gloves_Roughness.jpg"
		)
	else:
		glove_albedo = _safe_first_person_texture(
			"res://assets/external/characters/Textures/Textures/Gloves/Gloves_BaseColor.jpg"
		)
		glove_normal = _safe_first_person_texture(
			"res://assets/external/characters/Textures/Textures/Gloves/Gloves_Normal.jpg"
		)
	if glove_albedo != null:
		material.albedo_texture = glove_albedo
	else:
		material.albedo_color = Color(0.16,0.13,0.08) if team == 0 else Color(0.10,0.10,0.085)
	material.albedo_color = Color(0.78,0.78,0.74)
	material.roughness = 0.90
	material.metallic = 0.0
	if glove_normal != null:
		material.normal_enabled = true
		material.normal_texture = glove_normal
		material.normal_scale = 0.82
	if glove_roughness != null:
		material.roughness_texture = glove_roughness
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	return material

func _add_first_person_segment(
	parent: Node3D,
	node_name: String,
	start_point: Vector3,
	end_point: Vector3,
	start_radius: float,
	end_radius: float,
	material: Material
) -> void:
	# IMPORTANT: start_point/end_point are LOCAL TO parent.
	# Earlier builds used Node3D.look_at(end_point), but look_at() interprets
	# its target in global space. That mixed local and global coordinates and
	# produced the detached black bars/cylinders seen around the weapon.
	var direction: Vector3 = end_point - start_point
	var segment_length: float = direction.length()
	if segment_length <= 0.001:
		return

	var y_axis: Vector3 = direction.normalized()
	var reference: Vector3 = Vector3.FORWARD
	if absf(y_axis.dot(reference)) > 0.92:
		reference = Vector3.RIGHT

	var x_axis: Vector3 = reference.cross(y_axis).normalized()
	var z_axis: Vector3 = x_axis.cross(y_axis).normalized()
	var local_basis: Basis = Basis(x_axis, y_axis, z_axis).orthonormalized()
	var midpoint: Vector3 = (start_point + end_point) * 0.5

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = end_radius
	mesh.bottom_radius = start_radius
	mesh.height = segment_length
	mesh.radial_segments = 24
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# CylinderMesh is Y-axis aligned by default, so assign a local basis whose
	# Y axis points directly from the sleeve start to the grip. No look_at(),
	# no secondary 90-degree correction, and no world/local coordinate mixing.
	parent.add_child(mesh_instance)
	mesh_instance.transform = Transform3D(local_basis, midpoint)


func _add_fps_limb(
	node_name: String,
	start_point: Vector3,
	end_point: Vector3,
	radius_start: float,
	radius_end: float,
	material: Material
) -> void:
	# One continuous tapered mesh per limb section. No palms, fingers,
	# knuckles, cuffs, or detached thumb objects are spawned.
	_add_first_person_segment(
		weapon_view,
		node_name,
		start_point,
		end_point,
		radius_start,
		radius_end,
		material
	)


func _imported_viewmodel_holder() -> Node3D:
	if weapon_view == null:
		return null
	return weapon_view.get_node_or_null(
		"ImportedFirstPersonRig"
	) as Node3D


func _weapon_view_point_to_holder(
	holder: Node3D,
	weapon_view_point: Vector3
) -> Vector3:
	# Convert a point authored in weapon_view-local coordinates into the exact
	# local space used by ImportedFirstPersonRig.
	if holder == null or weapon_view == null:
		return weapon_view_point

	var global_point: Vector3 = weapon_view.to_global(weapon_view_point)
	return holder.to_local(global_point)


func _add_holder_limb(
	holder: Node3D,
	node_name: String,
	start_point: Vector3,
	end_point: Vector3,
	start_radius: float,
	end_radius: float,
	material: Material
) -> void:
	var direction: Vector3 = end_point - start_point
	var segment_length: float = direction.length()
	if segment_length <= 0.001:
		return

	var y_axis: Vector3 = direction.normalized()
	var reference: Vector3 = Vector3.FORWARD
	if absf(y_axis.dot(reference)) > 0.92:
		reference = Vector3.RIGHT

	var x_axis: Vector3 = reference.cross(y_axis).normalized()
	var z_axis: Vector3 = x_axis.cross(y_axis).normalized()
	var basis: Basis = Basis(x_axis, y_axis, z_axis).orthonormalized()

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name

	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = end_radius
	mesh.bottom_radius = start_radius
	mesh.height = segment_length
	mesh.radial_segments = 20
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	holder.add_child(mesh_instance)
	mesh_instance.transform = Transform3D(
		basis,
		(start_point + end_point) * 0.5
	)


func _build_first_person_arms(is_pistol: bool) -> void:
	# v8.60: procedural first-person arms are intentionally disabled.
	# Imported weapons remain clean and unobstructed. A future hand/arm pass
	# should use a properly rigged first-person asset rather than procedural
	# cylinders that can drift across differently-authored FBX weapon pivots.
	return


func _finalize_first_person_viewmodel() -> void:
	if weapon_view == null:
		return
	for child in weapon_view.find_children("*", "GeometryInstance3D", true):
		var geometry := child as GeometryInstance3D
		if geometry == null:
			continue
		geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		geometry.extra_cull_margin = 0.35

func _rebuild_first_person_weapon() -> void:
	if weapon_view == null:
		return

	for child in weapon_view.get_children():
		child.queue_free()

	var is_pistol: bool = current_weapon_index == 1
	var receiver_length: float = 0.72
	var barrel_length: float = 0.55
	var primary_profile: int = player_class
	weapon_base_position = _base_weapon_position()
	weapon_base_rotation = Vector3.ZERO
	weapon_view.position = weapon_base_position
	weapon_view.rotation = weapon_base_rotation

	if _build_imported_first_person_weapon(is_pistol):
		# Imported weapons now get a dedicated first-person sleeve/glove layer.
		# These arms are intentionally slimmer and positioned like an FPS
		# viewmodel instead of the earlier oversized prototype capsules.
		_build_first_person_arms(is_pistol)
		_finalize_first_person_viewmodel()
		return

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
	metal.albedo_color = Color(0.11, 0.12, 0.12)
	metal.roughness = 0.36
	metal.metallic = 0.72

	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.24, 0.115, 0.045)
	wood.roughness = 0.68

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
	grip_mesh.size = Vector3(0.105, 0.21, 0.105) if is_pistol else Vector3(0.14, 0.18, 0.22)
	grip.mesh = grip_mesh
	grip.position = Vector3(0.0, 0.13, 0.08) if is_pistol else Vector3(0.0, -0.015, 0.28)
	grip.rotation_degrees.x = -15.0 if is_pistol else 0.0
	grip.material_override = wood
	weapon_view.add_child(grip)

	_build_first_person_arms(is_pistol)

	if not is_pistol:
		var buttstock := MeshInstance3D.new()
		buttstock.name = "WoodStockBody"
		var buttstock_mesh := BoxMesh.new()
		buttstock_mesh.size = Vector3(0.14, 0.16, 0.24)
		buttstock.mesh = buttstock_mesh
		buttstock.position = Vector3(
			0.0,
			0.02,
			receiver_length * 0.5 + 0.11
		)
		buttstock.rotation_degrees.x = -7.0
		buttstock.material_override = wood
		weapon_view.add_child(buttstock)

		var stock_comb := MeshInstance3D.new()
		stock_comb.name = "WoodStockComb"
		var stock_comb_mesh := BoxMesh.new()
		stock_comb_mesh.size = Vector3(0.13, 0.07, 0.20)
		stock_comb.mesh = stock_comb_mesh
		stock_comb.position = Vector3(
			0.0,
			-0.075,
			receiver_length * 0.5 + 0.10
		)
		stock_comb.rotation_degrees.x = -7.0
		stock_comb.material_override = wood
		weapon_view.add_child(stock_comb)

		var butt_plate := MeshInstance3D.new()
		butt_plate.name = "ButtPlate"
		var butt_plate_mesh := BoxMesh.new()
		butt_plate_mesh.size = Vector3(0.145, 0.17, 0.025)
		butt_plate.mesh = butt_plate_mesh
		butt_plate.position = Vector3(
			0.0,
			0.035,
			receiver_length * 0.5 + 0.235
		)
		butt_plate.rotation_degrees.x = -7.0
		butt_plate.material_override = metal
		weapon_view.add_child(butt_plate)

		var handguard := MeshInstance3D.new()
		var handguard_mesh := CylinderMesh.new()
		handguard_mesh.top_radius = 0.07
		handguard_mesh.bottom_radius = 0.085
		handguard_mesh.height = 0.48
		handguard_mesh.radial_segments = 18
		handguard.mesh = handguard_mesh
		handguard.rotation_degrees.x = 90.0
		handguard.position = Vector3(
			0.0,
			0.015,
			-(receiver_length * 0.5 + 0.16)
		)
		handguard.material_override = wood
		weapon_view.add_child(handguard)

		var rear_sight := MeshInstance3D.new()
		var rear_sight_mesh := BoxMesh.new()
		rear_sight_mesh.size = Vector3(0.12, 0.08, 0.045)
		rear_sight.mesh = rear_sight_mesh
		rear_sight.position = Vector3(0.0, -0.12, 0.14)
		rear_sight.material_override = metal
		weapon_view.add_child(rear_sight)

		var front_sight := MeshInstance3D.new()
		var front_sight_mesh := BoxMesh.new()
		front_sight_mesh.size = Vector3(0.025, 0.12, 0.035)
		front_sight.mesh = front_sight_mesh
		front_sight.position = Vector3(
			0.0,
			-0.10,
			-(receiver_length * 0.5 + barrel_length * 0.68)
		)
		front_sight.material_override = metal
		weapon_view.add_child(front_sight)

	FirstPersonWeaponFidelityScript.decorate(
		weapon_view,
		is_pistol,
		player_class,
		metal,
		wood
	)
	muzzle_flash = MeshInstance3D.new()
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = _first_person_flash_radius()
	flash_mesh.height = flash_mesh.radius * 2.15
	muzzle_flash.mesh = flash_mesh
	muzzle_flash.position = _first_person_muzzle_position()

	var flash_material := StandardMaterial3D.new()
	flash_material.albedo_color = Color(1.0, 0.65, 0.12)
	flash_material.emission_enabled = true
	flash_material.emission = Color(1.0, 0.35, 0.02)
	muzzle_flash.material_override = flash_material
	muzzle_flash.visible = false
	weapon_view.add_child(muzzle_flash)
	_finalize_first_person_viewmodel()

func _initialize_optional_client_systems() -> void:
	if not _is_local_player():
		return

	_build_combat_camera_feedback()
	_build_team_identity_hud()
	_build_audio_players()
	if radar_panel != null:
		radar_panel.visible = true

func _build_combat_camera_feedback() -> void:
	if DisplayServer.get_name() == "headless" or combat_camera_feedback != null:
		return
	combat_camera_feedback = CombatCameraFeedbackScript.new()
	combat_camera_feedback.name = "CombatCameraFeedback"
	add_child(combat_camera_feedback)
	combat_camera_feedback.call("initialize")

func _update_combat_camera_feedback(delta: float) -> void:
	if combat_camera_feedback == null:
		return
	combat_camera_feedback.call(
		"update_state",
		delta,
		health,
		_class_health(player_class),
		replicated_suppression_ms,
		replicated_heavy_fire_ms,
		downed,
		alive
	)

func _build_team_identity_hud() -> void:
	if DisplayServer.get_name() == "headless" or team_identity_hud != null:
		return
	team_identity_hud = TeamIdentityHUDScript.new()
	team_identity_hud.name = "TeamIdentityHUD"
	add_child(team_identity_hud)
	team_identity_hud.call("initialize")

func _update_team_identity_hud() -> void:
	if team_identity_hud == null:
		return
	var main: Node = get_parent()
	var stage := 0
	if main != null:
		stage = int(main.get("objective_stage"))
	var class_names: Array[String] = ["SOLDIER", "MEDIC", "ENGINEER", "FIELD OPS", "SCOUT"]
	var selected_class_label: String = class_names[clampi(player_class, 0, class_names.size() - 1)]
	team_identity_hud.call("update_identity", team, selected_class_label, stage, has_deployed)

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
	weapon_audio.bus = "SFX"
	weapon_audio.volume_db = -5.0
	add_child(weapon_audio)

	reload_audio = AudioStreamPlayer.new()
	reload_audio.stream = reload_sound
	reload_audio.bus = "SFX"
	reload_audio.volume_db = -7.0
	add_child(reload_audio)

	footstep_audio = AudioStreamPlayer3D.new()
	footstep_audio.stream = footstep_sound
	footstep_audio.bus = "SFX"
	footstep_audio.max_distance = 18.0
	footstep_audio.volume_db = -10.0
	add_child(footstep_audio)

	confirm_audio = AudioStreamPlayer.new()
	confirm_audio.bus = "SFX"
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

func _detect_surface_name() -> String:
	var space_state := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.25
	var to := global_position + Vector3.DOWN * 1.35
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return "air"

	var collider: Object = result.get("collider")
	var collider_name := ""
	if collider != null:
		collider_name = str(collider.get("name")).to_lower()

	if (
		"metal" in collider_name
		or "rail" in collider_name
		or "halftrack" in collider_name
	):
		return "metal"
	if (
		"wood" in collider_name
		or "crate" in collider_name
		or "stagingcover" in collider_name
		or "barricade" in collider_name
	):
		return "wood"
	if (
		"brick" in collider_name
		or "townhouse" in collider_name
		or "church" in collider_name
		or "warehouse" in collider_name
		or "concrete" in collider_name
		or "bunker" in collider_name
	):
		return "stone"
	if (
		"mud" in collider_name
		or "ground" in collider_name
		or "crater" in collider_name
	):
		return "ground"
	return "gravel"

func _surface_footstep_pitch(surface_name: String) -> float:
	match surface_name:
		"metal":
			return randf_range(1.12, 1.24)
		"wood":
			return randf_range(0.86, 0.96)
		"stone":
			return randf_range(1.00, 1.10)
		"gravel":
			return randf_range(0.94, 1.06)
		_:
			return randf_range(0.88, 1.00)

func _surface_footstep_volume(surface_name: String) -> float:
	match surface_name:
		"metal":
			return 1.5
		"wood":
			return 0.5
		"stone":
			return 1.0
		"gravel":
			return 0.8
		_:
			return 0.0

func _update_footstep_audio(delta: float) -> void:
	if footstep_audio == null or not alive or downed or not is_on_floor():
		footstep_accumulator = 0.0
		return
	var speed: float = Vector2(velocity.x, velocity.z).length()
	if speed < 1.0:
		footstep_accumulator = 0.0
		footstep_audio.volume_db = 0.0
		return
	var interval: float = 0.29 if speed >= 8.0 else (0.40 if speed >= 5.0 else 0.52)
	footstep_accumulator += delta
	if footstep_accumulator >= interval:
		footstep_accumulator = 0.0
		current_surface_name = _detect_surface_name()
		footstep_audio.pitch_scale = _surface_footstep_pitch(
			current_surface_name
		)
		footstep_audio.volume_db = _surface_footstep_volume(
			current_surface_name
		)
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

func _apply_resolution_safe_hud() -> void:
	if hud_canvas_layer == null:
		return

	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	if viewport_size.is_equal_approx(hud_last_viewport_size):
		return

	hud_last_viewport_size = viewport_size
	var scale_factor: float = minf(
		viewport_size.x / hud_base_resolution.x,
		viewport_size.y / hud_base_resolution.y
	)
	scale_factor = clampf(scale_factor, 0.58, 1.55)
	scale_factor *= profile_hud_scale
	var rendered_size: Vector2 = hud_base_resolution * scale_factor
	var offset: Vector2 = (viewport_size - rendered_size) * 0.5

	hud_canvas_layer.transform = Transform2D(
		Vector2(scale_factor, 0.0),
		Vector2(0.0, scale_factor),
		offset
	)

func _hud_panel_style(
	background: Color,
	border: Color,
	border_width: int = 2,
	corner_radius: int = 7
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

func _make_et_panel(
	parent: Control,
	position_value: Vector2,
	size_value: Vector2,
	background: Color,
	border: Color
) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = position_value
	panel.size = size_value
	panel.add_theme_stylebox_override(
		"panel",
		_hud_panel_style(background, border)
	)
	parent.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	panel.add_child(box)
	return box

func _make_et_label(
	parent: Control,
	text_value: String,
	font_size: int,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.94, 0.93, 0.85))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _build_et_style_hud(layer: CanvasLayer) -> void:
	et_hud_root = Control.new()
	et_hud_root.name = "ObjectiveShooterHUD"
	et_hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	et_hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(et_hud_root)

	var olive_border := Color(0.52, 0.48, 0.31, 0.95)
	var dark_panel := Color(0.055, 0.060, 0.052, 0.82)

	var top_box := _make_et_panel(
		et_hud_root,
		Vector2(390, 14),
		Vector2(500, 82),
		dark_panel,
		olive_border
	)
	et_timer_label = _make_et_label(
		top_box,
		"10:00",
		23,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	et_objective_label = _make_et_label(
		top_box,
		"FOLLOW THE ACTIVE OBJECTIVE",
		16,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	et_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	et_compass_label = Label.new()
	et_compass_label.position = Vector2(532, 95)
	et_compass_label.custom_minimum_size = Vector2(216, 26)
	et_compass_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	et_compass_label.add_theme_font_size_override("font_size", 16)
	et_compass_label.add_theme_color_override(
		"font_color",
		Color(0.86, 0.82, 0.62)
	)
	et_hud_root.add_child(et_compass_label)

	et_objective_distance_label = Label.new()
	et_objective_distance_label.position = Vector2(540, 121)
	et_objective_distance_label.custom_minimum_size = Vector2(200, 24)
	et_objective_distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	et_objective_distance_label.add_theme_font_size_override("font_size", 15)
	et_objective_distance_label.add_theme_color_override(
		"font_color",
		Color(0.96, 0.82, 0.30)
	)
	et_hud_root.add_child(et_objective_distance_label)

	et_objective_arrow_label = Label.new()
	et_objective_arrow_label.position = Vector2(620, 142)
	et_objective_arrow_label.custom_minimum_size = Vector2(40, 28)
	et_objective_arrow_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	et_objective_arrow_label.add_theme_font_size_override(
		"font_size",
		19
	)
	et_objective_arrow_label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.78, 0.12)
	)
	et_hud_root.add_child(et_objective_arrow_label)

	et_route_hint_label = Label.new()
	et_route_hint_label.position = Vector2(470, 166)
	et_route_hint_label.custom_minimum_size = Vector2(340, 22)
	et_route_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	et_route_hint_label.add_theme_font_size_override("font_size", 12)
	et_route_hint_label.add_theme_color_override(
		"font_color",
		Color(0.78,0.80,0.72,0.86)
	)
	et_hud_root.add_child(et_route_hint_label)

	var left_box := _make_et_panel(
		et_hud_root,
		Vector2(18, 574),
		Vector2(300, 126),
		dark_panel,
		olive_border
	)
	et_team_label = _make_et_label(left_box, "ATTACKERS · SOLDIER", 18)
	et_health_label = _make_et_label(left_box, "✚ 100 HP", 25)
	et_stamina_label = _make_et_label(left_box, "STAMINA 100%", 16)
	et_rank_label = _make_et_label(left_box, "RECRUIT · 0 XP", 16)

	var right_box := _make_et_panel(
		et_hud_root,
		Vector2(965, 574),
		Vector2(297, 126),
		dark_panel,
		olive_border
	)
	et_weapon_label = _make_et_label(
		right_box,
		"SERVICE RIFLE",
		18,
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	et_ammo_label = _make_et_label(
		right_box,
		"30 / 120",
		29,
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	et_grenade_label = _make_et_label(
		right_box,
		"GRENADES 2 · SMOKE 1",
		16,
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	et_status_label = Label.new()
	et_status_label.position = Vector2(420, 661)
	et_status_label.custom_minimum_size = Vector2(440, 24)
	et_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	et_status_label.add_theme_font_size_override("font_size", 16)
	et_status_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.90, 0.70)
	)
	et_hud_root.add_child(et_status_label)

	et_crosshair_ring = Label.new()
	et_crosshair_ring.text = "⊕"
	et_crosshair_ring.position = Vector2(625, 333)
	et_crosshair_ring.add_theme_font_size_override("font_size", 27)
	et_crosshair_ring.add_theme_color_override(
		"font_color",
		Color(0.92, 0.92, 0.82, 0.72)
	)
	et_crosshair_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	et_hud_root.add_child(et_crosshair_ring)

	# The original debug text is still updated internally but no longer rendered.
	if hud != null:
		hud.visible = false
	if operations_label != null:
		operations_label.visible = false
	if class_mode_label != null:
		class_mode_label.visible = false
	if rank_progress_label != null:
		rank_progress_label.visible = false
	if tactical_indicator != null:
		tactical_indicator.visible = false
	if compass_label != null:
		compass_label.visible = false
	if crosshair != null:
		crosshair.visible = false

func _update_et_style_hud(main: Node, names: Array) -> void:
	if et_hud_root == null or main == null:
		return

	var minutes: int = int(main.get("match_time_remaining")) / 60
	var seconds: int = int(main.get("match_time_remaining")) % 60
	var team_name := "ATTACKERS" if team == 0 else "DEFENDERS"
	var stance_name := "CROUCHED" if is_crouching else "STANDING"
	var life_name := "DOWNED" if downed else ("ALIVE" if alive else "RESPAWNING")

	et_timer_label.text = (
		"%02d:%02d · ATK %d / DEF %d"
		% [
			minutes,
			seconds,
			int(main.get("attacker_tickets")),
			int(main.get("defender_tickets"))
		]
	)
	et_objective_label.text = str(main.call("objective_status_text"))

	var heading_degrees: float = fposmod(
		rad_to_deg(rotation.y) + 180.0,
		360.0
	)
	var cardinal := "N"
	if heading_degrees >= 22.5 and heading_degrees < 67.5:
		cardinal = "NE"
	elif heading_degrees < 112.5:
		cardinal = "E"
	elif heading_degrees < 157.5:
		cardinal = "SE"
	elif heading_degrees < 202.5:
		cardinal = "S"
	elif heading_degrees < 247.5:
		cardinal = "SW"
	elif heading_degrees < 292.5:
		cardinal = "W"
	elif heading_degrees < 337.5:
		cardinal = "NW"
	et_compass_label.text = "%s · %03d°" % [
		cardinal,
		int(round(heading_degrees))
	]

	var objective_position := global_position
	if int(main.get("objective_stage")) == 0:
		var bridge_site := main.get_node_or_null("BridgeBuildSite") as Node3D
		if bridge_site != null:
			objective_position = bridge_site.global_position
	else:
		var objective_node := main.get_node_or_null("Objective") as Node3D
		if objective_node != null:
			objective_position = objective_node.global_position
	et_objective_distance_label.text = "OBJECTIVE %dm" % int(round(
		global_position.distance_to(objective_position)
	))

	var objective_local: Vector3 = global_transform.basis.inverse() * (
		objective_position - global_position
	)
	var horizontal_angle: float = atan2(
		objective_local.x,
		-objective_local.z
	)
	if absf(horizontal_angle) < 0.22:
		et_objective_arrow_label.text = "▲"
	elif horizontal_angle > 0.0:
		et_objective_arrow_label.text = "▶"
	else:
		et_objective_arrow_label.text = "◀"

	if Time.get_ticks_msec() < collision_debug_notice_until_ms:
		et_route_hint_label.text = (
			"COLLISION AUDIT ACTIVE AFTER RESTART"
		)
	else:
		var route_text := (
			"NORTH · CENTER · SOUTH · SEWER"
			if int(main.get("objective_stage")) == 0
			else "RAIL YARD · FORT · SOUTH ANNEX"
		)
		var squad_order := "REGROUP"
		if main.has_method("squad_order_text"):
			squad_order = str(
				main.call("squad_order_text", team)
			)
		et_route_hint_label.text = "%s · ORDER: %s" % [
			route_text,
			squad_order
		]

	et_team_label.text = "%s · %s" % [
		team_name,
		str(names[player_class]).to_upper()
	]
	et_health_label.text = "✚ %d HP" % health
	et_stamina_label.text = "STAMINA %d%% · %s" % [
		int(round(replicated_stamina)),
		stance_name
	]
	et_rank_label.text = "%s · %d XP" % [rank_name(), xp]
	et_weapon_label.text = _weapon_display_name().to_upper()
	et_ammo_label.text = "%d / %d" % [ammo_in_mag, reserve_ammo]
	et_grenade_label.text = "GRENADES %d · SMOKE %d" % [
		grenades_remaining,
		replicated_smoke_grenades
	]
	if Time.get_ticks_msec() < collision_debug_notice_until_ms:
		et_status_label.text = (
			"COLLISION DEBUG CHANGED · RESTART TO REBUILD PROXIES"
		)
	else:
		et_status_label.text = "%s · %s · Q %s · F6 CINEMA" % [
			life_name,
			str(main.call("sector_status_text")),
			_ability_name()
		]

	var round_results_open := false
	if main.has_method("get"):
		var results_panel: PanelContainer = (
			main.get("round_results_panel") as PanelContainer
		)
		if results_panel != null:
			round_results_open = results_panel.visible

	var hud_visible: bool = (
		not cinema_mode_enabled
		and not scoreboard.visible
		and not tactical_map_open
		and not spawn_menu_open
		and not round_results_open
	)
	et_hud_root.visible = hud_visible
	if radar_panel != null:
		radar_panel.visible = hud_visible

func _apply_cinema_mode_visibility() -> void:
	# Scoreboard remains usable in cinema mode. Everything else in the regular
	# combat presentation can be hidden/restored with F6.
	var show_game_hud: bool = not cinema_mode_enabled

	if et_hud_root != null:
		et_hud_root.visible = (
			show_game_hud
			and not scoreboard.visible
			and not tactical_map_open
			and not spawn_menu_open
		)

	if radar_panel != null:
		radar_panel.visible = (
			show_game_hud
			and not scoreboard.visible
			and not tactical_map_open
			and not spawn_menu_open
		)

	if feed != null:
		feed.visible = show_game_hud
	if class_role_panel != null:
		class_role_panel.visible = show_game_hud and alive

	if objective_progress_text != null:
		objective_progress_text.visible = show_game_hud
	if objective_progress_bar != null:
		objective_progress_bar.visible = show_game_hud
	if mission_banner != null and cinema_mode_enabled:
		mission_banner.visible = false

	if suppression_overlay != null and cinema_mode_enabled:
		suppression_overlay.visible = false

	# Keep the actual aiming crosshair available only in normal game mode.
	if et_crosshair_ring != null:
		et_crosshair_ring.visible = show_game_hud
	if crosshair != null:
		crosshair.visible = false


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	hud_canvas_layer = layer
	add_child(layer)
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
	objective_progress_text.position = Vector2(430, 603)
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
	objective_progress_bar.position = Vector2(430, 632)
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

	tactical_map_panel = PanelContainer.new()
	tactical_map_panel.position = Vector2(310, 105)
	tactical_map_panel.custom_minimum_size = Vector2(660, 500)
	tactical_map_panel.visible = false
	layer.add_child(tactical_map_panel)

	var tactical_box := VBoxContainer.new()
	tactical_map_panel.add_child(tactical_box)

	var tactical_title := Label.new()
	tactical_title.text = "TACTICAL MAP · K TO CLOSE"
	tactical_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tactical_title.add_theme_font_size_override("font_size", 25)
	tactical_box.add_child(tactical_title)

	tactical_map_label = Label.new()
	tactical_map_label.custom_minimum_size = Vector2(620, 420)
	tactical_map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tactical_map_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tactical_map_label.add_theme_font_size_override("font_size", 20)
	tactical_box.add_child(tactical_map_label)

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
	radar_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	radar_panel.position = Vector2(-202, 18)
	radar_panel.size = Vector2(184, 184)
	radar_panel.clip_contents = false
	radar_panel.visible = false
	layer.add_child(radar_panel)

	radar_frame_rect = Control.new()
	radar_frame_rect.name = "NativeCompass"
	radar_frame_rect.set_script(RadarCompassScript)
	radar_frame_rect.position = Vector2.ZERO
	radar_frame_rect.size = Vector2(184, 184)
	radar_frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radar_panel.add_child(radar_frame_rect)

	var radar_title := Label.new()
	radar_title.text = "FIELD COMPASS"
	radar_title.position = Vector2(30, 6)
	radar_title.custom_minimum_size = Vector2(124, 20)
	radar_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	radar_title.add_theme_font_size_override("font_size", 11)
	radar_title.add_theme_color_override(
		"font_color",
		Color(0.90, 0.86, 0.68)
	)
	radar_panel.add_child(radar_title)

	radar_objective = Label.new()
	radar_objective.text = ""
	radar_objective.visible = false
	radar_panel.add_child(radar_objective)

	scoreboard = Label.new()
	scoreboard.position = Vector2(210, 100)
	scoreboard.custom_minimum_size = Vector2(860, 520)
	scoreboard.add_theme_font_size_override("font_size", 14)
	scoreboard.visible = false
	layer.add_child(scoreboard)
	feed = Label.new()
	feed.position = Vector2(805, 205)
	feed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	feed.custom_minimum_size = Vector2(455, 150)
	feed.add_theme_font_size_override("font_size", 15)
	feed.add_theme_color_override(
		"font_color",
		Color(0.95, 0.93, 0.84)
	)
	feed.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.92)
	)
	feed.add_theme_constant_override("shadow_offset_x", 2)
	feed.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(feed)

	# Framed TAB results panel.
	scoreboard_panel = PanelContainer.new()
	scoreboard_panel.position = Vector2(185, 62)
	scoreboard_panel.size = Vector2(910, 590)
	scoreboard_panel.add_theme_stylebox_override(
		"panel",
		_hud_panel_style(
			Color(0.025, 0.030, 0.028, 0.94),
			Color(0.53, 0.48, 0.30, 0.98),
			3,
			8
		)
	)
	scoreboard_panel.visible = false
	layer.add_child(scoreboard_panel)
	scoreboard.reparent(scoreboard_panel)
	scoreboard.position = Vector2.ZERO
	scoreboard.custom_minimum_size = Vector2(870, 550)
	scoreboard.add_theme_font_size_override("font_size", 14)
	scoreboard.add_theme_color_override(
		"font_color",
		Color(0.93, 0.91, 0.82)
	)
	scoreboard.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.90)
	)
	scoreboard.add_theme_constant_override("shadow_offset_x", 2)
	scoreboard.add_theme_constant_override("shadow_offset_y", 2)

	_build_et_style_hud(layer)
	_apply_resolution_safe_hud()

	# Dead-player reinforcement queue panel. Hidden while alive.
	reinforcement_death_panel = PanelContainer.new()
	reinforcement_death_panel.name = "ReinforcementDeathPanel"
	reinforcement_death_panel.position = Vector2(430, 300)
	reinforcement_death_panel.custom_minimum_size = Vector2(420, 86)

	var reinforcement_style := StyleBoxFlat.new()
	reinforcement_style.bg_color = Color(0.025, 0.028, 0.027, 0.82)
	reinforcement_style.border_color = Color(0.56, 0.52, 0.36, 0.68)
	reinforcement_style.set_border_width_all(1)
	reinforcement_style.corner_radius_top_left = 5
	reinforcement_style.corner_radius_top_right = 5
	reinforcement_style.corner_radius_bottom_left = 5
	reinforcement_style.corner_radius_bottom_right = 5
	reinforcement_death_panel.add_theme_stylebox_override(
		"panel",
		reinforcement_style
	)

	var reinforcement_margin := MarginContainer.new()
	reinforcement_margin.add_theme_constant_override("margin_left", 14)
	reinforcement_margin.add_theme_constant_override("margin_right", 14)
	reinforcement_margin.add_theme_constant_override("margin_top", 10)
	reinforcement_margin.add_theme_constant_override("margin_bottom", 10)
	reinforcement_death_panel.add_child(reinforcement_margin)

	reinforcement_death_label = Label.new()
	reinforcement_death_label.name = "ReinforcementDeathLabel"
	reinforcement_death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reinforcement_death_label.add_theme_font_size_override("font_size", 18)
	reinforcement_death_label.add_theme_constant_override("outline_size", 6)
	reinforcement_death_label.modulate = Color(0.94, 0.90, 0.72)
	reinforcement_margin.add_child(reinforcement_death_label)

	if hud_canvas_layer != null:
		hud_canvas_layer.add_child(reinforcement_death_panel)
	else:
		add_child(reinforcement_death_panel)
	reinforcement_death_panel.visible = false

	# v8.98 class-role HUD. Lightweight 2D-only presentation.
	class_role_panel = PanelContainer.new()
	class_role_panel.name = "ClassRolePanel"
	class_role_panel.position = Vector2(22, 505)
	class_role_panel.custom_minimum_size = Vector2(300, 58)

	var class_style := StyleBoxFlat.new()
	class_style.bg_color = Color(0.03, 0.035, 0.034, 0.72)
	class_style.border_color = Color(0.42, 0.46, 0.38, 0.48)
	class_style.set_border_width_all(1)
	class_style.corner_radius_top_left = 4
	class_style.corner_radius_top_right = 4
	class_style.corner_radius_bottom_left = 4
	class_style.corner_radius_bottom_right = 4
	class_role_panel.add_theme_stylebox_override("panel", class_style)

	var class_margin := MarginContainer.new()
	class_margin.add_theme_constant_override("margin_left", 10)
	class_margin.add_theme_constant_override("margin_right", 10)
	class_margin.add_theme_constant_override("margin_top", 7)
	class_margin.add_theme_constant_override("margin_bottom", 7)
	class_role_panel.add_child(class_margin)

	var class_stack := VBoxContainer.new()
	class_stack.add_theme_constant_override("separation", 1)
	class_margin.add_child(class_stack)

	class_role_label = Label.new()
	class_role_label.name = "ClassRoleLabel"
	class_role_label.add_theme_font_size_override("font_size", 14)
	class_role_label.add_theme_constant_override("outline_size", 4)
	class_role_label.modulate = Color(0.90, 0.88, 0.76)
	class_stack.add_child(class_role_label)

	class_role_prompt = Label.new()
	class_role_prompt.name = "ClassRolePrompt"
	class_role_prompt.add_theme_font_size_override("font_size", 12)
	class_role_prompt.add_theme_constant_override("outline_size", 3)
	class_role_prompt.modulate = Color(0.76, 0.80, 0.72)
	class_stack.add_child(class_role_prompt)

	if hud_canvas_layer != null:
		hud_canvas_layer.add_child(class_role_panel)
	else:
		add_child(class_role_panel)

	vehicle_hud_panel = PanelContainer.new()
	vehicle_hud_panel.name = "VehicleHUDPanel"
	vehicle_hud_panel.position = Vector2(470, 590)
	vehicle_hud_panel.custom_minimum_size = Vector2(340, 62)

	var vehicle_style := StyleBoxFlat.new()
	vehicle_style.bg_color = Color(0.025, 0.03, 0.028, 0.78)
	vehicle_style.border_color = Color(0.55, 0.52, 0.36, 0.58)
	vehicle_style.set_border_width_all(1)
	vehicle_hud_panel.add_theme_stylebox_override("panel", vehicle_style)

	var vehicle_margin := MarginContainer.new()
	vehicle_margin.add_theme_constant_override("margin_left", 12)
	vehicle_margin.add_theme_constant_override("margin_right", 12)
	vehicle_margin.add_theme_constant_override("margin_top", 7)
	vehicle_margin.add_theme_constant_override("margin_bottom", 7)
	vehicle_hud_panel.add_child(vehicle_margin)

	vehicle_hud_label = Label.new()
	vehicle_hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_hud_label.add_theme_font_size_override("font_size", 15)
	vehicle_hud_label.add_theme_constant_override("outline_size", 4)
	vehicle_margin.add_child(vehicle_hud_label)

	if hud_canvas_layer != null:
		hud_canvas_layer.add_child(vehicle_hud_panel)
	else:
		add_child(vehicle_hud_panel)
	vehicle_hud_panel.visible = false

	vehicle_gunsight = Label.new()
	vehicle_gunsight.name = "VehicleGunsight"
	vehicle_gunsight.text = "⊕"
	vehicle_gunsight.position = Vector2(620, 332)
	vehicle_gunsight.add_theme_font_size_override("font_size", 28)
	vehicle_gunsight.add_theme_constant_override("outline_size", 5)
	vehicle_gunsight.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_gunsight.custom_minimum_size = Vector2(40, 40)
	vehicle_gunsight.visible = false

	if hud_canvas_layer != null:
		hud_canvas_layer.add_child(vehicle_gunsight)
	else:
		add_child(vehicle_gunsight)

func _radar_position(world_position: Vector3, radius_meters: float = 42.0) -> Vector2:
	var relative: Vector3 = world_position - global_position
	relative.y = 0.0
	var local_x: float = relative.dot(global_transform.basis.x)
	var local_forward: float = relative.dot(-global_transform.basis.z)
	var scale_factor: float = 58.0 / radius_meters
	var result := Vector2(
		92.0 + clampf(local_x * scale_factor, -58.0, 58.0),
		92.0 - clampf(local_forward * scale_factor, -58.0, 58.0)
	)
	var centered: Vector2 = result - Vector2(92.0, 92.0)
	if centered.length() > 58.0:
		centered = centered.normalized() * 58.0
	return centered + Vector2(92.0, 92.0)

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

	if radar_frame_rect != null and radar_frame_rect.has_method(
		"set_compass_state"
	):
		var objective_relative: Vector3 = (
			objective_position - global_position
		)
		var objective_bearing: float = fposmod(
			rad_to_deg(
				atan2(
					objective_relative.x,
					-objective_relative.z
				)
			),
			360.0
		)
		var heading: float = fposmod(
			rad_to_deg(rotation.y) + 180.0,
			360.0
		)
		radar_frame_rect.call(
			"set_compass_state",
			heading,
			(
				Color(0.18, 0.72, 1.0)
				if team == 0
				else Color(1.0, 0.28, 0.20)
			),
			objective_bearing,
			true
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

func _first_person_part(node_name: String) -> Node3D:
	if weapon_view == null:
		return null
	return weapon_view.find_child(node_name, true, false) as Node3D

func _set_first_person_part_offset(
	node_name: String,
	position_offset: Vector3,
	rotation_offset: Vector3 = Vector3.ZERO
) -> void:
	var part := _first_person_part(node_name)
	if part == null:
		return
	if not part.has_meta("v822_base_position"):
		part.set_meta("v822_base_position", part.position)
		part.set_meta("v822_base_rotation", part.rotation)
	var base_position := part.position
	var stored_position: Variant = part.get_meta(
		"v822_base_position",
		part.position
	)
	if stored_position is Vector3:
		base_position = stored_position
	var base_rotation := part.rotation
	var stored_rotation: Variant = part.get_meta(
		"v822_base_rotation",
		part.rotation
	)
	if stored_rotation is Vector3:
		base_rotation = stored_rotation
	part.position = base_position + position_offset
	part.rotation = base_rotation + rotation_offset

func _update_first_person_mechanics(delta: float) -> void:
	if is_reloading:
		if not visual_was_reloading:
			visual_reload_progress = 0.0
		visual_reload_progress = minf(
			1.0,
			visual_reload_progress
			+ delta / maxf(_weapon_reload_seconds(), 0.10)
		)
	else:
		visual_reload_progress = 0.0
	visual_was_reloading = is_reloading

	var reload_arc := sin(visual_reload_progress * PI)
	var magazine_drop := 0.0
	if is_reloading:
		if visual_reload_progress < 0.42:
			magazine_drop = smoothstep(
				0.08,
				0.42,
				visual_reload_progress
			)
		elif visual_reload_progress < 0.72:
			magazine_drop = 1.0
		else:
			magazine_drop = 1.0 - smoothstep(
				0.72,
				0.96,
				visual_reload_progress
			)

	var now := Time.get_ticks_msec()
	var shot_cycle := 0.0
	if now < muzzle_flash_until_ms:
		var shot_progress := 1.0 - clampf(
			float(muzzle_flash_until_ms - now) / 55.0,
			0.0,
			1.0
		)
		shot_cycle = sin(shot_progress * PI)
	var reload_bolt := smoothstep(
		0.82,
		0.94,
		visual_reload_progress
	) * (1.0 - smoothstep(0.94, 1.0, visual_reload_progress))
	var bolt_travel := maxf(shot_cycle, reload_bolt)

	_set_first_person_part_offset(
		"PistolSlide",
		Vector3(0.0, 0.0, 0.105 * bolt_travel)
	)
	_set_first_person_part_offset(
		"BoltCarrier",
		Vector3(0.0, 0.0, 0.12 * bolt_travel)
	)
	_set_first_person_part_offset(
		"ChargingHandle",
		Vector3(0.0, 0.0, 0.12 * bolt_travel)
	)
	for magazine_name in [
		"Magazine",
		"MagazineBase",
		"MagazineFloorPlate",
		"PistolMagazine",
		"SMGMagazine",
		"SMGMagazineBase",
		"CarbineMagazine",
		"CarbineMagazineBase",
		"LMGDrumMagazine"
	]:
		_set_first_person_part_offset(
			magazine_name,
			Vector3(0.08 * magazine_drop, 0.32 * magazine_drop, 0.0),
			Vector3(0.0, 0.0, 0.22 * magazine_drop)
		)
	_set_first_person_part_offset(
		"LeftArm",
		Vector3(0.11 * reload_arc, 0.10 * reload_arc, 0.12 * reload_arc),
		Vector3(0.0, -0.18 * reload_arc, 0.22 * reload_arc)
	)
	_set_first_person_part_offset(
		"LeftSupportArm",
		Vector3(0.08 * reload_arc, 0.08 * reload_arc, 0.10 * reload_arc),
		Vector3(0.0, -0.14 * reload_arc, 0.18 * reload_arc)
	)

func _first_person_obstruction_fraction() -> float:
	var view_camera := get_node_or_null("Head/Camera3D") as Camera3D
	if view_camera == null or get_world_3d() == null:
		return 0.0
	var ray_start: Vector3 = view_camera.global_position
	var ray_end: Vector3 = (
		ray_start - view_camera.global_transform.basis.z * 1.15
	)
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [self]
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var hit: Dictionary = (
		get_world_3d().direct_space_state.intersect_ray(query)
	)
	if hit.is_empty():
		return 0.0
	var hit_position_value: Variant = hit.get("position")
	if not hit_position_value is Vector3:
		return 0.0
	var hit_position: Vector3 = hit_position_value
	var hit_distance: float = ray_start.distance_to(hit_position)
	return 1.0 - clampf((hit_distance - 0.24) / 0.82, 0.0, 1.0)

func _update_first_person_animation(delta: float) -> void:
	if weapon_view == null or not _is_local_player():
		return
	visual_animation_time += delta
	var heat_decay: float = (
		0.10
		if Time.get_ticks_msec() - visual_last_shot_ms < 240
		else 0.28
	)
	visual_weapon_heat = move_toward(
		visual_weapon_heat,
		0.0,
		delta * heat_decay
	)
	camera_inertia = camera_inertia.lerp(
		Vector2.ZERO,
		1.0 - exp(-8.0 * delta)
	)
	var speed: float = Vector2(velocity.x, velocity.z).length()
	var moving: bool = speed > 0.8 and is_on_floor()
	var visual_aiming: bool = is_aiming or aim_requested
	var sprinting: bool = moving and sprint_requested and replicated_stamina > 1.0 and not visual_aiming
	var grounded := is_on_floor()
	if grounded and not visual_was_on_floor:
		visual_landing_impulse = clampf(
			absf(visual_previous_vertical_velocity) * 0.012,
			0.0,
			0.13
		)
	visual_was_on_floor = grounded
	visual_previous_vertical_velocity = velocity.y
	visual_landing_impulse = move_toward(
		visual_landing_impulse,
		0.0,
		delta * 0.72
	)
	var target_position: Vector3 = weapon_base_position + recoil_position_impulse
	var target_rotation: Vector3 = weapon_base_rotation + recoil_rotation_impulse
	if visual_aiming:
		target_position = (
			_aim_weapon_position() + recoil_position_impulse * 0.64
		)
		target_rotation = (
			_aim_weapon_rotation() + recoil_rotation_impulse * 0.72
		)
	var landing_scale: float = 0.35 if visual_aiming else 1.0
	target_position.y -= visual_landing_impulse * landing_scale
	target_rotation.x += visual_landing_impulse * 0.65 * landing_scale
	recoil_position_impulse = recoil_position_impulse.lerp(Vector3.ZERO,1.0-exp(-18.0*delta))
	recoil_rotation_impulse = recoil_rotation_impulse.lerp(Vector3.ZERO,1.0-exp(-15.0*delta))
	if moving:
		var frequency: float = 11.0 if sprinting else 7.5
		var amount: float = 0.035 if sprinting else 0.020
		if visual_aiming:
			amount *= 0.18
		target_position.x += sin(visual_animation_time * frequency) * amount
		target_position.y += absf(cos(visual_animation_time * frequency)) * amount * 0.65
		target_rotation.z += sin(visual_animation_time * frequency) * 0.018
	if sprinting:
		target_position.y -= 0.12
		target_position.z += 0.16
		target_rotation.x += 0.28
		target_rotation.z -= 0.12
	elif visual_aiming:
		var breathing: float = sin(visual_animation_time * 1.25)
		target_position.y += breathing * 0.0012
		target_rotation.x += breathing * 0.0015
		target_rotation.y += cos(visual_animation_time * 0.95) * 0.0010
	elif is_reloading:
		var reload_motion := sin(visual_animation_time * 4.8)
		target_position.y -= 0.20
		target_position.x += 0.10 + reload_motion * 0.035
		target_position.z += 0.10
		target_rotation.x += 0.32
		target_rotation.y -= 0.18 + reload_motion * 0.055
		target_rotation.z += 0.30
	else:
		target_rotation.y += sin(visual_animation_time * 1.4) * 0.008
		target_rotation.x += cos(visual_animation_time * 1.1) * 0.006
	var obstruction: float = _first_person_obstruction_fraction()
	target_position.y -= obstruction * 0.11
	target_position.z += obstruction * 0.15
	target_rotation.x += obstruction * 0.24
	target_rotation.z -= obstruction * 0.08

	var inertia_scale: float = 0.28 if visual_aiming else 1.0
	target_rotation.y += camera_inertia.x * 0.008 * inertia_scale
	target_rotation.x += camera_inertia.y * 0.006 * inertia_scale
	target_position.x += camera_inertia.x * 0.004 * inertia_scale
	target_position.y -= absf(camera_inertia.y) * 0.002 * inertia_scale
	# Keep the complete weapon, sleeve, and hand hierarchy in front of the
	# camera near plane even during sprint, reload, recoil, and wall lowering.
	target_position.z = minf(target_position.z, -0.50)
	var position_speed: float = 16.0 if visual_aiming else 10.0
	var rotation_speed: float = 15.0 if visual_aiming else 9.0
	weapon_view.position = weapon_view.position.lerp(target_position, clampf(delta * position_speed,0.0,1.0))
	weapon_view.rotation = weapon_view.rotation.lerp(target_rotation, clampf(delta * rotation_speed,0.0,1.0))
	_update_first_person_mechanics(delta)

	# v8.88 handling layer: slight sprint lower and reload cant. These offsets
	# are intentionally small and apply on top of the existing pose system.
	if weapon_view != null and not is_aiming:
		var sprint_blend: float = (
			1.0
			if sprint_requested and velocity.length() > WALK_SPEED * 0.80
			else 0.0
		)
		var reload_blend: float = 1.0 if is_reloading else 0.0

		var desired_offset := Vector3(
			0.025 * sprint_blend,
			-0.055 * sprint_blend - 0.025 * reload_blend,
			0.055 * sprint_blend
		)
		weapon_view.position = weapon_view.position.lerp(
			weapon_base_position + desired_offset,
			clampf(get_process_delta_time() * 8.0, 0.0, 1.0)
		)

		var desired_rotation := weapon_base_rotation + Vector3(
			4.0 * reload_blend,
			0.0,
			-6.0 * sprint_blend - 5.0 * reload_blend
		)
		weapon_view.rotation_degrees = weapon_view.rotation_degrees.lerp(
			desired_rotation,
			clampf(get_process_delta_time() * 7.0, 0.0, 1.0)
		)

func _visual_part(node_name: String) -> Node3D:
	var character_visual: Node3D = (
		get_node_or_null("CharacterVisual") as Node3D
	)
	if character_visual == null:
		return null
	return character_visual.get_node_or_null(node_name) as Node3D

func _visual_is_grounded() -> bool:
	if is_on_floor():
		return true
	if get_world_3d() == null:
		return absf(velocity.y) < 0.15
	var ray_start := global_position + Vector3.UP * 0.12
	var query := PhysicsRayQueryParameters3D.create(
		ray_start,
		global_position - Vector3.UP * 0.24
	)
	query.exclude = [self]
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _update_world_character_animation(delta: float) -> void:
	_update_external_character_animation()
	visual_damage_reaction = move_toward(visual_damage_reaction, 0.0, delta * 3.4)
	visual_revive_recovery = move_toward(visual_revive_recovery, 0.0, delta * 0.9)
	visual_incapacitation_impact = move_toward(visual_incapacitation_impact, 0.0, delta * 2.0)
	var character_visual: Node3D = (
		get_node_or_null("CharacterVisual") as Node3D
	)
	if character_visual == null:
		return

	var planar_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var speed: float = planar_velocity.length()
	var speed_ratio: float = clampf(speed / SPRINT_SPEED, 0.0, 1.0)
	var grounded := _visual_is_grounded()
	if visual_world_was_grounded and not grounded:
		visual_world_takeoff_impulse = 1.0
	elif not visual_world_was_grounded and grounded:
		visual_world_landing_impulse = clampf(
			absf(visual_world_vertical_motion) * 0.55,
			0.28,
			1.0
		)
	visual_world_was_grounded = grounded
	visual_world_airborne = lerpf(
		visual_world_airborne,
		0.0 if grounded else 1.0,
		1.0 - exp(-(16.0 if grounded else 10.0) * delta)
	)
	visual_world_vertical_motion = lerpf(
		visual_world_vertical_motion,
		clampf(velocity.y / maxf(JUMP_SPEED, 0.001), -1.0, 1.0),
		1.0 - exp(-12.0 * delta)
	)
	visual_world_takeoff_impulse = move_toward(
		visual_world_takeoff_impulse,
		0.0,
		delta * 4.8
	)
	visual_world_landing_impulse = move_toward(
		visual_world_landing_impulse,
		0.0,
		delta * 3.8
	)
	visual_world_stance_blend = lerpf(
		visual_world_stance_blend,
		1.0 if is_crouching else 0.0,
		1.0 - exp(-11.0 * delta)
	)
	visual_world_aim_blend = lerpf(
		visual_world_aim_blend,
		1.0 if aim_requested or is_aiming or visual_world_aim_hold > 0.0 else 0.0,
		1.0 - exp(-15.0 * delta)
	)
	visual_world_aim_hold = move_toward(
		visual_world_aim_hold,
		0.0,
		delta * 2.8
	)
	visual_world_fire_recoil = move_toward(
		visual_world_fire_recoil,
		0.0,
		delta * 7.5
	)
	if is_reloading:
		if not visual_world_was_reloading:
			visual_world_reload_progress = 0.0
		visual_world_reload_progress = move_toward(
			visual_world_reload_progress,
			1.0,
			delta / maxf(_weapon_reload_seconds(), 0.10)
		)
	else:
		visual_world_reload_progress = 0.0
	visual_world_was_reloading = is_reloading
	var local_velocity: Vector3 = global_transform.basis.inverse() * planar_velocity
	var target_forward := 0.0
	var target_strafe := 0.0
	if speed > 0.05:
		target_forward = clampf(-local_velocity.z / speed, -1.0, 1.0)
		target_strafe = clampf(local_velocity.x / speed, -1.0, 1.0)
	visual_forward_motion = lerpf(
		visual_forward_motion,
		target_forward,
		1.0 - exp(-10.0 * delta)
	)
	visual_strafe_motion = lerpf(
		visual_strafe_motion,
		target_strafe,
		1.0 - exp(-10.0 * delta)
	)
	var acceleration_scale := maxf(SPRINT_SPEED * maxf(delta, 0.001), 0.001)
	var target_acceleration := clampf(
		(planar_velocity - visual_previous_planar_velocity).dot(
			planar_velocity.normalized() if speed > 0.05 else Vector3.ZERO
		) / acceleration_scale,
		-1.0,
		1.0
	)
	visual_acceleration_motion = lerpf(
		visual_acceleration_motion,
		target_acceleration,
		1.0 - exp(-8.0 * delta)
	)
	visual_previous_planar_velocity = planar_velocity
	if not visual_yaw_initialized:
		visual_last_body_yaw = rotation.y
		visual_yaw_initialized = true
	var yaw_delta := angle_difference(visual_last_body_yaw, rotation.y)
	var target_turn := clampf(yaw_delta / maxf(delta * 4.0, 0.001), -1.0, 1.0)
	visual_turn_motion = lerpf(
		visual_turn_motion,
		target_turn,
		1.0 - exp(-12.0 * delta)
	)
	visual_last_body_yaw = rotation.y
	var target_phase_speed: float = lerpf(4.8, 9.4, speed_ratio)
	visual_stride_phase += delta * target_phase_speed
	visual_last_speed = lerpf(
		visual_last_speed,
		speed,
		1.0 - exp(-8.0 * delta)
	)

	var moving: bool = (
		alive
		and visual_last_speed > 0.35
		and visual_world_airborne < 0.82
	)
	var stride: float = sin(visual_stride_phase)
	var opposite_stride: float = sin(visual_stride_phase + PI)
	var stride_amount: float = (
		lerpf(0.10, 0.48, speed_ratio)
		if moving
		else 0.0
	)
	var arm_amount: float = stride_amount * 0.82
	var crouch_offset: float = -0.34 * visual_world_stance_blend
	var body_bob: float = (
		absf(sin(visual_stride_phase * 2.0))
		* lerpf(0.005, 0.035, speed_ratio)
		* (1.0 - visual_world_airborne)
		if moving
		else 0.0
	)

	character_visual.position.y = lerpf(
		character_visual.position.y,
		crouch_offset + body_bob,
		1.0 - exp(-12.0 * delta)
	)
	character_visual.rotation.z = lerpf(
		character_visual.rotation.z,
		stride * 0.025 * speed_ratio,
		1.0 - exp(-9.0 * delta)
	)

	var arm_l := _visual_part("ArmL")
	var arm_r := _visual_part("ArmR")
	var leg_l := _visual_part("LegL")
	var leg_r := _visual_part("LegR")
	var pack := _visual_part("Pack")
	var head := _visual_part("Head")
	var helmet := _visual_part("Helmet")

	if arm_l != null:
		arm_l.rotation.x = lerpf(
			arm_l.rotation.x,
			opposite_stride * arm_amount,
			1.0 - exp(-13.0 * delta)
		)
	if arm_r != null:
		arm_r.rotation.x = lerpf(
			arm_r.rotation.x,
			stride * arm_amount,
			1.0 - exp(-13.0 * delta)
		)
	if leg_l != null:
		leg_l.rotation.x = lerpf(
			leg_l.rotation.x,
			stride * stride_amount,
			1.0 - exp(-14.0 * delta)
		)
	if leg_r != null:
		leg_r.rotation.x = lerpf(
			leg_r.rotation.x,
			opposite_stride * stride_amount,
			1.0 - exp(-14.0 * delta)
		)
	if pack != null:
		pack.rotation.z = lerpf(
			pack.rotation.z,
			-stride * 0.035 * speed_ratio,
			1.0 - exp(-8.0 * delta)
		)
	if head != null:
		head.rotation.y = lerpf(
			head.rotation.y,
			stride * 0.025 * speed_ratio,
			1.0 - exp(-10.0 * delta)
		)
	if helmet != null:
		helmet.rotation.y = head.rotation.y if head != null else 0.0

	if class_accent_mesh != null:
		class_accent_mesh.rotation.z = lerpf(
			class_accent_mesh.rotation.z,
			stride * 0.035 * speed_ratio,
			1.0 - exp(-10.0 * delta)
		)

	ThirdPersonPoseFidelityScript.apply(
		character_visual,
		delta,
		visual_animation_time,
		speed_ratio,
		stride,
		moving,
		is_crouching,
		aim_requested or is_aiming,
		is_reloading,
		alive,
		downed,
		visual_damage_reaction,
		visual_damage_side,
		visual_revive_recovery,
		visual_incapacitation_impact,
		visual_forward_motion,
		visual_strafe_motion,
		visual_turn_motion,
		visual_acceleration_motion,
		visual_world_airborne,
		visual_world_vertical_motion,
		visual_world_takeoff_impulse,
		visual_world_landing_impulse,
		visual_world_stance_blend,
		clampf($Head.rotation.x, -1.10, 1.10),
		visual_world_aim_blend,
		visual_world_fire_recoil,
		visual_world_reload_progress
	)

func register_world_shot_recoil() -> void:
	if DisplayServer.get_name() == "headless":
		return
	visual_world_fire_recoil = clampf(
		visual_world_fire_recoil + 0.72,
		0.0,
		1.0
	)
	visual_world_aim_hold = 1.0

func _register_visual_damage(amount: int, source_id: int = 0) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var impulse := clampf(float(maxi(1, amount)) / 45.0, 0.22, 0.80)
	visual_damage_reaction = clampf(visual_damage_reaction + impulse, 0.0, 1.0)
	visual_damage_side = -1.0 if posmod(source_id + peer_id, 2) == 0 else 1.0

func _register_visual_revive() -> void:
	if DisplayServer.get_name() == "headless":
		return
	visual_revive_recovery = 1.0
	visual_damage_reaction = 0.0
	visual_incapacitation_impact = 0.0

func _update_reinforcement_death_panel() -> void:
	if reinforcement_death_panel == null:
		return

	var show_panel := (
		not alive
		and not cinema_mode_enabled
		and not scoreboard.visible
		and not spawn_menu_open
		and not tactical_map_open
	)

	reinforcement_death_panel.visible = show_panel
	if not show_panel or reinforcement_death_label == null:
		return

	var main: Node = get_parent()
	var seconds := 0
	if (
		main != null
		and main.has_method("team_spawn_wave_remaining")
	):
		seconds = maxi(
			0,
			int(ceil(float(
				main.call(
					"team_spawn_wave_remaining",
					team
				)
			)))
		)

	reinforcement_death_label.text = (
		"WAITING FOR REINFORCEMENTS · %ds\n"
		+ "M CLASS / TEAM · TAB SCOREBOARD"
	) % seconds


func _class_role_name() -> String:
	match player_class:
		PlayerClass.SOLDIER:
			return "SOLDIER · ASSAULT"
		PlayerClass.MEDIC:
			return "MEDIC · SUPPORT"
		PlayerClass.ENGINEER:
			return "ENGINEER · OBJECTIVE"
		PlayerClass.FIELD_OPS:
			return "FIELD OPS · FIRE SUPPORT"
		PlayerClass.SCOUT:
			return "SCOUT · RECON"
		_:
			return "CLASS"


func _class_role_prompt_text() -> String:
	var ready_text := "READY"
	var remaining_ms := maxi(
		0,
		next_ability_time - Time.get_ticks_msec()
	)
	if remaining_ms > 0:
		ready_text = "%.1fs" % (float(remaining_ms) / 1000.0)

	match player_class:
		PlayerClass.SOLDIER:
			return "Q HEAVY FIRE · %s · LEAD THE PUSH" % ready_text
		PlayerClass.MEDIC:
			return "Q REVIVE PULSE · %s · E REVIVE" % ready_text
		PlayerClass.ENGINEER:
			return "Q FIELD BUILD · %s · E OBJECTIVE" % ready_text
		PlayerClass.FIELD_OPS:
			return "Q ARTILLERY · %s · RESUPPLY TEAM" % ready_text
		PlayerClass.SCOUT:
			return "Q SENSOR · %s · MOUSE2 ZOOM" % ready_text
		_:
			return "Q ABILITY · %s" % ready_text


func _update_class_role_hud() -> void:
	if class_role_panel == null:
		return

	var round_results_open: bool = false
	var main_node: Node = get_parent()
	if main_node != null:
		var results_panel_value: Variant = main_node.get("round_results_panel")
		if results_panel_value is PanelContainer:
			round_results_open = (
				results_panel_value as PanelContainer
			).visible

	var visible_state: bool = (
		alive
		and not cinema_mode_enabled
		and not scoreboard.visible
		and not tactical_map_open
		and not spawn_menu_open
		and not round_results_open
	)

	class_role_panel.visible = visible_state
	if not visible_state:
		return

	if class_role_label != null:
		class_role_label.text = _class_role_name()

	if class_role_prompt != null:
		class_role_prompt.text = _class_role_prompt_text()


func _update_hud() -> void:
	if hud == null:
		return

	_apply_resolution_safe_hud()
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

	if tactical_map_label != null and main != null:
		tactical_map_label.text = str(
			main.call("tactical_map_text")
		)

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
	hud.text = "%s | %s | %s\n%s · %s · Stamina %d%%\nHP %d  Ammo %d/%d  %s [%d/%d]  Grenades %d  Smoke %d  %s\nLoadout: %s + Service Pistol\n%s\n%s  Time %02d:%02d\nClass: %s  XP %d (%s)  Q: %s [%s]  RMB: aim/zoom  G: grenade  X: switch  E: interact  M: spawn menu  K: map  MMB: ping  B: smoke  C: barricade  V: rally  F: freecam\nBlue=Attackers  Red=Defenders  Accent=Class" % [
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
	var round_results_open := false
	var main_results_panel: PanelContainer = (
		main.get("round_results_panel") as PanelContainer
	)
	if main_results_panel != null:
		round_results_open = main_results_panel.visible

	var scoreboard_requested: bool = (
		scoreboard_key_held
		or Input.is_action_pressed("scoreboard")
		or Input.is_physical_key_pressed(KEY_TAB)
	)
	scoreboard.visible = (
		scoreboard_requested
		and not round_results_open
		and not tactical_map_open
		and not spawn_menu_open
	)
	if scoreboard_panel != null:
		scoreboard_panel.visible = scoreboard.visible
	if scoreboard.visible:
		scoreboard.text = str(main.call("scoreboard_text"))

	_update_et_style_hud(main, names)
	if et_hud_root != null and round_results_open:
		et_hud_root.visible = false
	if radar_panel != null and round_results_open:
		radar_panel.visible = false
	if feed != null:
		feed.visible = not round_results_open and not cinema_mode_enabled
		feed.text = "\n".join(main.kill_feed)
