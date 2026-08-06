extends Node

const PlayerProfileScript = preload(
	"res://scripts/profile/player_profile.gd"
)
const InputBindingManagerScript = preload(
	"res://scripts/profile/input_binding_manager.gd"
)
const ServerProgressionStoreScript = preload(
	"res://scripts/profile/server_progression_store.gd"
)
const WWIIDetailPassScript = preload(
	"res://scripts/visuals/wwii_detail_pass.gd"
)
const WWIIMaterialLibraryScript = preload(
	"res://scripts/visuals/wwii_material_library.gd"
)
const BattlefieldAtmosphereScript = preload(
	"res://scripts/visuals/battlefield_atmosphere.gd"
)
const RealAssetAdapterScript = preload(
	"res://scripts/assets/real_asset_adapter.gd"
)
const StructureCollisionAuditorScript = preload(
	"res://scripts/physics/structure_collision_auditor.gd"
)
const UrbanRealismPassScript = preload(
	"res://scripts/visuals/urban_realism_pass.gd"
)
const AlleyDetailPassScript = preload(
	"res://scripts/visuals/alley_detail_pass.gd"
)
const CombatEffectsManagerScript = preload(
	"res://scripts/visuals/combat_effects_manager.gd"
)

const ExternalAssetRegistryScript = preload(
	"res://scripts/assets/asset_registry.gd"
)
const ExternalAssetLoaderScript = preload(
	"res://scripts/assets/external_asset_loader.gd"
)
const ExternalAssetValidatorScript = preload(
	"res://scripts/assets/external_asset_validator.gd"
)
const ExternalLODControllerScript = preload(
	"res://scripts/assets/external_lod_controller.gd"
)

const TacticalDirectorScript = preload(
	"res://scripts/ai/tactical_director.gd"
)
const SquadCoordinatorScript = preload(
	"res://scripts/ai/squad_coordinator.gd"
)

const PlayerScene = preload("res://scenes/player.tscn")
const GrenadeScene = preload("res://scenes/grenade.tscn")
const SupplyPackScript = preload("res://scripts/supply_pack.gd")
const ConstructibleScript = preload("res://scripts/constructible.gd")
const SmokeCloudScript = preload("res://scripts/smoke_cloud.gd")
const SensorBeaconScript = preload("res://scripts/sensor_beacon.gd")
const FieldEmplacementScript = preload("res://scripts/field_emplacement.gd")
const DestructibleCoverScript = preload("res://scripts/destructible_cover.gd")
const RallyPointScript = preload("res://scripts/rally_point.gd")
const BreakablePropScript = preload("res://scripts/breakable_prop.gd")
const PORT_DEFAULT := 27960
const MAX_CLIENTS := 32
const BUILD_VERSION := "8.3.0"
const NETWORK_PROTOCOL := 341
const ROUND_RESTART_SECONDS := 10.0
const BOT_PEER_ID_START := 10000
const MATCH_LENGTH_SECONDS := 600.0
const SPAWN_WAVE_SECONDS := 10.0
const DYNAMITE_FUSE_SECONDS := 8.0
const INITIAL_TEAM_TICKETS := 80
const COMMAND_POST_CAPTURE_SECONDS := 12.0
const COMMAND_POST_RADIUS := 5.5
const FORWARD_SPAWN_WAVE_BONUS := 2.0
const MAX_BARRICADES_PER_ENGINEER := 2
const COMMAND_POST_STATION_INTERVAL := 1.0
const ARTILLERY_WARNING_SECONDS := 2.8
const ARTILLERY_RADIUS := 7.5
const ARTILLERY_DAMAGE := 92
const SENSOR_BEACON_DURATION := 18.0
const SENSOR_BEACON_RADIUS := 24.0
const FIELD_EMPLACEMENT_COUNT := 2
const SUPPLY_DEPOT_CAPTURE_SECONDS := 10.0
const SUPPLY_DEPOT_RADIUS := 5.2
const SUPPLY_DEPOT_TICKET_INTERVAL := 12.0
const RALLY_POINT_DURATION := 45.0
const RALLY_POINT_CONTEST_RADIUS := 8.0
const LARGE_MAP_HALF_WIDTH := 62.0
const LARGE_MAP_HALF_LENGTH := 52.0
const SECTOR_CAPTURE_RADIUS := 7.0
const SECTOR_CAPTURE_SECONDS := 12.0
const SECTOR_TICKET_INTERVAL := 18.0

var tex_metal: Texture2D
var tex_objective: Texture2D
var tex_foliage: Texture2D
var pbr_cobble_albedo: Texture2D
var pbr_cobble_normal: Texture2D
var pbr_cobble_roughness: Texture2D
var pbr_brick_albedo: Texture2D
var pbr_brick_normal: Texture2D
var pbr_brick_roughness: Texture2D
var pbr_plaster_albedo: Texture2D
var pbr_plaster_normal: Texture2D
var pbr_plaster_roughness: Texture2D
var pbr_ground_albedo: Texture2D
var pbr_ground_normal: Texture2D
var pbr_ground_roughness: Texture2D
var visual_townhouse_scene: PackedScene
var visual_ruined_townhouse_scene: PackedScene
var visual_rubble_scene: PackedScene
var visual_sandbag_scene: PackedScene
var pbr_concrete_albedo: Texture2D
var pbr_concrete_normal: Texture2D
var pbr_concrete_roughness: Texture2D
var pbr_mud_albedo: Texture2D
var pbr_mud_normal: Texture2D
var pbr_mud_roughness: Texture2D
var pbr_rust_albedo: Texture2D
var pbr_rust_normal: Texture2D
var pbr_rust_roughness: Texture2D
var bullet_impact_texture: Texture2D
var visual_rail_car_scene: PackedScene
var visual_halftrack_scene: PackedScene
var visual_bunker_scene: PackedScene
var active_impact_decals: Array[Decal] = []
var battlefield_dust: GPUParticles3D
var muzzle_smoke_texture: Texture2D
var glass_crack_texture: Texture2D
var breakable_props: Dictionary = {}
var next_breakable_prop_id := 1
var structure_collision_roots: Array[Node3D] = []
var collision_debug_enabled := false
var external_lod_controller: Node
var external_asset_reports: Array[String] = []
var external_asset_overlay: PanelContainer
var external_asset_overlay_label: Label
var external_asset_overlay_visible := false
var pbr_limestone_albedo: Texture2D
var pbr_limestone_normal: Texture2D
var pbr_limestone_roughness: Texture2D
var pbr_slate_albedo: Texture2D
var pbr_slate_normal: Texture2D
var pbr_slate_roughness: Texture2D
var pbr_damaged_plaster_albedo: Texture2D
var pbr_damaged_plaster_normal: Texture2D
var pbr_damaged_plaster_roughness: Texture2D
var pbr_gravel_albedo: Texture2D
var pbr_gravel_normal: Texture2D
var pbr_gravel_roughness: Texture2D
var visual_church_scene: PackedScene
var visual_warehouse_scene: PackedScene
var visual_field_gun_scene: PackedScene
var visual_prop_cluster_scene: PackedScene

var players: Dictionary = {}
var squad_shared_targets: Dictionary = {}
var squad_target_claims: Dictionary = {}
var squad_order_revision := 0
var squad_claim_reset_ms := 0
var player_teams: Dictionary = {}
var player_names: Dictionary = {}
var player_identity_ids: Dictionary = {}
var progression_store
var local_progression: Dictionary = {}
var progression_canvas: CanvasLayer
var progression_panel: PanelContainer
var progression_label: Label
var progression_visible := false
var supply_packs: Dictionary = {}
var grenades: Dictionary = {}
var next_grenade_id := 1
var next_supply_pack_id := 1
var constructibles: Dictionary = {}
var next_constructible_id := 1
var engineer_constructibles: Dictionary = {}
var smoke_clouds: Dictionary = {}
var next_smoke_id := 1
var station_accumulator := 0.0
var command_health_station: MeshInstance3D
var command_ammo_station: MeshInstance3D
var sensor_beacons: Dictionary = {}
var next_sensor_beacon_id := 1
var pending_artillery: Array[Dictionary] = []
var field_emplacements: Array[Node3D] = []
var destructible_covers: Dictionary = {}
var next_cover_id := 1
var spawn_points := {
	0: [
		Vector3(-58.0, 1.2, -16.0),
		Vector3(-58.0, 1.2, -10.0),
		Vector3(-58.0, 1.2, -4.0),
		Vector3(-54.0, 1.2, -18.0),
		Vector3(-54.0, 1.2, -10.0),
		Vector3(-54.0, 1.2, -2.0),
		Vector3(-50.0, 1.2, -10.0)
	],
	1: [
		Vector3(58.0, 1.2, 16.0),
		Vector3(58.0, 1.2, 10.0),
		Vector3(58.0, 1.2, 4.0),
		Vector3(54.0, 1.2, 18.0),
		Vector3(54.0, 1.2, 10.0),
		Vector3(54.0, 1.2, 2.0),
		Vector3(50.0, 1.2, 10.0)
	]
}
var next_team := 0
var desired_bot_count := 8
var bot_skill := 1.0
var next_bot_peer_id := BOT_PEER_ID_START
var round_restart_remaining := 0.0
var objective_health := 100
var objective_stage := 0 # 0 build bridge, 1 destroy bunker
var bridge_progress := 0
var bridge_required := 10
var defuse_progress := 0
var defuse_required := 5
var dynamite_armed := false
var dynamite_remaining := 0.0
var match_time_remaining := MATCH_LENGTH_SECONDS
var spawn_wave_remaining := SPAWN_WAVE_SECONDS
var match_over := false
var status_label: Label
var connection_panel: PanelContainer
var connection_address: LineEdit
var connection_port: SpinBox
var connection_join_button: Button
var connection_player_name: LineEdit
var connection_server_list: OptionButton
var connection_favorite_button: Button
var profile_binding_buttons: Dictionary = {}
var profile_waiting_for_action := ""
var profile_transfer_path: LineEdit
var profile_manager
var local_profile: Dictionary = {}
var profile_canvas: CanvasLayer
var profile_panel: PanelContainer
var profile_name_input: LineEdit
var profile_team_option: OptionButton
var profile_class_option: OptionButton
var profile_sensitivity_slider: HSlider
var profile_fov_slider: HSlider
var profile_hud_scale_slider: HSlider
var profile_master_slider: HSlider
var profile_effects_slider: HSlider
var profile_music_slider: HSlider
var profile_status_label: Label
var profile_panel_visible := false
var protocol_verified := false
var protocol_message := "Protocol pending"
var last_server_input_ack := -1
var snapshot_accumulator := 0.0
const SNAPSHOT_INTERVAL := 0.05
var verified_peers: Dictionary = {}
var kill_feed: Array[String] = []
var objective_marker: Label3D
var objective_progress_label: Label3D
var dynamite_model: MeshInstance3D
var dynamite_light: OmniLight3D
var round_results_layer: CanvasLayer
var round_results_panel: PanelContainer
var round_results_label: Label
var round_results_title: Label
var round_results_summary: Label
var round_results_countdown: Label
var announcement_layer: CanvasLayer
var announcement_panel: PanelContainer
var announcement_label: Label
var announcement_hide_ms := 0
var attacker_tickets := INITIAL_TEAM_TICKETS
var defender_tickets := INITIAL_TEAM_TICKETS
var command_post_control := -1
var command_post_progress := 0.0
var command_post_contested := false
var overtime_active := false
var command_post_marker: Label3D
var command_post_progress_label: Label3D
var command_post_beacon: OmniLight3D
var battlefield_environment: Environment
var wwii_detail_pass: Node3D
var wwii_material_library
var battlefield_atmosphere: Node3D
var structure_collision_report: Dictionary = {}
var urban_realism_pass: Node3D
var alley_detail_pass: Node3D
var combat_effects_manager: Node3D
var battlefield_sun: DirectionalLight3D
var atmosphere_elapsed := 0.0
var ambience_player: AudioStreamPlayer
var bridge_beacon: OmniLight3D
var bunker_beacon: OmniLight3D
var spawn_beams: Array[Node3D] = []
var rally_points: Dictionary = {}
var next_rally_id := 1
var supply_depot_control := -1
var supply_depot_progress := 0.0
var supply_depot_contested := false
var supply_depot_ticket_accumulator := 0.0
var supply_depot_marker: Label3D
var supply_depot_progress_label: Label3D
var supply_depot_light: OmniLight3D
var mission_banner_text := ""
var mission_banner_until_ms := 0
var sector_positions: Dictionary = {
	"Village": Vector3(-28.0, 0.0, 1.0),
	"Rail Yard": Vector3(25.0, 0.0, -20.0),
	"Fort": Vector3(30.0, 0.0, 25.0)
}
var sector_control: Dictionary = {
	"Village": -1,
	"Rail Yard": -1,
	"Fort": -1
}
var sector_progress: Dictionary = {
	"Village": 0.0,
	"Rail Yard": 0.0,
	"Fort": 0.0
}
var sector_contested: Dictionary = {
	"Village": false,
	"Rail Yard": false,
	"Fort": false
}
var sector_ticket_accumulator := 0.0
var sector_markers: Dictionary = {}
var sector_lights: Dictionary = {}
var forward_spawn_points := {
	0: [
		Vector3(3.5, 1.0, -8.5),
		Vector3(5.0, 1.0, -6.5),
		Vector3(6.5, 1.0, -8.5)
	],
	1: [
		Vector3(5.0, 1.0, -9.5),
		Vector3(7.0, 1.0, -7.0),
		Vector3(8.5, 1.0, -9.0)
	]
}

func _ready() -> void:
	profile_manager = PlayerProfileScript.new()
	local_profile = profile_manager.load_profile()
	progression_store = ServerProgressionStoreScript.new()
	if DisplayServer.get_name() == "headless":
		progression_store.load_database()
	InputBindingManagerScript.apply_bindings(
		Dictionary(local_profile.get("keybindings", {}))
	)
	_apply_profile_audio_settings()

	# Structural scenes must be loaded on both the graphical client and the
	# headless VPS. The server cannot collide with a wall it never instantiated.
	visual_townhouse_scene = _load_optional_scene(
		"res://assets/models/wwii_townhouse.glb"
	)
	visual_ruined_townhouse_scene = _load_optional_scene(
		"res://assets/models/wwii_townhouse_ruined.glb"
	)
	visual_church_scene = _load_optional_scene(
		"res://assets/models/stone_church.glb"
	)
	visual_warehouse_scene = _load_optional_scene(
		"res://assets/models/rail_warehouse.glb"
	)
	visual_bunker_scene = _load_optional_scene(
		"res://assets/models/concrete_bunker.glb"
	)

	if DisplayServer.get_name() != "headless":
		_initialize_battlefield_ambience()
		tex_metal = _load_optional_texture(
			"res://assets/textures/metal_panel.png"
		)
		tex_objective = _load_optional_texture(
			"res://assets/textures/objective_hazard.png"
		)
		tex_foliage = _load_optional_texture(
			"res://assets/textures/foliage_sprite.png"
		)
		pbr_cobble_albedo = _load_optional_texture(
			"res://assets/pbr/cobblestone_albedo.png"
		)
		pbr_cobble_normal = _load_optional_texture(
			"res://assets/pbr/cobblestone_normal.png"
		)
		pbr_cobble_roughness = _load_optional_texture(
			"res://assets/pbr/cobblestone_roughness.png"
		)
		pbr_brick_albedo = _load_optional_texture(
			"res://assets/pbr/brick_albedo.png"
		)
		pbr_brick_normal = _load_optional_texture(
			"res://assets/pbr/brick_normal.png"
		)
		pbr_brick_roughness = _load_optional_texture(
			"res://assets/pbr/brick_roughness.png"
		)
		pbr_plaster_albedo = _load_optional_texture(
			"res://assets/pbr/plaster_albedo.png"
		)
		pbr_plaster_normal = _load_optional_texture(
			"res://assets/pbr/plaster_normal.png"
		)
		pbr_plaster_roughness = _load_optional_texture(
			"res://assets/pbr/plaster_roughness.png"
		)
		pbr_ground_albedo = _load_optional_texture(
			"res://assets/pbr/rubble_ground_albedo.png"
		)
		pbr_ground_normal = _load_optional_texture(
			"res://assets/pbr/rubble_ground_normal.png"
		)
		pbr_ground_roughness = _load_optional_texture(
			"res://assets/pbr/rubble_ground_roughness.png"
		)
		visual_rubble_scene = _load_optional_scene(
			"res://assets/models/rubble_pile.glb"
		)
		visual_sandbag_scene = _load_optional_scene(
			"res://assets/models/sandbag_emplacement.glb"
		)
		pbr_concrete_albedo = _load_optional_texture("res://assets/pbr/concrete_albedo.png")
		pbr_concrete_normal = _load_optional_texture("res://assets/pbr/concrete_normal.png")
		pbr_concrete_roughness = _load_optional_texture("res://assets/pbr/concrete_roughness.png")
		pbr_mud_albedo = _load_optional_texture("res://assets/pbr/mud_albedo.png")
		pbr_mud_normal = _load_optional_texture("res://assets/pbr/mud_normal.png")
		pbr_mud_roughness = _load_optional_texture("res://assets/pbr/mud_roughness.png")
		pbr_rust_albedo = _load_optional_texture("res://assets/pbr/rusted_metal_albedo.png")
		pbr_rust_normal = _load_optional_texture("res://assets/pbr/rusted_metal_normal.png")
		pbr_rust_roughness = _load_optional_texture("res://assets/pbr/rusted_metal_roughness.png")
		bullet_impact_texture = _load_optional_texture("res://assets/fx/bullet_impact.png")
		visual_rail_car_scene = _load_optional_scene("res://assets/models/rail_car_detailed.glb")
		visual_halftrack_scene = _load_optional_scene("res://assets/models/halftrack_prop.glb")
		muzzle_smoke_texture = _load_optional_texture("res://assets/fx/muzzle_smoke.png")
		glass_crack_texture = _load_optional_texture("res://assets/fx/glass_crack.png")
		pbr_limestone_albedo = _load_optional_texture("res://assets/pbr/limestone_blocks_albedo.png")
		pbr_limestone_normal = _load_optional_texture("res://assets/pbr/limestone_blocks_normal.png")
		pbr_limestone_roughness = _load_optional_texture("res://assets/pbr/limestone_blocks_roughness.png")
		pbr_slate_albedo = _load_optional_texture("res://assets/pbr/slate_roof_albedo.png")
		pbr_slate_normal = _load_optional_texture("res://assets/pbr/slate_roof_normal.png")
		pbr_slate_roughness = _load_optional_texture("res://assets/pbr/slate_roof_roughness.png")
		pbr_damaged_plaster_albedo = _load_optional_texture("res://assets/pbr/damaged_plaster_albedo.png")
		pbr_damaged_plaster_normal = _load_optional_texture("res://assets/pbr/damaged_plaster_normal.png")
		pbr_damaged_plaster_roughness = _load_optional_texture("res://assets/pbr/damaged_plaster_roughness.png")
		pbr_gravel_albedo = _load_optional_texture("res://assets/pbr/compacted_gravel_albedo.png")
		pbr_gravel_normal = _load_optional_texture("res://assets/pbr/compacted_gravel_normal.png")
		pbr_gravel_roughness = _load_optional_texture("res://assets/pbr/compacted_gravel_roughness.png")
		visual_field_gun_scene = _load_optional_scene("res://assets/models/field_artillery.glb")
		visual_prop_cluster_scene = _load_optional_scene("res://assets/models/crate_barrel_cluster.glb")

	_build_world()
	_initialize_external_lod()
	_build_external_asset_overlay()
	_spawn_external_environment_assets()
	_update_external_asset_overlay()
	_apply_high_visual_quality()
	_build_round_results_ui()
	_update_objective_visuals()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	_parse_command_line()
	print(
		"Authoritative structural assets: townhouse=%s ruined=%s church=%s warehouse=%s bunker=%s"
		% [
			visual_townhouse_scene != null,
			visual_ruined_townhouse_scene != null,
			visual_church_scene != null,
			visual_warehouse_scene != null,
			visual_bunker_scene != null
		]
	)

func _unhandled_input(event: InputEvent) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
	):
		var key_event := event as InputEventKey
		var key_code: Key = (
			key_event.physical_keycode
			if key_event.physical_keycode != 0
			else key_event.keycode
		)
		if not profile_waiting_for_action.is_empty():
			if key_code == KEY_ESCAPE:
				profile_waiting_for_action = ""
				if profile_status_label != null:
					profile_status_label.text = (
						"Keybinding capture cancelled."
					)
			else:
				_capture_binding_key(int(key_code))
			get_viewport().set_input_as_handled()
			return

		if key_code == KEY_F10:
			_toggle_external_asset_overlay()
			get_viewport().set_input_as_handled()
		elif key_code == KEY_F8:
			_set_profile_panel_visible(
				not profile_panel_visible
			)
			get_viewport().set_input_as_handled()
		elif key_code == KEY_F7:
			_set_progression_visible(not progression_visible)
			get_viewport().set_input_as_handled()
		elif key_code == KEY_ESCAPE and progression_visible:
			_set_progression_visible(false)
			get_viewport().set_input_as_handled()
		elif key_code == KEY_ESCAPE and profile_panel_visible:
			_set_profile_panel_visible(false)
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	atmosphere_elapsed += delta
	_update_immersive_visuals()
	_update_objective_visuals()
	_update_command_post_visuals()
	_update_supply_depot_visuals()
	_update_sector_visuals()
	_update_battlefield_atmosphere()

	var active_peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if active_peer == null:
		return
	if (
		active_peer.get_connection_status()
		== MultiplayerPeer.CONNECTION_DISCONNECTED
	):
		return
	if not multiplayer.is_server():
		return

	_update_pending_artillery(delta)
	_update_supply_depot(delta)
	_update_sector_warfare(delta)

	station_accumulator += delta
	if station_accumulator >= COMMAND_POST_STATION_INTERVAL:
		station_accumulator = 0.0
		_update_command_post_stations()

	snapshot_accumulator += delta
	if snapshot_accumulator >= SNAPSHOT_INTERVAL:
		snapshot_accumulator = 0.0
		_broadcast_player_snapshots()

	_update_announcement_ui()
	if match_over:
		round_restart_remaining = maxf(0.0, round_restart_remaining - delta)
		if round_results_countdown != null:
			round_results_countdown.text = (
				"Next round begins in %.0f seconds"
				% ceilf(round_restart_remaining)
			)
		broadcast_match_state.rpc(
			match_time_remaining,
			spawn_wave_remaining,
			objective_health,
			objective_stage,
			bridge_progress,
			bridge_required,
			dynamite_armed,
			dynamite_remaining,
			defuse_progress,
			defuse_required,
			attacker_tickets,
			defender_tickets,
			command_post_control,
			command_post_progress,
			command_post_contested,
			overtime_active
		)
		if round_restart_remaining <= 0.0:
			_reset_round()
		return

	_update_command_post_capture(delta)

	if not overtime_active:
		match_time_remaining = maxf(
			0.0,
			match_time_remaining - delta
		)

	spawn_wave_remaining -= delta
	if spawn_wave_remaining <= 0.0:
		var wave_interval := SPAWN_WAVE_SECONDS
		if command_post_control >= 0:
			wave_interval = maxf(
				5.0,
				SPAWN_WAVE_SECONDS - FORWARD_SPAWN_WAVE_BONUS
			)
		spawn_wave_remaining += wave_interval
		_respawn_wave()

	if dynamite_armed:
		dynamite_remaining = maxf(0.0, dynamite_remaining - delta)
		if dynamite_remaining <= 0.0:
			dynamite_armed = false
			defuse_progress = 0
			_update_objective_visuals()
			damage_objective(100, 0)

	_check_ticket_victory()

	if match_time_remaining <= 0.0 and not match_over:
		if _should_overtime_continue():
			if not overtime_active:
				overtime_active = true
				push_kill_feed.rpc("OVERTIME — objective remains active")
		else:
			overtime_active = false
			_end_match("DEFENDERS WIN — objective secured")

	broadcast_match_state.rpc(
		match_time_remaining,
		spawn_wave_remaining,
		objective_health,
		objective_stage,
		bridge_progress,
		bridge_required,
		dynamite_armed,
		dynamite_remaining,
		defuse_progress,
		defuse_required,
		attacker_tickets,
		defender_tickets,
		command_post_control,
		command_post_progress,
		command_post_contested,
		overtime_active
	)

func _initialize_battlefield_ambience() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not ResourceLoader.exists("res://audio/battlefield_ambience.wav"):
		return
	var resource: Resource = load("res://audio/battlefield_ambience.wav")
	if not resource is AudioStream:
		return
	ambience_player = AudioStreamPlayer.new()
	ambience_player.stream = resource as AudioStream
	ambience_player.volume_db = -24.0
	add_child(ambience_player)
	ambience_player.play()

func _create_spawn_beam(position: Vector3, team_id: int) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var root: Node3D = Node3D.new()
	root.position = position
	add_child(root)
	var beam := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.07
	cylinder.bottom_radius = 0.18
	cylinder.height = 2.4
	beam.mesh = cylinder
	beam.position.y = 1.2
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.12,0.48,1.0,0.09) if team_id == 0 else Color(1.0,0.18,0.10,0.09)
	material.emission_enabled = true
	material.emission = material.albedo_color
	beam.material_override = material
	root.add_child(beam)
	spawn_beams.append(root)

func _update_immersive_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var pulse: float = 1.25 + sin(atmosphere_elapsed * 3.2) * 0.55
	if bridge_beacon != null:
		bridge_beacon.light_energy = pulse
	if bunker_beacon != null:
		bunker_beacon.light_energy = pulse
	var local_player: Node3D = null
	if multiplayer.has_multiplayer_peer():
		var local_id: int = multiplayer.get_unique_id()
		if players.has(local_id):
			local_player = players[local_id] as Node3D

	for index in spawn_beams.size():
		var root: Node3D = spawn_beams[index] as Node3D
		if root == null:
			continue
		if local_player != null:
			root.visible = (
				local_player.global_position.distance_to(
					root.global_position
				) > 8.0
			)
		root.rotation.y += 0.003
		var p: float = 1.0 + sin(atmosphere_elapsed * 2.2 + index) * 0.06
		root.scale = Vector3(p,1.0,p)

func _build_asset_based_rail_and_fort_pass() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var rust_material := _make_pbr_material(pbr_rust_albedo, pbr_rust_normal, pbr_rust_roughness, Color(0.86,0.84,0.80), 2.4)
	var concrete_material := _make_pbr_material(pbr_concrete_albedo, pbr_concrete_normal, pbr_concrete_roughness, Color(0.94,0.94,0.92), 2.0)
	var mud_material := _make_pbr_material(pbr_mud_albedo, pbr_mud_normal, pbr_mud_roughness, Color(0.90,0.86,0.78), 3.2)
	for rail_position in [Vector3(19.0,0.0,-20.5), Vector3(29.0,0.0,-20.5), Vector3(39.0,0.0,-20.5)]:
		_spawn_visual_scene(visual_rail_car_scene, "DetailedRailCar_%s" % str(rail_position), rail_position, 0.0, Vector3.ONE, rust_material)
	_spawn_visual_scene(visual_halftrack_scene, "HalftrackVillage", Vector3(-25.0,0.0,-8.0), deg_to_rad(14.0), Vector3.ONE, rust_material)
	_spawn_visual_scene(visual_halftrack_scene, "HalftrackFort", Vector3(25.0,0.0,14.0), deg_to_rad(-32.0), Vector3.ONE*0.95, rust_material)
	_spawn_visual_scene(visual_bunker_scene, "ImportedFortBunker", Vector3(33.0,0.0,28.0), deg_to_rad(180.0), Vector3.ONE*1.15, concrete_material)
	for mud_data in [["MudNorthRoad",Vector3(0.0,0.095,-31.0),Vector3(60.0,0.08,8.0)],["MudSouthRoad",Vector3(0.0,0.095,35.0),Vector3(62.0,0.08,10.0)],["MudRailYard",Vector3(28.0,0.095,-18.0),Vector3(40.0,0.08,28.0)]]:
		var mud_plane := MeshInstance3D.new()
		mud_plane.name = str(mud_data[0])
		mud_plane.position = Vector3(mud_data[1])
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(mud_data[2])
		mud_plane.mesh = mesh
		mud_plane.material_override = mud_material
		add_child(mud_plane)

func _initialize_battlefield_particles() -> void:
	if DisplayServer.get_name() == "headless":
		return
	battlefield_dust = GPUParticles3D.new()
	battlefield_dust.amount = 180
	battlefield_dust.lifetime = 9.0
	battlefield_dust.visibility_aabb = AABB(Vector3(-70.0,-5.0,-60.0),Vector3(140.0,28.0,120.0))
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(58.0,8.0,48.0)
	process_material.direction = Vector3(0.25,0.15,0.10)
	process_material.spread = 180.0
	process_material.initial_velocity_min = 0.10
	process_material.initial_velocity_max = 0.55
	process_material.gravity = Vector3(0.0,-0.02,0.0)
	process_material.scale_min = 0.05
	process_material.scale_max = 0.22
	process_material.color = Color(0.58,0.54,0.46,0.26)
	battlefield_dust.process_material = process_material
	var quad := QuadMesh.new()
	quad.size = Vector2(0.22,0.22)
	var dust_material := StandardMaterial3D.new()
	dust_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dust_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dust_material.albedo_color = Color(0.65,0.60,0.52,0.30)
	dust_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = dust_material
	battlefield_dust.draw_pass_1 = quad
	add_child(battlefield_dust)
	battlefield_dust.emitting = true

func spawn_bullet_impact_decal(position: Vector3, normal: Vector3) -> void:
	if DisplayServer.get_name() == "headless" or bullet_impact_texture == null:
		return
	var decal := Decal.new()
	decal.texture_albedo = bullet_impact_texture
	decal.size = Vector3(0.42,0.42,0.18)
	decal.position = position + normal*0.01
	decal.rotation = Vector3(0.0,atan2(normal.x,normal.z),0.0)
	add_child(decal)
	active_impact_decals.append(decal)
	while active_impact_decals.size() > 48:
		var oldest: Decal = active_impact_decals.pop_front()
		if oldest != null and is_instance_valid(oldest):
			oldest.queue_free()

func _create_breakable_prop(
	prop_kind: String,
	position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0
) -> void:
	var prop_id: int = next_breakable_prop_id
	next_breakable_prop_id += 1
	var prop := StaticBody3D.new()
	prop.name = "Breakable_%s_%d" % [prop_kind, prop_id]
	prop.set_script(BreakablePropScript)
	add_child(prop)
	prop.call("configure", prop_id, prop_kind, position, size, rotation_y)
	breakable_props[prop_id] = prop

func _build_breakable_environment() -> void:
	for window_data in [
		[Vector3(-51.0,4.6,-30.55),Vector3(1.25,1.35,0.10),0.0],
		[Vector3(-48.3,7.6,-30.55),Vector3(1.25,1.35,0.10),0.0],
		[Vector3(-52.0,4.6,-11.55),Vector3(1.25,1.35,0.10),0.0],
		[Vector3(45.0,4.4,-22.05),Vector3(1.20,1.25,0.10),0.0]
	]:
		_create_breakable_prop("window",Vector3(window_data[0]),Vector3(window_data[1]),float(window_data[2]))
	for door_data in [
		[Vector3(-52.0,1.25,-11.65),Vector3(1.55,2.50,0.20),0.0],
		[Vector3(-49.0,1.25,30.15),Vector3(1.55,2.50,0.20),0.0],
		[Vector3(42.0,1.25,25.0),Vector3(0.20,2.50,1.55),0.0]
	]:
		_create_breakable_prop("door",Vector3(door_data[0]),Vector3(door_data[1]),float(door_data[2]))

func _spawn_impact_particles(position: Vector3, hit_player: bool) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var particles := GPUParticles3D.new()
	particles.position = position
	particles.amount = 16 if hit_player else 24
	particles.lifetime = 0.42
	particles.one_shot = true
	particles.explosiveness = 0.92
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.08
	pm.direction = Vector3(0.0,1.0,0.0)
	pm.spread = 180.0
	pm.initial_velocity_min = 1.5
	pm.initial_velocity_max = 4.0
	pm.gravity = Vector3(0.0,-6.0,0.0)
	pm.scale_min = 0.035
	pm.scale_max = 0.085
	pm.color = Color(0.75,0.05,0.02,0.85) if hit_player else Color(1.0,0.68,0.18,0.90)
	particles.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.09,0.09)
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = pm.color
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = mat
	particles.draw_pass_1 = quad
	add_child(particles)
	particles.emitting = true
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.75
	timer.timeout.connect(particles.queue_free)
	particles.add_child(timer)
	timer.start()

func _spawn_explosion_debris(position: Vector3) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_ensure_combat_effects_manager()
	if combat_effects_manager != null:
		combat_effects_manager.call(
			"spawn_explosion_polish",
			position,
			"ground"
		)

func _set_environment_property_if_available(
	property_name: StringName,
	value: Variant
) -> void:
	if battlefield_environment == null:
		return
	for property_info in battlefield_environment.get_property_list():
		if StringName(property_info.get("name", "")) == property_name:
			battlefield_environment.set(property_name, value)
			return

func _apply_wwii_material_library() -> void:
	if DisplayServer.get_name() == "headless":
		return
	wwii_material_library = WWIIMaterialLibraryScript.new()
	if wwii_material_library.has_method("apply_to_world"):
		var report: Dictionary = Dictionary(
			wwii_material_library.call("apply_to_world", self)
		)
		print("WWII material assignment: %s" % report)

func _build_battlefield_atmosphere() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if battlefield_atmosphere != null:
		return
	battlefield_atmosphere = BattlefieldAtmosphereScript.new()
	battlefield_atmosphere.name = "BattlefieldAtmosphere"
	add_child(battlefield_atmosphere)
	if battlefield_atmosphere.has_method("build"):
		battlefield_atmosphere.call("build", self)

func _build_wwii_detail_pass() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if wwii_detail_pass != null:
		return

	wwii_detail_pass = WWIIDetailPassScript.new()
	wwii_detail_pass.name = "WWIIDetailPass"
	add_child(wwii_detail_pass)
	if wwii_detail_pass.has_method("build"):
		wwii_detail_pass.call("build")

func _build_high_fidelity_environment_pass() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var stone_material := _make_pbr_material(
		pbr_limestone_albedo,
		pbr_limestone_normal,
		pbr_limestone_roughness,
		Color(0.96, 0.95, 0.91),
		2.2
	)
	var plaster_material := _make_pbr_material(
		pbr_damaged_plaster_albedo,
		pbr_damaged_plaster_normal,
		pbr_damaged_plaster_roughness,
		Color(0.97, 0.92, 0.84),
		2.0
	)
	var gravel_material := _make_pbr_material(
		pbr_gravel_albedo,
		pbr_gravel_normal,
		pbr_gravel_roughness,
		Color(0.90, 0.89, 0.84),
		3.4
	)
	var slate_material := _make_pbr_material(
		pbr_slate_albedo,
		pbr_slate_normal,
		pbr_slate_roughness,
		Color(0.82, 0.87, 0.91),
		2.6
	)

	var church := _spawn_visual_scene(
		visual_church_scene,
		"StoneChurch",
		Vector3(-42.0, 0.0, 9.0),
		deg_to_rad(7.0),
		Vector3.ONE * 0.92,
		stone_material
	)
	if church != null:
		# Keep the roof darker after global stone override.
		for child in church.get_children():
			if child is MeshInstance3D and "roof" in child.name.to_lower():
				(child as MeshInstance3D).material_override = slate_material

	_spawn_visual_scene(
		visual_warehouse_scene,
		"DetailedRailWarehouse",
		Vector3(47.0, 0.0, -18.0),
		deg_to_rad(-2.0),
		Vector3.ONE,
		plaster_material
	)
	_spawn_visual_scene(
		visual_field_gun_scene,
		"FieldGunNorth",
		Vector3(8.0, 0.0, -28.0),
		deg_to_rad(20.0),
		Vector3.ONE,
		null
	)
	_spawn_visual_scene(
		visual_field_gun_scene,
		"FieldGunFort",
		Vector3(37.0, 0.0, 18.0),
		deg_to_rad(-65.0),
		Vector3.ONE,
		null
	)

	for prop_position in [
		Vector3(-35.0, 0.0, -4.0),
		Vector3(-30.0, 0.0, 23.0),
		Vector3(24.0, 0.0, -24.0),
		Vector3(40.0, 0.0, 18.0),
		Vector3(51.0, 0.0, -10.0)
	]:
		_spawn_visual_scene(
			visual_prop_cluster_scene,
			"PropCluster_%s" % str(prop_position),
			prop_position,
			randf_range(-0.5, 0.5),
			Vector3.ONE * randf_range(0.88, 1.12),
			null
		)

	for overlay_data in [
		["HighResGravelNorth", Vector3(0.0, 0.115, -40.0), Vector3(104.0, 0.08, 14.0)],
		["HighResGravelSouth", Vector3(0.0, 0.115, 42.0), Vector3(105.0, 0.08, 14.0)],
		["HighResRailApron", Vector3(39.0, 0.115, -20.0), Vector3(42.0, 0.08, 36.0)]
	]:
		var overlay := MeshInstance3D.new()
		overlay.name = str(overlay_data[0])
		overlay.position = Vector3(overlay_data[1])
		var overlay_mesh := BoxMesh.new()
		overlay_mesh.size = Vector3(overlay_data[2])
		overlay.mesh = overlay_mesh
		overlay.material_override = gravel_material
		add_child(overlay)

	# Conservative post-processing: only set properties found on this Godot build.
	_set_environment_property_if_available(&"ssao_enabled", true)
	_set_environment_property_if_available(&"ssao_radius", 2.4)
	_set_environment_property_if_available(&"ssao_intensity", 2.2)
	_set_environment_property_if_available(&"ssao_power", 1.45)
	_set_environment_property_if_available(&"ssil_enabled", true)
	_set_environment_property_if_available(&"ssil_radius", 4.0)
	_set_environment_property_if_available(&"ssil_intensity", 1.1)
	_set_environment_property_if_available(&"adjustment_enabled", true)
	_set_environment_property_if_available(&"adjustment_contrast", 1.08)
	_set_environment_property_if_available(&"adjustment_saturation", 0.88)
	_set_environment_property_if_available(&"adjustment_brightness", 1.02)

func _make_wooden_fence(
	node_name: String,
	position: Vector3,
	length: int,
	rotation_y: float = 0.0
) -> void:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	# One authoritative fence body exists on both graphical and headless
	# instances. Visual rails and posts remain client-side decoration.
	var collision_body := StaticBody3D.new()
	collision_body.name = "%s_Collision" % node_name
	collision_body.collision_layer = 1
	collision_body.collision_mask = 1
	root.add_child(collision_body)

	var fence_collision := CollisionShape3D.new()
	var fence_shape := BoxShape3D.new()
	fence_shape.size = Vector3(
		maxf(0.8, float(length) * 1.35),
		1.50,
		0.30
	)
	fence_collision.shape = fence_shape
	fence_collision.position = Vector3(0.0, 0.75, 0.0)
	collision_body.add_child(fence_collision)

	if DisplayServer.get_name() == "headless":
		return

	var wood_material := StandardMaterial3D.new()
	wood_material.albedo_color = Color(0.25, 0.15, 0.075)
	wood_material.roughness = 0.96

	for index in range(length + 1):
		var post := MeshInstance3D.new()
		var post_mesh := BoxMesh.new()
		post_mesh.size = Vector3(0.16, 1.55, 0.16)
		post.mesh = post_mesh
		post.position = Vector3(
			float(index) * 1.35 - float(length) * 0.675,
			0.78,
			0.0
		)
		post.material_override = wood_material
		root.add_child(post)

	for rail_y in [0.55, 1.12]:
		var rail := MeshInstance3D.new()
		var rail_mesh := BoxMesh.new()
		rail_mesh.size = Vector3(
			float(length) * 1.35,
			0.13,
			0.12
		)
		rail.mesh = rail_mesh
		rail.position = Vector3(0.0, rail_y, 0.0)
		rail.material_override = wood_material
		root.add_child(rail)

func _make_telegraph_pole(
	node_name: String,
	position: Vector3
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	add_child(root)

	var wood_material := StandardMaterial3D.new()
	wood_material.albedo_color = Color(0.20, 0.115, 0.055)
	wood_material.roughness = 0.95

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.09
	pole_mesh.bottom_radius = 0.14
	pole_mesh.height = 6.6
	pole.mesh = pole_mesh
	pole.position.y = 3.3
	pole.material_override = wood_material
	root.add_child(pole)

	var crossbar := MeshInstance3D.new()
	var crossbar_mesh := BoxMesh.new()
	crossbar_mesh.size = Vector3(2.4, 0.16, 0.16)
	crossbar.mesh = crossbar_mesh
	crossbar.position.y = 6.05
	crossbar.material_override = wood_material
	root.add_child(crossbar)

	for insulator_x in [-0.85, 0.0, 0.85]:
		var insulator := MeshInstance3D.new()
		var insulator_mesh := CylinderMesh.new()
		insulator_mesh.top_radius = 0.08
		insulator_mesh.bottom_radius = 0.12
		insulator_mesh.height = 0.24
		insulator.mesh = insulator_mesh
		insulator.position = Vector3(insulator_x, 6.25, 0.0)
		var ceramic := StandardMaterial3D.new()
		ceramic.albedo_color = Color(0.28, 0.32, 0.30)
		ceramic.roughness = 0.38
		insulator.material_override = ceramic
		root.add_child(insulator)

func _make_shell_crater(
	node_name: String,
	position: Vector3,
	radius: float
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var crater := MeshInstance3D.new()
	crater.name = node_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius * 0.52
	mesh.outer_radius = radius
	mesh.rings = 22
	mesh.ring_segments = 32
	crater.mesh = mesh
	crater.position = position + Vector3(0.0, 0.035, 0.0)
	crater.rotation_degrees.x = 90.0
	crater.scale.y = 0.25

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.12, 0.075)
	material.roughness = 1.0
	crater.material_override = material
	add_child(crater)

func _make_direction_sign(
	node_name: String,
	position: Vector3,
	rotation_y: float,
	label_text: String
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	var post := MeshInstance3D.new()
	var post_mesh := BoxMesh.new()
	post_mesh.size = Vector3(0.15, 2.1, 0.15)
	post.mesh = post_mesh
	post.position.y = 1.05
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.23, 0.14, 0.07)
	wood.roughness = 0.96
	post.material_override = wood
	root.add_child(post)

	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(2.25, 0.62, 0.10)
	board.mesh = board_mesh
	board.position = Vector3(0.0, 1.82, 0.0)
	board.material_override = wood
	root.add_child(board)

	var label := Label3D.new()
	label.text = label_text
	label.position = Vector3(0.0, 1.82, -0.065)
	label.font_size = 28
	label.outline_size = 5
	label.modulate = Color(0.88, 0.84, 0.67)
	label.fixed_size = false
	root.add_child(label)

func _build_battlefield_dressing_pass() -> void:
	for fence_data in [
		["WestRoadFenceA", Vector3(-43.0,0.0,-39.0), 10, 0.0],
		["WestRoadFenceB", Vector3(-31.0,0.0,42.0), 12, 0.08],
		["RailFenceA", Vector3(20.0,0.0,-34.0), 9, 0.0],
		["FortFenceA", Vector3(43.0,0.0,39.0), 8, 1.57]
	]:
		_make_wooden_fence(
			str(fence_data[0]),
			Vector3(fence_data[1]),
			int(fence_data[2]),
			float(fence_data[3])
		)

	for pole_position in [
		Vector3(-48.0,0.0,-34.0),
		Vector3(-32.0,0.0,-34.0),
		Vector3(-16.0,0.0,-34.0),
		Vector3(12.0,0.0,-34.0),
		Vector3(28.0,0.0,-34.0),
		Vector3(44.0,0.0,-34.0)
	]:
		_make_telegraph_pole(
			"Telegraph_%s" % str(pole_position),
			pole_position
		)

	for crater_data in [
		[Vector3(-16.0,0.0,-8.0), 1.6],
		[Vector3(5.0,0.0,14.0), 2.0],
		[Vector3(18.0,0.0,-29.0), 1.4],
		[Vector3(38.0,0.0,7.0), 1.8],
		[Vector3(-37.0,0.0,28.0), 1.5]
	]:
		_make_shell_crater(
			"Crater_%s" % str(crater_data[0]),
			Vector3(crater_data[0]),
			float(crater_data[1])
		)

	_make_direction_sign(
		"VillageSign",
		Vector3(-27.0,0.0,-18.0),
		deg_to_rad(8.0),
		"VILLAGE  →"
	)
	_make_direction_sign(
		"RailSign",
		Vector3(11.0,0.0,-25.0),
		deg_to_rad(-4.0),
		"RAIL DEPOT  →"
	)
	_make_direction_sign(
		"FortSign",
		Vector3(20.0,0.0,19.0),
		deg_to_rad(18.0),
		"FORT  →"
	)

func _make_road_barricade(
	node_name: String,
	position: Vector3,
	rotation_y: float
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.30, 0.17, 0.075)
	wood.roughness = 0.96

	for index in [-1, 0, 1]:
		var beam := MeshInstance3D.new()
		var beam_mesh := BoxMesh.new()
		beam_mesh.size = Vector3(3.6, 0.18, 0.18)
		beam.mesh = beam_mesh
		beam.position = Vector3(
			0.0,
			0.52 + float(index + 1) * 0.34,
			0.0
		)
		beam.rotation.z = deg_to_rad(
			-7.0 if index % 2 == 0 else 7.0
		)
		beam.material_override = wood
		root.add_child(beam)

	for x in [-1.45, 1.45]:
		var support := MeshInstance3D.new()
		var support_mesh := BoxMesh.new()
		support_mesh.size = Vector3(0.20, 1.65, 0.20)
		support.mesh = support_mesh
		support.position = Vector3(x, 0.82, 0.0)
		support.rotation.z = deg_to_rad(
			18.0 if x < 0.0 else -18.0
		)
		support.material_override = wood
		root.add_child(support)

func _make_fire_barrel(
	node_name: String,
	position: Vector3
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	add_child(root)

	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.42
	barrel_mesh.bottom_radius = 0.44
	barrel_mesh.height = 1.0
	barrel.mesh = barrel_mesh
	barrel.position.y = 0.50

	var barrel_material := StandardMaterial3D.new()
	barrel_material.albedo_color = Color(0.17, 0.18, 0.17)
	barrel_material.metallic = 0.55
	barrel_material.roughness = 0.72
	barrel.material_override = barrel_material
	root.add_child(barrel)

	var fire := GPUParticles3D.new()
	fire.name = "Fire"
	fire.position.y = 1.12
	fire.amount = 30
	fire.lifetime = 0.75
	fire.randomness = 0.62
	fire.visibility_aabb = AABB(
		Vector3(-1.5, -0.3, -1.5),
		Vector3(3.0, 4.0, 3.0)
	)

	var fire_process := ParticleProcessMaterial.new()
	fire_process.emission_shape = (
		ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	)
	fire_process.emission_sphere_radius = 0.22
	fire_process.direction = Vector3(0.0, 1.0, 0.0)
	fire_process.spread = 26.0
	fire_process.initial_velocity_min = 0.65
	fire_process.initial_velocity_max = 1.65
	fire_process.gravity = Vector3(0.0, 0.40, 0.0)
	fire_process.scale_min = 0.10
	fire_process.scale_max = 0.32
	fire_process.color = Color(1.0, 0.34, 0.035, 0.92)
	fire.process_material = fire_process

	var fire_quad := QuadMesh.new()
	fire_quad.size = Vector2(0.36, 0.52)
	var fire_material := StandardMaterial3D.new()
	fire_material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)
	fire_material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)
	fire_material.billboard_mode = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	fire_material.albedo_color = Color(1.0, 0.26, 0.025, 0.85)
	fire_material.emission_enabled = true
	fire_material.emission = Color(1.0, 0.18, 0.01)
	fire_quad.material = fire_material
	fire.draw_pass_1 = fire_quad
	root.add_child(fire)
	fire.emitting = true

	var light := OmniLight3D.new()
	light.name = "FireLight"
	light.position.y = 1.55
	light.light_color = Color(1.0, 0.37, 0.11)
	light.light_energy = 2.2
	light.omni_range = 7.5
	light.shadow_enabled = false
	root.add_child(light)

func _make_smoke_column(
	node_name: String,
	position: Vector3,
	height: float = 12.0
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var smoke := GPUParticles3D.new()
	smoke.name = node_name
	smoke.position = position
	smoke.amount = 52
	smoke.lifetime = 7.5
	smoke.randomness = 0.82
	smoke.visibility_aabb = AABB(
		Vector3(-5.0, -1.0, -5.0),
		Vector3(10.0, height + 6.0, 10.0)
	)

	var process := ParticleProcessMaterial.new()
	process.emission_shape = (
		ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	)
	process.emission_sphere_radius = 0.70
	process.direction = Vector3(0.08, 1.0, 0.04)
	process.spread = 22.0
	process.initial_velocity_min = 0.65
	process.initial_velocity_max = 1.55
	process.gravity = Vector3(0.025, 0.05, 0.01)
	process.scale_min = 0.55
	process.scale_max = 1.85
	process.color = Color(0.15, 0.15, 0.14, 0.44)
	smoke.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(2.1, 2.1)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)
	material.billboard_mode = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)
	material.albedo_color = Color(0.18, 0.18, 0.17, 0.40)
	quad.material = material
	smoke.draw_pass_1 = quad
	add_child(smoke)
	smoke.emitting = true

func _make_objective_zone_light(
	node_name: String,
	position: Vector3,
	color: Color
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var light := OmniLight3D.new()
	light.name = node_name
	light.position = position
	light.light_color = color
	light.light_energy = 1.45
	light.omni_range = 9.0
	light.shadow_enabled = false
	add_child(light)

func _build_combat_atmosphere_pass() -> void:
	for barricade_data in [
		["VillageBarricade",Vector3(-25.0,0.0,-7.0),0.10],
		["RailBarricade",Vector3(13.0,0.0,-24.0),-0.08],
		["FortBarricade",Vector3(27.0,0.0,17.0),0.48],
		["SouthBarricade",Vector3(-4.0,0.0,37.0),0.0]
	]:
		_make_road_barricade(
			str(barricade_data[0]),
			Vector3(barricade_data[1]),
			float(barricade_data[2])
		)

	for fire_position in [
		Vector3(-31.0,0.0,-10.0),
		Vector3(19.0,0.0,-19.0),
		Vector3(39.0,0.0,17.0)
	]:
		_make_fire_barrel(
			"FireBarrel_%s" % str(fire_position),
			fire_position
		)

	for smoke_data in [
		[Vector3(-48.0,0.4,28.0),14.0],
		[Vector3(42.0,0.4,-15.0),16.0],
		[Vector3(29.0,0.4,30.0),12.0]
	]:
		_make_smoke_column(
			"SmokeColumn_%s" % str(smoke_data[0]),
			Vector3(smoke_data[0]),
			float(smoke_data[1])
		)

	_make_objective_zone_light(
		"BridgeObjectiveLight",
		Vector3(0.0,2.2,0.0),
		Color(0.95,0.67,0.26)
	)
	_make_objective_zone_light(
		"FortObjectiveLight",
		Vector3(34.0,2.2,28.0),
		Color(0.70,0.25,0.16)
	)

func _generated_surface_material(
	node_name: String,
	fallback_color: Color
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = fallback_color
	material.roughness = 0.88

	var lower_name := node_name.to_lower()
	var albedo_path := ""
	var roughness_path := ""

	if "brick" in lower_name or "townhouse" in lower_name:
		albedo_path = "res://assets/pbr/generated/brick_wall_albedo.png"
		roughness_path = "res://assets/pbr/generated/brick_wall_roughness.png"
	elif "plaster" in lower_name or "apartment" in lower_name:
		albedo_path = "res://assets/pbr/generated/plaster_albedo.png"
		roughness_path = "res://assets/pbr/generated/plaster_roughness.png"
	elif "ground" in lower_name or "road" in lower_name:
		albedo_path = "res://assets/pbr/generated/cobblestone_albedo.png"
		roughness_path = "res://assets/pbr/generated/cobblestone_roughness.png"
	elif (
		"wood" in lower_name
		or "cover" in lower_name
		or "crate" in lower_name
		or "barricade" in lower_name
	):
		albedo_path = "res://assets/pbr/generated/wood_albedo.png"
		roughness_path = "res://assets/pbr/generated/wood_roughness.png"
	elif "metal" in lower_name or "rail" in lower_name:
		albedo_path = "res://assets/pbr/generated/aged_metal_albedo.png"
		roughness_path = "res://assets/pbr/generated/aged_metal_roughness.png"

	if albedo_path != "" and ResourceLoader.exists(albedo_path):
		material.albedo_texture = load(albedo_path) as Texture2D
		material.uv1_scale = Vector3(2.0, 2.0, 2.0)
	if roughness_path != "" and ResourceLoader.exists(roughness_path):
		material.roughness_texture = load(roughness_path) as Texture2D

	return material

func _make_gameplay_block(
	node_name: String,
	position: Vector3,
	size: Vector3,
	color: Color,
	rotation_y: float = 0.0
) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 1
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = position
	body.rotation.y = rotation_y
	add_child(body)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	if DisplayServer.get_name() != "headless":
		var visual: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = size
		visual.mesh = mesh
		var material: StandardMaterial3D = (
			_generated_surface_material(node_name, color)
		)
		visual.material_override = material
		body.add_child(visual)
	return body

func _make_local_structure_block(
	parent: Node3D,
	node_name: String,
	local_position: Vector3,
	size: Vector3,
	color: Color
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = local_position
	body.collision_layer = 1
	body.collision_mask = 1
	body.set_meta("authoritative_structure_collision", true)
	parent.add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	if DisplayServer.get_name() != "headless":
		var visual := MeshInstance3D.new()
		visual.name = "%s_Visual" % node_name
		var mesh := BoxMesh.new()
		mesh.size = size
		visual.mesh = mesh
		visual.material_override = _generated_surface_material(
			node_name,
			color
		)
		body.add_child(visual)

	return body

func _make_open_building(
	node_name: String,
	position: Vector3,
	width: float,
	depth: float,
	height: float,
	rotation_y: float,
	wall_color: Color
) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	root.set_meta("authoritative_structure_root", true)
	add_child(root)

	var thickness := 0.42
	var doorway_width := 2.3
	var side_width: float = (
		width - doorway_width
	) * 0.5

	var part_data: Array = [
		[
			"Floor",
			Vector3(0.0, 0.10, 0.0),
			Vector3(width, 0.20, depth),
			Color(0.24, 0.24, 0.22)
		],
		[
			"BackWall",
			Vector3(0.0, height * 0.5, depth * 0.5),
			Vector3(width, height, thickness),
			wall_color
		],
		[
			"LeftWall",
			Vector3(-width * 0.5, height * 0.5, 0.0),
			Vector3(thickness, height, depth),
			wall_color
		],
		[
			"RightWall",
			Vector3(width * 0.5, height * 0.5, 0.0),
			Vector3(thickness, height, depth),
			wall_color
		],
		[
			"FrontLeftWall",
			Vector3(
				-(doorway_width + side_width) * 0.5,
				height * 0.5,
				-depth * 0.5
			),
			Vector3(side_width, height, thickness),
			wall_color
		],
		[
			"FrontRightWall",
			Vector3(
				(doorway_width + side_width) * 0.5,
				height * 0.5,
				-depth * 0.5
			),
			Vector3(side_width, height, thickness),
			wall_color
		],
		[
			"Roof",
			Vector3(0.0, height + 0.16, 0.0),
			Vector3(
				width + 0.35,
				0.32,
				depth + 0.35
			),
			Color(0.13, 0.15, 0.16)
		]
	]

	for item in part_data:
		_make_local_structure_block(
			root,
			"%s_%s" % [node_name, str(item[0])],
			Vector3(item[1]),
			Vector3(item[2]),
			Color(item[3])
		)

	return root

func _make_tunnel_segment(
	node_name: String,
	position: Vector3,
	length: float,
	rotation_y: float
) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	var width := 4.4
	var height := 3.4
	var concrete := Color(0.30,0.31,0.29)
	var tunnel_parts: Array = [
		["Floor", Vector3(0.0,-0.12,0.0), Vector3(width,0.24,length)],
		["Ceiling", Vector3(0.0,height,0.0), Vector3(width,0.34,length)],
		["LeftWall", Vector3(-width*0.5,height*0.5,0.0), Vector3(0.42,height,length)],
		["RightWall", Vector3(width*0.5,height*0.5,0.0), Vector3(0.42,height,length)]
	]
	for item in tunnel_parts:
		var part: StaticBody3D = _make_gameplay_block(
			"%s_%s" % [node_name, str(item[0])],
			position,
			Vector3(item[2]),
			concrete,
			rotation_y
		)
		part.reparent(root)
		part.position = Vector3(item[1])
		part.rotation.y = 0.0

	if DisplayServer.get_name() != "headless":
		for lamp_z in range(int(-length*0.5+4.0), int(length*0.5), 8):
			var light := OmniLight3D.new()
			light.position = Vector3(0.0,2.75,float(lamp_z))
			light.light_color = Color(1.0,0.62,0.28)
			light.light_energy = 0.65
			light.omni_range = 5.0
			light.shadow_enabled = false
			root.add_child(light)
	return root

func _make_spawn_staging_area(
	team_id: int,
	position: Vector3
) -> void:
	# Staging is deliberately open. Earlier enclosed shells overlapped spawn
	# capsules and trapped bots against their own deployment geometry.
	var facing: float = 0.0 if team_id == 0 else PI
	var floor_color := (
		Color(0.16, 0.25, 0.31)
		if team_id == 0
		else Color(0.30, 0.16, 0.13)
	)

	_make_gameplay_block(
		"AttackerStagingFloor" if team_id == 0 else "DefenderStagingFloor",
		position + Vector3(0.0, -0.10, 0.0),
		Vector3(18.0, 0.20, 16.0),
		floor_color,
		facing
	)

	# Rear protection only; all forward and side exits remain unobstructed.
	var rear_offset: Vector3 = Vector3(0.0, 2.0, 7.5).rotated(
		Vector3.UP,
		facing
	)
	_make_gameplay_block(
		"AttackerRearWall" if team_id == 0 else "DefenderRearWall",
		position + rear_offset,
		Vector3(16.0, 4.0, 0.45),
		Color(0.25, 0.22, 0.18),
		facing
	)

	for cover_position in [
		Vector3(-5.5, 0.55, 2.5),
		Vector3(0.0, 0.55, 3.8),
		Vector3(5.5, 0.55, 2.5)
	]:
		var offset: Vector3 = cover_position.rotated(
			Vector3.UP,
			facing
		)
		_make_gameplay_block(
			"StagingCover_%d_%s" % [
				team_id,
				str(cover_position.x)
			],
			position + offset,
			Vector3(2.4, 1.1, 0.65),
			Color(0.29, 0.23, 0.15),
			facing
		)

func _build_map_expansion_pass() -> void:
	_make_spawn_staging_area(0, Vector3(-56.0,0.0,-10.0))
	_make_spawn_staging_area(1, Vector3(56.0,0.0,10.0))

	for building_data in [
		["NorthApartmentA",Vector3(-31.0,0.0,-50.0),13.0,11.0,6.5,0.0,Color(0.48,0.42,0.34)],
		["NorthApartmentB",Vector3(-12.0,0.0,-50.0),12.0,10.0,6.0,0.04,Color(0.40,0.34,0.29)],
		["NorthWorkshop",Vector3(10.0,0.0,-50.0),15.0,11.0,5.0,-0.03,Color(0.38,0.31,0.25)],
		["NorthWarehouseAnnex",Vector3(34.0,0.0,-49.0),17.0,12.0,5.8,0.02,Color(0.35,0.30,0.27)],
		["SouthFarmhouse",Vector3(-34.0,0.0,51.0),13.0,11.0,5.8,PI,Color(0.48,0.43,0.34)],
		["SouthMachineShop",Vector3(-10.0,0.0,51.0),16.0,11.0,5.2,PI,Color(0.34,0.31,0.27)],
		["SouthBarracks",Vector3(18.0,0.0,51.0),17.0,12.0,5.8,PI,Color(0.39,0.34,0.28)],
		["SouthFortAnnex",Vector3(42.0,0.0,50.0),13.0,10.0,5.2,PI,Color(0.31,0.31,0.29)]
	]:
		_make_open_building(
			str(building_data[0]), Vector3(building_data[1]),
			float(building_data[2]), float(building_data[3]),
			float(building_data[4]), float(building_data[5]),
			Color(building_data[6])
		)

	_make_tunnel_segment("VillageSewerWest",Vector3(-29.0,-3.3,10.0),26.0,PI*0.5)
	_make_tunnel_segment("VillageSewerEast",Vector3(-5.0,-3.3,10.0),24.0,PI*0.5)

	for ramp_data in [
		["SewerRampWest",Vector3(-43.0,-1.5,10.0),deg_to_rad(-16.0)],
		["SewerRampEast",Vector3(8.0,-1.5,10.0),deg_to_rad(16.0)]
	]:
		var ramp: StaticBody3D = _make_gameplay_block(
			str(ramp_data[0]), Vector3(ramp_data[1]),
			Vector3(10.0,0.45,4.0), Color(0.27,0.27,0.25), PI*0.5
		)
		ramp.rotation.z = float(ramp_data[2])

	for cover_data in [
		[Vector3(-39.0,0.8,-37.0),0.18],
		[Vector3(-20.0,0.8,-37.0),-0.14],
		[Vector3(2.0,0.8,-38.0),0.10],
		[Vector3(25.0,0.8,-38.0),-0.12],
		[Vector3(-36.0,0.8,38.0),-0.10],
		[Vector3(-14.0,0.8,38.0),0.12],
		[Vector3(10.0,0.8,38.0),-0.15],
		[Vector3(34.0,0.8,38.0),0.13]
	]:
		_make_gameplay_block(
			"RouteCover_%s" % str(cover_data[0]),
			Vector3(cover_data[0]), Vector3(4.2,1.6,0.8),
			Color(0.31,0.24,0.15), float(cover_data[1])
		)

func _collision_box(
	parent: Node3D,
	node_name: String,
	local_position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0
) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = local_position
	body.rotation.y = rotation_y

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)

	if collision_debug_enabled and DisplayServer.get_name() != "headless":
		var visual: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = size
		visual.mesh = mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.1, 0.95, 0.25, 0.18)
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		visual.material_override = material
		body.add_child(visual)

	return body

func _create_aligned_facade_collision(
	node_name: String,
	position: Vector3,
	rotation_y: float,
	width: float,
	depth: float,
	height: float,
	front_offset: float,
	door_center_x: float = 0.0,
	door_width: float = 2.0,
	door_height: float = 2.8,
	has_door: bool = true,
	back_wall: bool = true
) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)
	structure_collision_roots.append(root)

	var wall_thickness := 0.24
	var half_width: float = width * 0.5
	var half_depth: float = depth * 0.5
	var front_z: float = front_offset

	# The façade is segmented around the actual visible doorway rather than
	# represented by a broad shell extending beyond the rendered model.
	if has_door:
		var left_width: float = maxf(
			0.20,
			door_center_x - door_width * 0.5 + half_width
		)
		var right_width: float = maxf(
			0.20,
			half_width - door_center_x - door_width * 0.5
		)

		if left_width > 0.22:
			_collision_box(
				root,
				"FacadeLeft",
				Vector3(
					-half_width + left_width * 0.5,
					height * 0.5,
					front_z
				),
				Vector3(left_width, height, wall_thickness)
			)

		if right_width > 0.22:
			_collision_box(
				root,
				"FacadeRight",
				Vector3(
					half_width - right_width * 0.5,
					height * 0.5,
					front_z
				),
				Vector3(right_width, height, wall_thickness)
			)

		if height > door_height:
			_collision_box(
				root,
				"FacadeLintel",
				Vector3(
					door_center_x,
					door_height + (height - door_height) * 0.5,
					front_z
				),
				Vector3(
					door_width,
					height - door_height,
					wall_thickness
				)
			)
	else:
		_collision_box(
			root,
			"Facade",
			Vector3(0.0, height * 0.5, front_z),
			Vector3(width, height, wall_thickness)
		)

	# Thin side walls follow the rendered footprint closely.
	_collision_box(
		root,
		"LeftSide",
		Vector3(
			-half_width,
			height * 0.5,
			front_z + depth * 0.5
		),
		Vector3(wall_thickness, height, depth)
	)
	_collision_box(
		root,
		"RightSide",
		Vector3(
			half_width,
			height * 0.5,
			front_z + depth * 0.5
		),
		Vector3(wall_thickness, height, depth)
	)

	if back_wall:
		_collision_box(
			root,
			"RearWall",
			Vector3(
				0.0,
				height * 0.5,
				front_z + depth
			),
			Vector3(width, height, wall_thickness)
		)

	return root

func _create_wall_segment_collision(
	node_name: String,
	position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0
) -> StaticBody3D:
	var body: StaticBody3D = _make_gameplay_block(
		node_name,
		position,
		size,
		Color(0.42, 0.40, 0.35),
		rotation_y
	)
	return body

func _create_collision_shell(
	node_name: String,
	position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0,
	door_width: float = 2.2,
	door_height: float = 2.8,
	front_open: bool = true,
	back_open: bool = false
) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)
	structure_collision_roots.append(root)

	var thickness := 0.40
	var half_width: float = size.x * 0.5
	var half_depth: float = size.z * 0.5
	var wall_height: float = size.y
	var side_width: float = maxf(
		0.25,
		(size.x - door_width) * 0.5
	)

	_collision_box(
		root,
		"Floor",
		Vector3(0.0, 0.10, 0.0),
		Vector3(size.x, 0.20, size.z)
	)
	_collision_box(
		root,
		"Roof",
		Vector3(0.0, wall_height + 0.16, 0.0),
		Vector3(size.x, 0.32, size.z)
	)
	_collision_box(
		root,
		"LeftWall",
		Vector3(-half_width, wall_height * 0.5, 0.0),
		Vector3(thickness, wall_height, size.z)
	)
	_collision_box(
		root,
		"RightWall",
		Vector3(half_width, wall_height * 0.5, 0.0),
		Vector3(thickness, wall_height, size.z)
	)

	if front_open:
		_collision_box(
			root,
			"FrontLeft",
			Vector3(
				-(door_width + side_width) * 0.5,
				wall_height * 0.5,
				-half_depth
			),
			Vector3(side_width, wall_height, thickness)
		)
		_collision_box(
			root,
			"FrontRight",
			Vector3(
				(door_width + side_width) * 0.5,
				wall_height * 0.5,
				-half_depth
			),
			Vector3(side_width, wall_height, thickness)
		)
		if wall_height > door_height:
			_collision_box(
				root,
				"FrontLintel",
				Vector3(
					0.0,
					door_height + (
						wall_height - door_height
					) * 0.5,
					-half_depth
				),
				Vector3(
					door_width,
					wall_height - door_height,
					thickness
				)
			)
	else:
		_collision_box(
			root,
			"FrontWall",
			Vector3(0.0, wall_height * 0.5, -half_depth),
			Vector3(size.x, wall_height, thickness)
		)

	if back_open:
		_collision_box(
			root,
			"BackLeft",
			Vector3(
				-(door_width + side_width) * 0.5,
				wall_height * 0.5,
				half_depth
			),
			Vector3(side_width, wall_height, thickness)
		)
		_collision_box(
			root,
			"BackRight",
			Vector3(
				(door_width + side_width) * 0.5,
				wall_height * 0.5,
				half_depth
			),
			Vector3(side_width, wall_height, thickness)
		)
	else:
		_collision_box(
			root,
			"BackWall",
			Vector3(0.0, wall_height * 0.5, half_depth),
			Vector3(size.x, wall_height, thickness)
		)

	return root

func _create_solid_collision_proxy(
	node_name: String,
	position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0
) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)
	structure_collision_roots.append(root)
	_collision_box(
		root,
		"Solid",
		Vector3(0.0, size.y * 0.5, 0.0),
		size
	)
	return root

func _add_interior_cover(
	parent_position: Vector3,
	rotation_y: float,
	prefix: String
) -> void:
	for cover_data in [
		[Vector3(-2.8,0.55,1.2),Vector3(2.4,1.1,0.65)],
		[Vector3(2.7,0.55,-1.4),Vector3(2.2,1.1,0.65)],
		[Vector3(0.0,0.45,3.0),Vector3(1.6,0.9,1.2)]
	]:
		var local_position: Vector3 = Vector3(cover_data[0])
		var world_offset: Vector3 = local_position.rotated(
			Vector3.UP,
			rotation_y
		)
		_make_gameplay_block(
			"%s_%s" % [prefix, str(local_position)],
			parent_position + world_offset,
			Vector3(cover_data[1]),
			Color(0.28,0.21,0.13),
			rotation_y
		)

func _build_structure_collision_pass() -> void:
	# Townhouse and plaster structures now use exact collision generated from
	# their visible scene meshes. Do not add broad solid fallback volumes here.
	# Those proxies caused invisible walls and still failed to match openings.

	# Large imported landmarks.
	_create_collision_shell(
		"Church_ServerCollision",
		Vector3(-42.0,0.0,9.0),
		Vector3(9.2,8.8,17.2),
		deg_to_rad(7.0),
		2.2,
		3.4,
		true,
		false
	)
	_create_collision_shell(
		"Warehouse_ServerCollision",
		Vector3(47.0,0.0,-18.0),
		Vector3(17.2,7.0,9.2),
		deg_to_rad(-2.0),
		5.0,
		4.4,
		true,
		false
	)
	_create_collision_shell(
		"FortBunker_ServerCollision",
		Vector3(33.0,0.0,28.0),
		Vector3(7.7,4.5,5.9),
		PI,
		1.5,
		2.3,
		true,
		false
	)

	# Rail cars and vehicle props.
	for car_position in [
		Vector3(19.0,0.0,-20.5),
		Vector3(29.0,0.0,-20.5),
		Vector3(39.0,0.0,-20.5)
	]:
		_create_solid_collision_proxy(
			"RailCarCollision_%s" % str(car_position),
			car_position,
			Vector3(8.2,3.6,3.2),
			0.0
		)

	_create_solid_collision_proxy(
		"HalftrackVillageCollision",
		Vector3(-25.0,0.0,-8.0),
		Vector3(6.0,3.0,2.6),
		deg_to_rad(14.0)
	)
	_create_solid_collision_proxy(
		"HalftrackFortCollision",
		Vector3(25.0,0.0,14.0),
		Vector3(5.7,2.9,2.5),
		deg_to_rad(-32.0)
	)

	# Interior fighting cover for the new open buildings.
	for interior_data in [
		[Vector3(-31.0,0.0,-50.0),0.0,"NorthApartmentAInterior"],
		[Vector3(-12.0,0.0,-50.0),0.04,"NorthApartmentBInterior"],
		[Vector3(10.0,0.0,-50.0),-0.03,"NorthWorkshopInterior"],
		[Vector3(34.0,0.0,-49.0),0.02,"NorthWarehouseInterior"],
		[Vector3(-34.0,0.0,51.0),PI,"SouthFarmhouseInterior"],
		[Vector3(-10.0,0.0,51.0),PI,"SouthMachineShopInterior"],
		[Vector3(18.0,0.0,51.0),PI,"SouthBarracksInterior"],
		[Vector3(42.0,0.0,50.0),PI,"SouthFortAnnexInterior"]
	]:
		_add_interior_cover(
			Vector3(interior_data[0]),
			float(interior_data[1]),
			str(interior_data[2])
		)

func _collision_root_horizontal_extent(
	root: Node3D
) -> Vector2:
	var maximum := Vector2.ZERO
	for child in root.get_children():
		if not child is StaticBody3D:
			continue
		var body := child as StaticBody3D
		for body_child in body.get_children():
			if not body_child is CollisionShape3D:
				continue
			var collision := body_child as CollisionShape3D
			if collision.shape is BoxShape3D:
				var box := collision.shape as BoxShape3D
				maximum.x = maxf(
					maximum.x,
					absf(body.position.x) + box.size.x * 0.5
				)
				maximum.y = maxf(
					maximum.y,
					absf(body.position.z) + box.size.z * 0.5
				)
	return maximum

func _validate_structure_collision_layout() -> void:
	# Lightweight startup validation; logs missing/invalid proxies.
	for collision_root in structure_collision_roots:
		if collision_root == null or not is_instance_valid(collision_root):
			push_error("Invalid structure collision root")
			continue
		var shape_count := 0
		for child in collision_root.get_children():
			if child is StaticBody3D:
				for body_child in child.get_children():
					if body_child is CollisionShape3D:
						var shape_node := body_child as CollisionShape3D
						if shape_node.shape != null:
							shape_count += 1
		if shape_count == 0:
			push_error(
				"Structure collision has no shapes: %s"
				% collision_root.name
			)
			continue

		var horizontal_extent: Vector2 = (
			_collision_root_horizontal_extent(collision_root)
		)
		if horizontal_extent.x > 12.0 or horizontal_extent.y > 14.0:
			push_warning(
				"Large collision proxy requires review: %s extent=%s"
				% [collision_root.name, horizontal_extent]
			)

func _make_ground_collision_tile(
	node_name: String,
	position: Vector3,
	size: Vector3
) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = position
	add_child(body)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	if collision_debug_enabled and DisplayServer.get_name() != "headless":
		var visual: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = size
		visual.mesh = mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.18, 0.72, 1.0, 0.16)
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		visual.material_override = material
		body.add_child(visual)

	return body

func _build_expanded_ground_collision() -> void:
	# Continuous collision under the full surface combat area.
	# The top sits at y = 0.0 while the body extends downward.
	for tile_data in [
		["GroundCenter", Vector3(0.0,-1.0,0.0), Vector3(104.0,2.0,84.0)],
		["GroundNorth", Vector3(0.0,-1.0,-51.0), Vector3(104.0,2.0,24.0)],
		["GroundSouth", Vector3(0.0,-1.0,51.0), Vector3(104.0,2.0,24.0)],
		["GroundWest", Vector3(-57.0,-1.0,-10.0), Vector3(18.0,2.0,34.0)],
		["GroundEast", Vector3(57.0,-1.0,10.0), Vector3(18.0,2.0,34.0)],
		["GroundNorthWest", Vector3(-50.0,-1.0,-44.0), Vector3(20.0,2.0,22.0)],
		["GroundNorthEast", Vector3(50.0,-1.0,-44.0), Vector3(20.0,2.0,22.0)],
		["GroundSouthWest", Vector3(-50.0,-1.0,44.0), Vector3(20.0,2.0,22.0)],
		["GroundSouthEast", Vector3(50.0,-1.0,44.0), Vector3(20.0,2.0,22.0)]
	]:
		_make_ground_collision_tile(
			str(tile_data[0]),
			Vector3(tile_data[1]),
			Vector3(tile_data[2])
		)

	# Invisible perimeter walls stop players from reaching unsupported visuals.
	for wall_data in [
		["BoundaryWest", Vector3(-67.0,2.5,0.0), Vector3(0.8,5.0,116.0)],
		["BoundaryEast", Vector3(67.0,2.5,0.0), Vector3(0.8,5.0,116.0)],
		["BoundaryNorth", Vector3(0.0,2.5,-63.0), Vector3(134.0,5.0,0.8)],
		["BoundarySouth", Vector3(0.0,2.5,63.0), Vector3(134.0,5.0,0.8)]
	]:
		_make_gameplay_block(
			str(wall_data[0]),
			Vector3(wall_data[1]),
			Vector3(wall_data[2]),
			Color(0.12,0.12,0.12,0.0),
			0.0
		)

func server_recover_out_of_bounds_player(
	peer_id: int,
	team_id: int,
	current_position: Vector3
) -> Vector3:
	if not multiplayer.is_server():
		return current_position

	# Sewer floor is around y=-3.3, so only recover well below it.
	if current_position.y > -12.0:
		return current_position

	return server_recover_stuck_player(
		peer_id,
		team_id,
		current_position
	)

func _apply_high_visual_quality() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var viewport := get_viewport()
	if viewport != null:
		viewport.msaa_3d = Viewport.MSAA_4X
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		viewport.use_taa = true

	var environment_nodes := find_children(
		"*",
		"WorldEnvironment",
		true
	)
	for value in environment_nodes:
		var world_environment := value as WorldEnvironment
		if (
			world_environment != null
			and world_environment.environment != null
		):
			var environment := world_environment.environment
			environment.ssao_enabled = true
			environment.ssao_radius = 2.2
			environment.ssao_intensity = 1.7
			environment.glow_enabled = true
			environment.fog_enabled = true
			environment.fog_density = minf(
				environment.fog_density,
				0.012
			)

func _build_external_asset_overlay() -> void:
	if DisplayServer.get_name() == "headless":
		return

	external_asset_overlay = PanelContainer.new()
	external_asset_overlay.name = "ExternalAssetOverlay"
	external_asset_overlay.set_anchors_preset(
		Control.PRESET_TOP_LEFT
	)
	external_asset_overlay.position = Vector2(18, 62)
	external_asset_overlay.custom_minimum_size = Vector2(480, 260)
	external_asset_overlay.visible = false

	external_asset_overlay_label = Label.new()
	external_asset_overlay_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	external_asset_overlay_label.add_theme_font_size_override(
		"font_size",
		13
	)
	external_asset_overlay.add_child(
		external_asset_overlay_label
	)

	var canvas := CanvasLayer.new()
	canvas.name = "ExternalAssetDebugCanvas"
	canvas.layer = 110
	canvas.add_child(external_asset_overlay)
	add_child(canvas)

func _update_external_asset_overlay() -> void:
	if external_asset_overlay == null:
		return
	external_asset_overlay.visible = (
		external_asset_overlay_visible
	)
	if external_asset_overlay_label != null:
		external_asset_overlay_label.text = (
			"EXTERNAL ASSETS · F10 TO CLOSE\n\n"
			+ "\n\n".join(external_asset_reports)
		)

func _toggle_external_asset_overlay() -> void:
	external_asset_overlay_visible = (
		not external_asset_overlay_visible
	)
	_update_external_asset_overlay()

func _initialize_external_lod() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var controller_instance: Node = (
		ExternalLODControllerScript.new()
	)
	external_lod_controller = controller_instance
	external_lod_controller.name = "ExternalLODController"
	add_child(external_lod_controller)
	if external_lod_controller.has_method("configure"):
		external_lod_controller.call(
			"configure",
			get_viewport().get_camera_3d()
		)

func _spawn_external_environment_assets() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var placements: Array = [
		[
			"village_house_a",
			"ExternalVillageHouseA",
			Vector3(-51.0, 0.0, -27.0),
			deg_to_rad(8.0),
			Vector3.ONE
		],
		[
			"village_house_b",
			"ExternalVillageHouseB",
			Vector3(-52.0, 0.0, -8.0),
			deg_to_rad(-4.0),
			Vector3.ONE
		],
		[
			"ruined_house",
			"ExternalRuinedHouse",
			Vector3(-50.0, 0.0, 13.0),
			deg_to_rad(7.0),
			Vector3.ONE
		],
		[
			"warehouse",
			"ExternalWarehouse",
			Vector3(47.0, 0.0, -18.0),
			deg_to_rad(-2.0),
			Vector3.ONE
		],
		[
			"chainlink_fence",
			"ExternalChainlinkFence",
			Vector3(29.0, 0.0, -34.0),
			0.0,
			Vector3.ONE
		],
		[
			"military_crate",
			"ExternalMilitaryCrate",
			Vector3(8.0, 0.0, -5.0),
			0.25,
			Vector3.ONE
		]
	]

	for placement in placements:
		var asset_id: String = str(placement[0])
		var scene: PackedScene = (
			ExternalAssetRegistryScript.environment_scene(
				asset_id
			)
		)
		if scene == null:
			continue

		var asset_config: Dictionary = (
			ExternalAssetRegistryScript.environment_config(
				asset_id
			)
		)
		var final_position: Vector3 = (
			Vector3(placement[2])
			+ Vector3(
				asset_config.get(
					"offset",
					Vector3.ZERO
				)
			)
		)
		var final_rotation: float = (
			float(placement[3])
			+ float(
				asset_config.get("rotation_y", 0.0)
			)
		)
		var final_scale: Vector3 = (
			Vector3(placement[4])
			* Vector3(
				asset_config.get(
					"scale",
					Vector3.ONE
				)
			)
		)

		var external_node: Node3D = (
			ExternalAssetLoaderScript.instantiate_scene(
				self,
				scene,
				str(placement[1]),
				final_position,
				final_rotation,
				final_scale
			)
		)
		if external_node == null:
			continue

		var target_height := float(
			asset_config.get("target_height", 0.0)
		)
		var adaptation: Dictionary = (
			RealAssetAdapterScript.adapt_environment(
				external_node,
				target_height
			)
		)

		var collision_result: Dictionary = (
			ExternalAssetLoaderScript.ensure_environment_collision(
				external_node,
				bool(
					asset_config.get(
						"generate_collision",
						false
					)
				)
			)
		)

		if bool(collision_result.get("has_collision", false)):
			var fallback_names: Array = Array(
				asset_config.get("hide_fallback", [])
			)
			var string_names: Array[String] = []
			for fallback_name in fallback_names:
				string_names.append(str(fallback_name))
			ExternalAssetLoaderScript.hide_named_nodes(
				self,
				string_names
			)

		var validation: Dictionary = (
			ExternalAssetValidatorScript.validate_environment(
				external_node
			)
		)
		var report_line := (
			"%s\nadaptation=%s\nvalidation=%s\ncollision=%s"
			% [
				asset_id,
				adaptation,
				validation,
				collision_result
			]
		)
		external_asset_reports.append(report_line)
		print(report_line)
		if (
			external_lod_controller != null
			and external_lod_controller.has_method(
				"register_external"
			)
		):
			external_lod_controller.call(
				"register_external",
				external_node
			)

	var availability: Dictionary = (
		ExternalAssetRegistryScript.availability_report()
	)
	print(
		ExternalAssetLoaderScript.build_asset_report(
			self,
			availability
		)
	)

func _load_optional_scene(path: String) -> PackedScene:
	if DisplayServer.get_name() == "headless":
		return null
	if not ResourceLoader.exists(path):
		push_warning("Optional visual scene not imported: %s" % path)
		return null
	var resource: Resource = load(path)
	if resource is PackedScene:
		return resource as PackedScene
	push_warning("Optional visual scene failed: %s" % path)
	return null

func _make_pbr_material(
	albedo: Texture2D,
	normal: Texture2D,
	roughness: Texture2D,
	tint: Color = Color.WHITE,
	scale_value: float = 2.5
) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = tint
	material.albedo_texture = albedo
	material.normal_enabled = normal != null
	material.normal_texture = normal
	material.roughness = 0.82
	material.roughness_texture = roughness
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * scale_value
	return material

func _apply_material_recursive(
	root: Node,
	material: Material
) -> void:
	if root is MeshInstance3D:
		var mesh_instance := root as MeshInstance3D
		mesh_instance.material_override = material
	for child in root.get_children():
		_apply_material_recursive(child, material)

func _set_mesh_visibility_recursive(
	root: Node,
	visible_value: bool
) -> void:
	for node_value in root.find_children(
		"*",
		"VisualInstance3D",
		true
	):
		var visual := node_value as VisualInstance3D
		if visual != null:
			visual.visible = visible_value

func _create_authoritative_townhouse_fallback(
	node_name: String,
	position: Vector3,
	rotation_y: float,
	width: float,
	depth: float,
	height: float,
	door_center_x: float = 0.0,
	door_width: float = 1.8,
	door_height: float = 2.7
) -> Node3D:
	var root := Node3D.new()
	root.name = "%s_ServerFallback" % node_name
	root.position = position
	root.rotation.y = rotation_y
	root.set_meta("authoritative_missing_asset_fallback", true)
	add_child(root)

	var thickness := 0.30
	var half_width := width * 0.5
	var half_depth := depth * 0.5
	var left_width := maxf(
		0.25,
		door_center_x - door_width * 0.5 + half_width
	)
	var right_width := maxf(
		0.25,
		half_width - door_center_x - door_width * 0.5
	)

	_make_local_structure_block(
		root,
		"%s_LeftSide" % node_name,
		Vector3(-half_width, height * 0.5, 0.0),
		Vector3(thickness, height, depth),
		Color(0.44, 0.18, 0.10)
	)
	_make_local_structure_block(
		root,
		"%s_RightSide" % node_name,
		Vector3(half_width, height * 0.5, 0.0),
		Vector3(thickness, height, depth),
		Color(0.58, 0.55, 0.49)
	)
	_make_local_structure_block(
		root,
		"%s_Rear" % node_name,
		Vector3(0.0, height * 0.5, half_depth),
		Vector3(width, height, thickness),
		Color(0.50, 0.47, 0.41)
	)

	if left_width > 0.30:
		_make_local_structure_block(
			root,
			"%s_FrontLeft" % node_name,
			Vector3(
				-half_width + left_width * 0.5,
				height * 0.5,
				-half_depth
			),
			Vector3(left_width, height, thickness),
			Color(0.44, 0.18, 0.10)
		)
	if right_width > 0.30:
		_make_local_structure_block(
			root,
			"%s_FrontRight" % node_name,
			Vector3(
				half_width - right_width * 0.5,
				height * 0.5,
				-half_depth
			),
			Vector3(right_width, height, thickness),
			Color(0.58, 0.55, 0.49)
		)
	if height > door_height:
		_make_local_structure_block(
			root,
			"%s_FrontLintel" % node_name,
			Vector3(
				door_center_x,
				door_height + (height - door_height) * 0.5,
				-half_depth
			),
			Vector3(
				door_width,
				height - door_height,
				thickness
			),
			Color(0.47, 0.30, 0.20)
		)

	print(
		"WARNING: structural asset missing; using doorway-aware fallback: %s"
		% node_name
	)
	return root

func _ensure_combat_effects_manager() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if combat_effects_manager != null:
		return
	combat_effects_manager = CombatEffectsManagerScript.new()
	combat_effects_manager.name = "CombatEffectsManager"
	add_child(combat_effects_manager)

func _build_alley_detail_pass() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if alley_detail_pass != null:
		return
	alley_detail_pass = AlleyDetailPassScript.new()
	alley_detail_pass.name = "AlleyDetailPass"
	add_child(alley_detail_pass)
	if alley_detail_pass.has_method("build"):
		alley_detail_pass.call("build")

func _spawn_structural_scene(
	scene: PackedScene,
	node_name: String,
	position: Vector3,
	rotation_y: float,
	scale_value: Vector3,
	material: Material = null
) -> Node3D:
	if scene == null:
		return null

	var instance := scene.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return null

	var root := instance as Node3D
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	root.scale = scale_value
	root.set_meta("exact_structure_source", true)
	add_child(root)

	if DisplayServer.get_name() != "headless" and material != null:
		_apply_material_recursive(root, material)

	var generated_shapes := 0
	for node_value in root.find_children(
		"*",
		"MeshInstance3D",
		true
	):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var before_count := mesh_instance.get_child_count()
		mesh_instance.create_trimesh_collision()
		for child_index in range(
			before_count,
			mesh_instance.get_child_count()
		):
			var child := mesh_instance.get_child(child_index)
			if child is StaticBody3D:
				var body := child as StaticBody3D
				body.collision_layer = 1
				body.collision_mask = 1
				body.set_meta("exact_structure_collision", true)
				generated_shapes += 1

	if DisplayServer.get_name() == "headless":
		_set_mesh_visibility_recursive(root, false)

	print(
		"Exact structure collision: %s bodies=%d"
		% [node_name, generated_shapes]
	)
	return root

func _build_urban_realism_pass() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if urban_realism_pass != null:
		return
	urban_realism_pass = UrbanRealismPassScript.new()
	urban_realism_pass.name = "UrbanRealismPass"
	add_child(urban_realism_pass)
	if urban_realism_pass.has_method("build"):
		urban_realism_pass.call("build")

func _spawn_visual_scene(
	scene: PackedScene,
	node_name: String,
	position: Vector3,
	rotation_y: float,
	scale_value: Vector3,
	material: Material = null
) -> Node3D:
	if DisplayServer.get_name() == "headless" or scene == null:
		return null
	var instance: Node = scene.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return null
	var root := instance as Node3D
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	root.scale = scale_value
	if material != null:
		_apply_material_recursive(root, material)
	add_child(root)
	return root

func _build_asset_based_village_pass() -> void:
	var plaster_material: Material = null
	var brick_material: Material = null
	var cobble_material: Material = null
	var rubble_material: Material = null

	if DisplayServer.get_name() != "headless":
		plaster_material = _make_pbr_material(
			pbr_plaster_albedo,
			pbr_plaster_normal,
			pbr_plaster_roughness,
			Color(0.96, 0.92, 0.84),
			1.7
		)
		brick_material = _make_pbr_material(
			pbr_brick_albedo,
			pbr_brick_normal,
			pbr_brick_roughness,
			Color(0.90, 0.84, 0.80),
			2.2
		)
		cobble_material = _make_pbr_material(
			pbr_cobble_albedo,
			pbr_cobble_normal,
			pbr_cobble_roughness,
			Color(0.88, 0.90, 0.92),
			3.8
		)
		rubble_material = _make_pbr_material(
			pbr_ground_albedo,
			pbr_ground_normal,
			pbr_ground_roughness,
			Color(0.92, 0.88, 0.82),
			2.8
		)

	for building_data in [
		[
			visual_ruined_townhouse_scene,
			"VisualTownhouseA",
			Vector3(-51.0, 0.0, -27.0),
			deg_to_rad(8.0),
			Vector3(1.05, 1.05, 1.05),
			brick_material,
			Vector3(8.0, 7.4, 6.0),
			-0.75
		],
		[
			visual_townhouse_scene,
			"VisualTownhouseB",
			Vector3(-52.0, 0.0, -8.0),
			deg_to_rad(-4.0),
			Vector3(1.15, 1.10, 1.10),
			plaster_material,
			Vector3(8.4, 7.5, 6.2),
			0.65
		],
		[
			visual_ruined_townhouse_scene,
			"VisualTownhouseC",
			Vector3(-50.0, 0.0, 13.0),
			deg_to_rad(7.0),
			Vector3(1.05, 1.05, 1.05),
			plaster_material,
			Vector3(8.0, 7.4, 6.0),
			-0.35
		],
		[
			visual_townhouse_scene,
			"VisualTownhouseD",
			Vector3(-49.0, 0.0, 34.0),
			deg_to_rad(-9.0),
			Vector3(1.10, 1.12, 1.10),
			brick_material,
			Vector3(8.3, 7.5, 6.2),
			0.55
		]
	]:
		var structure := _spawn_structural_scene(
			building_data[0] as PackedScene,
			str(building_data[1]),
			Vector3(building_data[2]),
			float(building_data[3]),
			Vector3(building_data[4]),
			building_data[5] as Material
		)
		if structure == null:
			var fallback_size := Vector3(building_data[6])
			_create_authoritative_townhouse_fallback(
				str(building_data[1]),
				Vector3(building_data[2]),
				float(building_data[3]),
				fallback_size.x,
				fallback_size.z,
				fallback_size.y,
				float(building_data[7])
			)


	if DisplayServer.get_name() == "headless":
		return

	for rubble_position in [
		Vector3(-45.0, 0.0, -22.0),
		Vector3(-43.0, 0.0, 5.0),
		Vector3(-46.0, 0.0, 27.0),
		Vector3(41.0, 0.0, -14.0)
	]:
		_spawn_visual_scene(
			visual_rubble_scene,
			"RubbleVisual_%s" % str(rubble_position),
			rubble_position,
			randf_range(-0.6, 0.6),
			Vector3.ONE * randf_range(0.8, 1.25),
			rubble_material
		)

	for sandbag_position in [
		Vector3(-35.0, 0.0, -17.0),
		Vector3(-31.0, 0.0, 19.0),
		Vector3(27.0, 0.0, -12.0),
		Vector3(34.0, 0.0, 18.0)
	]:
		_spawn_visual_scene(
			visual_sandbag_scene,
			"SandbagVisual_%s" % str(sandbag_position),
			sandbag_position,
			randf_range(-0.3, 0.3),
			Vector3.ONE,
			rubble_material
		)

	# PBR ground overlays that sit just above gameplay collision ground.
	for ground_data in [
		["PBRVillageStreet", Vector3(-47.0, 0.08, 3.0), Vector3(23.0, 0.10, 88.0), cobble_material],
		["PBRRailStreet", Vector3(39.0, 0.08, -18.0), Vector3(29.0, 0.10, 25.0), rubble_material],
		["PBRFortCourtyard", Vector3(34.0, 0.08, 27.0), Vector3(28.0, 0.10, 22.0), cobble_material]
	]:
		var visual_ground := MeshInstance3D.new()
		visual_ground.name = str(ground_data[0])
		visual_ground.position = Vector3(ground_data[1])
		var ground_mesh := BoxMesh.new()
		ground_mesh.size = Vector3(ground_data[2])
		visual_ground.mesh = ground_mesh
		visual_ground.material_override = ground_data[3] as Material
		add_child(visual_ground)

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

func _create_foliage_sprite(position: Vector3, scale_value: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if tex_foliage == null:
		return

	var sprite := Sprite3D.new()
	sprite.texture = tex_foliage
	sprite.position = position
	sprite.pixel_size = 0.012
	sprite.scale = Vector3.ONE * scale_value
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	add_child(sprite)

func _make_road(
	node_name: String,
	position: Vector3,
	size: Vector3,
	rotation_y: float = 0.0
) -> void:
	var road := MeshInstance3D.new()
	road.name = node_name
	road.position = position
	road.rotation.y = rotation_y

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	road.mesh = mesh

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.17, 0.17)
	material.roughness = 0.94
	road.material_override = material
	add_child(road)

func _make_sloped_ground(
	node_name: String,
	position: Vector3,
	size: Vector3,
	rotation_degrees_value: Vector3,
	color: Color
) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = position
	body.rotation_degrees = rotation_degrees_value

	var mesh_instance := MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.96
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _make_tree(
	position: Vector3,
	scale_value: float = 1.0
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root: Node3D = Node3D.new()
	root.position = position
	root.scale = Vector3.ONE * scale_value
	add_child(root)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.27
	trunk_mesh.height = 3.6
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.8
	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.25, 0.16, 0.09)
	trunk_material.roughness = 1.0
	trunk.material_override = trunk_material
	root.add_child(trunk)

	for crown_position in [
		Vector3(0.0, 4.1, 0.0),
		Vector3(-0.55, 3.7, 0.15),
		Vector3(0.55, 3.75, -0.10)
	]:
		var crown := MeshInstance3D.new()
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 1.25
		crown_mesh.height = 2.2
		crown.mesh = crown_mesh
		crown.position = crown_position
		var crown_material := StandardMaterial3D.new()
		crown_material.albedo_color = Color(
			0.12 + randf_range(0.0, 0.05),
			0.30 + randf_range(0.0, 0.08),
			0.12 + randf_range(0.0, 0.04)
		)
		crown_material.roughness = 0.95
		crown.material_override = crown_material
		root.add_child(crown)

func _make_ruined_house(
	node_name: String,
	position: Vector3,
	rotation_y: float,
	size: Vector3
) -> void:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	var wall_color := Color(0.39, 0.36, 0.32)
	var wall_height: float = size.y

	_make_static_box(
		node_name + "_Back",
		position + Vector3(0.0, wall_height * 0.5, size.z * 0.5),
		Vector3(size.x, wall_height, 0.45),
		wall_color
	)
	_make_static_box(
		node_name + "_Left",
		position + Vector3(-size.x * 0.5, wall_height * 0.5, 0.0),
		Vector3(0.45, wall_height, size.z),
		wall_color
	)
	_make_static_box(
		node_name + "_RightBroken",
		position + Vector3(size.x * 0.5, wall_height * 0.30, 0.7),
		Vector3(0.45, wall_height * 0.60, size.z * 0.55),
		wall_color.darkened(0.08)
	)
	_make_static_box(
		node_name + "_Floor",
		position + Vector3(0.0, 0.15, 0.0),
		Vector3(size.x, 0.30, size.z),
		Color(0.24, 0.22, 0.20)
	)

func _make_watchtower(
	node_name: String,
	position: Vector3
) -> void:
	_make_static_box(
		node_name + "_Platform",
		position + Vector3(0.0, 4.3, 0.0),
		Vector3(4.2, 0.5, 4.2),
		Color(0.27, 0.25, 0.21)
	)
	for offset in [
		Vector3(-1.65, 2.0, -1.65),
		Vector3(1.65, 2.0, -1.65),
		Vector3(-1.65, 2.0, 1.65),
		Vector3(1.65, 2.0, 1.65)
	]:
		_make_static_box(
			node_name + "_Leg_%s" % str(offset),
			position + offset,
			Vector3(0.35, 4.0, 0.35),
			Color(0.22, 0.20, 0.17)
		)
	_make_static_box(
		node_name + "_Roof",
		position + Vector3(0.0, 6.0, 0.0),
		Vector3(5.0, 0.35, 5.0),
		Color(0.20, 0.20, 0.20)
	)

func _make_cobblestone_square(
	node_name: String,
	center: Vector3,
	columns: int,
	rows: int,
	tile_size: float
) -> void:
	for x_index in range(columns):
		for z_index in range(rows):
			var offset_x: float = (
				float(x_index) - float(columns - 1) * 0.5
			) * tile_size
			var offset_z: float = (
				float(z_index) - float(rows - 1) * 0.5
			) * tile_size
			var variation: float = randf_range(-0.035, 0.035)
			_make_static_box(
				"%s_%d_%d" % [node_name, x_index, z_index],
				center + Vector3(offset_x, 0.03 + variation, offset_z),
				Vector3(tile_size * 0.94, 0.10, tile_size * 0.94),
				Color(
					randf_range(0.28, 0.38),
					randf_range(0.27, 0.36),
					randf_range(0.25, 0.33)
				)
			)

func _make_wwii_apartment(
	node_name: String,
	position: Vector3,
	width: float,
	depth: float,
	floors: int,
	damaged: bool = false
) -> void:
	var floor_height := 3.1
	var total_height: float = float(floors) * floor_height
	var wall_color := Color(0.43, 0.39, 0.34)

	_make_static_box(
		node_name + "_Rear",
		position + Vector3(0.0, total_height * 0.5, depth * 0.5),
		Vector3(width, total_height, 0.55),
		wall_color
	)
	_make_static_box(
		node_name + "_Left",
		position + Vector3(-width * 0.5, total_height * 0.5, 0.0),
		Vector3(0.55, total_height, depth),
		wall_color.darkened(0.04)
	)
	_make_static_box(
		node_name + "_Right",
		position + Vector3(width * 0.5, total_height * 0.5, 0.0),
		Vector3(0.55, total_height, depth),
		wall_color.darkened(0.02)
	)

	for floor_index in range(floors):
		var y: float = float(floor_index) * floor_height + 0.18
		_make_static_box(
			"%s_Floor_%d" % [node_name, floor_index],
			position + Vector3(0.0, y, 0.0),
			Vector3(width, 0.32, depth),
			Color(0.24, 0.22, 0.20)
		)

		for side in [-1.0, 1.0]:
			var front_piece_width: float = width * 0.28
			var front_y: float = (
				float(floor_index) * floor_height
				+ floor_height * 0.56
			)
			if damaged and floor_index == floors - 1 and side > 0.0:
				continue
			_make_static_box(
				"%s_Front_%d_%s" % [
					node_name,
					floor_index,
					str(side)
				],
				position + Vector3(
					side * width * 0.34,
					front_y,
					-depth * 0.5
				),
				Vector3(
					front_piece_width,
					floor_height * 0.88,
					0.55
				),
				wall_color
			)

	# Dark window recesses and lintels.
	for floor_index in range(floors):
		for window_index in [-1, 0, 1]:
			if damaged and floor_index == floors - 1 and window_index == 1:
				continue
			var window_x: float = float(window_index) * width * 0.25
			var window_y: float = (
				float(floor_index) * floor_height + 1.75
			)
			_make_static_box(
				"%s_Window_%d_%d" % [
					node_name,
					floor_index,
					window_index
				],
				position + Vector3(window_x, window_y, -depth * 0.51),
				Vector3(width * 0.13, 1.15, 0.12),
				Color(0.055, 0.065, 0.070)
			)

	# Pitched dark roof.
	_make_sloped_ground(
		node_name + "_RoofA",
		position + Vector3(-width * 0.22, total_height + 0.85, 0.0),
		Vector3(width * 0.56, 0.32, depth + 0.5),
		Vector3(0.0, 0.0, -22.0),
		Color(0.18, 0.14, 0.12)
	)
	_make_sloped_ground(
		node_name + "_RoofB",
		position + Vector3(width * 0.22, total_height + 0.85, 0.0),
		Vector3(width * 0.56, 0.32, depth + 0.5),
		Vector3(0.0, 0.0, 22.0),
		Color(0.18, 0.14, 0.12)
	)

func _make_sandbag_wall(
	node_name: String,
	position: Vector3,
	length: int,
	rotation_y: float = 0.0
) -> void:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	root.rotation.y = rotation_y
	add_child(root)

	for row in range(2):
		for index in range(length):
			var bag := MeshInstance3D.new()
			var mesh := CapsuleMesh.new()
			mesh.radius = 0.24
			mesh.height = 0.78
			mesh.radial_segments = 12
			mesh.rings = 6
			bag.mesh = mesh
			bag.rotation_degrees.z = 90.0
			bag.position = Vector3(
				float(index) * 0.68 - float(length - 1) * 0.34,
				0.26 + float(row) * 0.38,
				0.10 if (index + row) % 2 == 0 else -0.10
			)
			var material: StandardMaterial3D = StandardMaterial3D.new()
			material.albedo_color = Color(
				randf_range(0.38, 0.46),
				randf_range(0.34, 0.41),
				randf_range(0.22, 0.28)
			)
			material.roughness = 1.0
			bag.material_override = material
			root.add_child(bag)

func _make_street_lamp(
	node_name: String,
	position: Vector3
) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.position = position
	add_child(root)

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.07
	pole_mesh.bottom_radius = 0.10
	pole_mesh.height = 4.8
	pole.mesh = pole_mesh
	pole.position.y = 2.4
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.08, 0.09, 0.09)
	metal.metallic = 0.55
	metal.roughness = 0.40
	pole.material_override = metal
	root.add_child(pole)

	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.0, 4.35, 0.0)
	lamp.omni_range = 9.0
	lamp.light_color = Color(1.0, 0.72, 0.38)
	lamp.light_energy = 1.25
	root.add_child(lamp)

func _build_operation_black_river_expansion() -> void:
	# Large outer terrain, roughly 92 x 76 meters.
	_make_static_box(
		"OuterGroundWest",
		Vector3(-27.0, -0.65, 0.0),
		Vector3(34.0, 1.3, 74.0),
		Color(0.18, 0.25, 0.17)
	)
	_make_static_box(
		"OuterGroundEast",
		Vector3(27.0, -0.65, 0.0),
		Vector3(34.0, 1.3, 74.0),
		Color(0.18, 0.25, 0.17)
	)
	_make_static_box(
		"OuterRiverNorth",
		Vector3(0.0, -1.05, -25.0),
		Vector3(6.0, 0.35, 26.0),
		Color(0.07, 0.20, 0.28)
	)
	_make_static_box(
		"OuterRiverSouth",
		Vector3(0.0, -1.05, 25.0),
		Vector3(6.0, 0.35, 26.0),
		Color(0.07, 0.20, 0.28)
	)

	# Main roads and side routes.
	_make_road(
		"WestVillageRoad",
		Vector3(-20.0, 0.04, 0.0),
		Vector3(7.0, 0.08, 72.0)
	)
	_make_road(
		"EastFortRoad",
		Vector3(20.0, 0.04, 0.0),
		Vector3(7.0, 0.08, 72.0)
	)
	_make_road(
		"NorthCrossRoad",
		Vector3(0.0, 0.05, -27.0),
		Vector3(42.0, 0.10, 5.0)
	)
	_make_road(
		"SouthCrossRoad",
		Vector3(0.0, 0.05, 27.0),
		Vector3(42.0, 0.10, 5.0)
	)

	# Village sector.
	_make_ruined_house(
		"VillageHouseA",
		Vector3(-27.0, 0.0, -19.0),
		deg_to_rad(8.0),
		Vector3(7.0, 4.5, 6.0)
	)
	_make_ruined_house(
		"VillageHouseB",
		Vector3(-29.0, 0.0, 2.0),
		deg_to_rad(-6.0),
		Vector3(8.0, 5.0, 6.5)
	)
	_make_ruined_house(
		"VillageHouseC",
		Vector3(-25.0, 0.0, 21.0),
		deg_to_rad(12.0),
		Vector3(6.5, 4.2, 7.0)
	)
	_make_watchtower(
		"VillageWatchtower",
		Vector3(-36.0, 0.0, -29.0)
	)

	# Rail-yard sector.
	for rail_z in [-23.0, -19.5, -16.0]:
		_make_static_box(
			"Rail_%s_A" % str(rail_z),
			Vector3(25.0, 0.12, rail_z),
			Vector3(30.0, 0.16, 0.18),
			Color(0.25, 0.26, 0.27)
		)
		_make_static_box(
			"Rail_%s_B" % str(rail_z),
			Vector3(25.0, 0.12, rail_z + 1.1),
			Vector3(30.0, 0.16, 0.18),
			Color(0.25, 0.26, 0.27)
		)
	for car_x in [14.0, 24.0, 34.0]:
		_make_static_box(
			"RailCar_%s" % str(car_x),
			Vector3(car_x, 1.6, -20.5),
			Vector3(7.5, 3.2, 2.8),
			Color(0.26, 0.30, 0.31)
		)

	# Fort/bunker sector.
	_make_static_box(
		"FortNorthWall",
		Vector3(30.0, 2.5, 16.0),
		Vector3(24.0, 5.0, 1.0),
		Color(0.33, 0.34, 0.34)
	)
	_make_static_box(
		"FortSouthWall",
		Vector3(30.0, 2.5, 34.0),
		Vector3(24.0, 5.0, 1.0),
		Color(0.33, 0.34, 0.34)
	)
	_make_static_box(
		"FortEastWall",
		Vector3(42.0, 2.5, 25.0),
		Vector3(1.0, 5.0, 19.0),
		Color(0.33, 0.34, 0.34)
	)
	_make_static_box(
		"FortWestGateA",
		Vector3(18.0, 2.5, 19.0),
		Vector3(1.0, 5.0, 6.0),
		Color(0.33, 0.34, 0.34)
	)
	_make_static_box(
		"FortWestGateB",
		Vector3(18.0, 2.5, 31.0),
		Vector3(1.0, 5.0, 6.0),
		Color(0.33, 0.34, 0.34)
	)
	_make_watchtower(
		"FortWatchtower",
		Vector3(36.0, 0.0, 27.0)
	)

	# Sloped approaches and elevated flank routes.
	_make_sloped_ground(
		"WestHillRamp",
		Vector3(-38.0, 1.0, 7.0),
		Vector3(12.0, 1.2, 18.0),
		Vector3(0.0, 0.0, -8.0),
		Color(0.17, 0.23, 0.15)
	)
	_make_sloped_ground(
		"EastHillRamp",
		Vector3(38.0, 1.0, -4.0),
		Vector3(12.0, 1.2, 18.0),
		Vector3(0.0, 0.0, 8.0),
		Color(0.17, 0.23, 0.15)
	)

	# Trees and visual breakup.
	for tree_position in [
		Vector3(-40.0, 0.0, -32.0),
		Vector3(-34.0, 0.0, -14.0),
		Vector3(-39.0, 0.0, 2.0),
		Vector3(-35.0, 0.0, 18.0),
		Vector3(-41.0, 0.0, 31.0),
		Vector3(39.0, 0.0, -31.0),
		Vector3(34.0, 0.0, -11.0),
		Vector3(40.0, 0.0, 5.0),
		Vector3(35.0, 0.0, 18.0),
		Vector3(43.0, 0.0, 34.0),
		Vector3(-15.0, 0.0, -33.0),
		Vector3(15.0, 0.0, 34.0)
	]:
		_make_tree(tree_position, randf_range(0.85, 1.30))

	# WWII urban expansion: cobbled village, apartments, courtyards.
	_make_cobblestone_square(
		"VillageCobble",
		Vector3(-31.0, 0.0, 2.0),
		20,
		24,
		1.15
	)
	_make_cobblestone_square(
		"FortCourtyard",
		Vector3(33.0, 0.0, 26.0),
		18,
		14,
		1.10
	)

	_make_wwii_apartment(
		"OldTownApartmentsA",
		Vector3(-42.0, 0.0, -18.0),
		12.0,
		8.0,
		3,
		true
	)
	_make_wwii_apartment(
		"OldTownApartmentsB",
		Vector3(-44.0, 0.0, 7.0),
		14.0,
		8.5,
		4,
		false
	)
	_make_wwii_apartment(
		"OldTownApartmentsC",
		Vector3(-39.0, 0.0, 31.0),
		11.0,
		7.5,
		3,
		true
	)
	_make_wwii_apartment(
		"RailOffice",
		Vector3(45.0, 0.0, -18.0),
		13.0,
		8.0,
		3,
		true
	)
	_make_wwii_apartment(
		"FortBarracks",
		Vector3(49.0, 0.0, 26.0),
		15.0,
		9.0,
		3,
		false
	)

	for wall_data in [
		[Vector3(-22.0, 0.0, -13.0), 9, 0.0],
		[Vector3(-18.0, 0.0, 17.0), 11, 0.2],
		[Vector3(18.0, 0.0, -10.0), 10, -0.1],
		[Vector3(24.0, 0.0, 11.0), 12, 0.0],
		[Vector3(35.0, 0.0, 18.0), 8, 1.57]
	]:
		_make_sandbag_wall(
			"Sandbags_%s" % str(wall_data[0]),
			Vector3(wall_data[0]),
			int(wall_data[1]),
			float(wall_data[2])
		)

	for lamp_position in [
		Vector3(-32.0, 0.0, -12.0),
		Vector3(-31.0, 0.0, 2.0),
		Vector3(-30.0, 0.0, 17.0),
		Vector3(23.0, 0.0, -20.0),
		Vector3(32.0, 0.0, 26.0),
		Vector3(42.0, 0.0, 26.0)
	]:
		_make_street_lamp(
			"Lamp_%s" % str(lamp_position),
			lamp_position
		)

	# Longer outskirts for larger battles.
	_make_static_box(
		"FarWestGround",
		Vector3(-54.0, -0.65, 0.0),
		Vector3(16.0, 1.3, 102.0),
		Color(0.19, 0.22, 0.17)
	)
	_make_static_box(
		"FarEastGround",
		Vector3(54.0, -0.65, 0.0),
		Vector3(16.0, 1.3, 102.0),
		Color(0.19, 0.22, 0.17)
	)

	# Outer boundaries.
	_make_static_box(
		"OuterBoundaryNorth",
		Vector3(0.0, 3.0, -52.0),
		Vector3(126.0, 6.0, 1.0),
		Color(0.24, 0.25, 0.26)
	)
	_make_static_box(
		"OuterBoundarySouth",
		Vector3(0.0, 3.0, 52.0),
		Vector3(126.0, 6.0, 1.0),
		Color(0.24, 0.25, 0.26)
	)
	_make_static_box(
		"OuterBoundaryWest",
		Vector3(-62.0, 3.0, 0.0),
		Vector3(1.0, 6.0, 104.0),
		Color(0.24, 0.25, 0.26)
	)
	_make_static_box(
		"OuterBoundaryEast",
		Vector3(62.0, 3.0, 0.0),
		Vector3(1.0, 6.0, 104.0),
		Color(0.24, 0.25, 0.26)
	)

func _create_field_emplacement(
	emplacement_id: int,
	preferred_team: int,
	position: Vector3,
	rotation_y: float
) -> void:
	var emplacement := Node3D.new()
	emplacement.name = "FieldEmplacement_%d" % emplacement_id
	emplacement.set_script(FieldEmplacementScript)
	add_child(emplacement)
	emplacement.call(
		"configure",
		emplacement_id,
		preferred_team,
		position,
		rotation_y
	)
	field_emplacements.append(emplacement)

func _create_destructible_cover(
	position: Vector3,
	rotation_y: float,
	size: Vector3,
	health: int = 260
) -> void:
	var cover_id: int = next_cover_id
	next_cover_id += 1

	var cover := StaticBody3D.new()
	cover.name = "DestructibleCover_%d" % cover_id
	cover.set_script(DestructibleCoverScript)
	add_child(cover)
	cover.call(
		"configure",
		cover_id,
		position,
		rotation_y,
		size,
		health
	)
	destructible_covers[cover_id] = cover

func _reset_destructible_cover() -> void:
	for cover_value in destructible_covers.values():
		if cover_value == null or not is_instance_valid(cover_value):
			continue
		var cover: Node = cover_value as Node
		if cover != null and cover.has_method("reset_cover"):
			cover.call("reset_cover")

func emplacement_status_text() -> String:
	if command_post_control < 0:
		return "AUTO-GUNS OFFLINE"
	return (
		"AUTO-GUNS: ATTACKERS"
		if command_post_control == 0
		else "AUTO-GUNS: DEFENDERS"
	)

func _supply_depot_node() -> Node3D:
	return get_node_or_null("SupplyDepot") as Node3D

func _update_supply_depot(delta: float) -> void:
	if not multiplayer.is_server() or match_over:
		return

	var depot: Node3D = _supply_depot_node()
	if depot == null:
		return

	var attackers := 0
	var defenders := 0

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if not bool(player.get("alive")) or bool(player.get("downed")):
			continue
		if player.global_position.distance_to(
			depot.global_position
		) > SUPPLY_DEPOT_RADIUS:
			continue

		if int(player.get("team")) == 0:
			attackers += 1
		else:
			defenders += 1

	supply_depot_contested = attackers > 0 and defenders > 0

	if attackers != defenders:
		var advantage: int = clampi(
			abs(attackers - defenders),
			1,
			3
		)
		var rate: float = (
			100.0 / SUPPLY_DEPOT_CAPTURE_SECONDS
		) * float(advantage)

		if attackers > defenders:
			supply_depot_progress = minf(
				100.0,
				supply_depot_progress + rate * delta
			)
		else:
			supply_depot_progress = maxf(
				-100.0,
				supply_depot_progress - rate * delta
			)

	var new_control := supply_depot_control
	if supply_depot_progress >= 100.0:
		new_control = 0
	elif supply_depot_progress <= -100.0:
		new_control = 1
	elif absf(supply_depot_progress) < 5.0:
		new_control = -1

	if new_control != supply_depot_control:
		supply_depot_control = new_control
		supply_depot_ticket_accumulator = 0.0

		if new_control == 0:
			attacker_tickets = mini(
				INITIAL_TEAM_TICKETS,
				attacker_tickets + 4
			)
			show_mission_event.rpc(
				"ATTACKERS SECURED THE SUPPLY DEPOT"
			)
		elif new_control == 1:
			defender_tickets = mini(
				INITIAL_TEAM_TICKETS,
				defender_tickets + 4
			)
			show_mission_event.rpc(
				"DEFENDERS SECURED THE SUPPLY DEPOT"
			)
		else:
			show_mission_event.rpc("SUPPLY DEPOT NEUTRALIZED")

	if supply_depot_control >= 0:
		supply_depot_ticket_accumulator += delta
		if (
			supply_depot_ticket_accumulator
			>= SUPPLY_DEPOT_TICKET_INTERVAL
		):
			supply_depot_ticket_accumulator = 0.0
			if supply_depot_control == 0:
				attacker_tickets = mini(
					INITIAL_TEAM_TICKETS,
					attacker_tickets + 1
				)
			else:
				defender_tickets = mini(
					INITIAL_TEAM_TICKETS,
					defender_tickets + 1
				)

func _update_supply_depot_visuals() -> void:
	if (
		supply_depot_marker == null
		or supply_depot_progress_label == null
		or supply_depot_light == null
	):
		return

	var state_text := "SUPPLY DEPOT NEUTRAL"
	var state_color := Color(0.72, 0.72, 0.72)

	if supply_depot_control == 0:
		state_text = "ATTACKER SUPPLY DEPOT"
		state_color = Color(0.20, 0.55, 1.0)
	elif supply_depot_control == 1:
		state_text = "DEFENDER SUPPLY DEPOT"
		state_color = Color(1.0, 0.24, 0.16)

	if supply_depot_contested:
		state_text = "SUPPLY DEPOT CONTESTED"
		state_color = Color(1.0, 0.72, 0.10)

	supply_depot_marker.text = state_text
	supply_depot_marker.modulate = state_color
	supply_depot_progress_label.text = (
		"Capture %+d%%" % int(round(supply_depot_progress))
	)
	supply_depot_progress_label.modulate = state_color.lightened(0.2)
	supply_depot_light.light_color = state_color
	supply_depot_light.light_energy = (
		2.7 if supply_depot_contested else 1.6
	)

@rpc("authority", "call_local", "reliable")
func show_mission_event(message: String) -> void:
	mission_banner_text = message
	mission_banner_until_ms = Time.get_ticks_msec() + 3500
	push_kill_feed.rpc(message)

@rpc("any_peer", "call_remote", "reliable")
func request_rally_point(
	requested_peer_id: int,
	position_hint: Vector3
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player == null:
		return
	if int(player.get("player_class")) != 3:
		return
	if not bool(player.get("alive")) or bool(player.get("downed")):
		return

	var team_id: int = int(player.get("team"))
	var deploy_position: Vector3 = (
		player.global_position
		+ (-player.global_transform.basis.z * 2.2)
	)
	deploy_position.y = 0.0

	if deploy_position.distance_to(position_hint) <= 4.0:
		deploy_position = position_hint
		deploy_position.y = 0.0

	server_remove_rally_point(team_id)

	var rally_id: int = next_rally_id
	next_rally_id += 1
	spawn_rally_point.rpc(
		rally_id,
		team_id,
		int(player.get("peer_id")),
		deploy_position,
		RALLY_POINT_DURATION
	)
	player.call("add_xp", 6, "rally deployed")
	show_mission_event.rpc(
		"%s DEPLOYED A TEAM RALLY"
		% str(player.get("player_name"))
	)

@rpc("authority", "call_local", "reliable")
func spawn_rally_point(
	rally_id: int,
	team_id: int,
	owner_id: int,
	position: Vector3,
	duration: float
) -> void:
	if rally_points.has(team_id):
		var old_value: Variant = rally_points.get(team_id)
		rally_points.erase(team_id)
		if old_value != null and is_instance_valid(old_value):
			var old_rally: Node = old_value as Node
			if old_rally != null:
				old_rally.queue_free()

	var rally := Node3D.new()
	rally.name = "RallyPoint_%d" % team_id
	rally.set_script(RallyPointScript)
	add_child(rally)
	rally.call(
		"configure",
		rally_id,
		team_id,
		owner_id,
		position,
		duration
	)
	rally_points[team_id] = rally

func server_remove_rally_point(team_id: int) -> void:
	if not multiplayer.is_server():
		return
	remove_rally_point.rpc(team_id)

@rpc("authority", "call_local", "reliable")
func remove_rally_point(team_id: int) -> void:
	if not rally_points.has(team_id):
		return

	var rally_value: Variant = rally_points.get(team_id)
	rally_points.erase(team_id)

	if rally_value == null or not is_instance_valid(rally_value):
		return

	var rally: Node = rally_value as Node
	if rally != null and not rally.is_queued_for_deletion():
		rally.queue_free()

func is_rally_contested(
	team_id: int,
	position: Vector3
) -> bool:
	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if not bool(player.get("alive")):
			continue
		if int(player.get("team")) == team_id:
			continue
		if player.global_position.distance_to(
			position
		) <= RALLY_POINT_CONTEST_RADIUS:
			return true
	return false

func _rally_spawn_position(
	team_id: int,
	peer_id: int
) -> Variant:
	if not rally_points.has(team_id):
		return null

	var rally_value: Variant = rally_points.get(team_id)
	if rally_value == null or not is_instance_valid(rally_value):
		rally_points.erase(team_id)
		return null

	var rally: Node3D = rally_value as Node3D
	if rally == null or bool(rally.get("contested")):
		return null

	var candidates: Array[Vector3] = [
		rally.global_position + Vector3(1.5, 1.0, 0.0),
		rally.global_position + Vector3(-1.5, 1.0, 0.0),
		rally.global_position + Vector3(0.0, 1.0, 1.5),
		rally.global_position + Vector3(0.0, 1.0, -1.5)
	]

	for candidate in candidates:
		var result: Dictionary = _validate_spawn_candidate(
			candidate,
			peer_id
		)
		if bool(result.get("valid", false)):
			return Vector3(result.get("position"))

	return null

func _artillery_danger_position() -> Variant:
	if pending_artillery.is_empty():
		return null

	var closest_remaining := 999.0
	var danger_position: Variant = null
	for strike in pending_artillery:
		var remaining: float = float(
			strike.get("remaining", 999.0)
		)
		if remaining < closest_remaining:
			closest_remaining = remaining
			danger_position = Vector3(
				strike.get("position", Vector3.ZERO)
			)
	return danger_position

func _update_sector_warfare(delta: float) -> void:
	if not multiplayer.is_server() or match_over:
		return

	for sector_name_value in sector_positions.keys():
		var sector_name: String = str(sector_name_value)
		var sector_position: Vector3 = Vector3(
			sector_positions.get(sector_name, Vector3.ZERO)
		)
		var attackers := 0
		var defenders := 0

		for player_value in players.values():
			var player: Node3D = player_value as Node3D
			if player == null:
				continue
			if not bool(player.get("alive")):
				continue
			if bool(player.get("downed")):
				continue
			if player.global_position.distance_to(
				sector_position
			) > SECTOR_CAPTURE_RADIUS:
				continue

			if int(player.get("team")) == 0:
				attackers += 1
			else:
				defenders += 1

		var contested: bool = attackers > 0 and defenders > 0
		sector_contested[sector_name] = contested

		var current_progress: float = float(
			sector_progress.get(sector_name, 0.0)
		)
		if attackers != defenders:
			var advantage: int = clampi(
				abs(attackers - defenders),
				1,
				3
			)
			var capture_rate: float = (
				100.0 / SECTOR_CAPTURE_SECONDS
			) * float(advantage)

			if attackers > defenders:
				current_progress = minf(
					100.0,
					current_progress + capture_rate * delta
				)
			else:
				current_progress = maxf(
					-100.0,
					current_progress - capture_rate * delta
				)

		sector_progress[sector_name] = current_progress
		var old_control: int = int(
			sector_control.get(sector_name, -1)
		)
		var new_control := old_control

		if current_progress >= 100.0:
			new_control = 0
		elif current_progress <= -100.0:
			new_control = 1
		elif absf(current_progress) <= 4.0:
			new_control = -1

		if new_control != old_control:
			sector_control[sector_name] = new_control
			if new_control == 0:
				show_mission_event.rpc(
					"ATTACKERS CAPTURED %s" % sector_name.to_upper()
				)
			elif new_control == 1:
				show_mission_event.rpc(
					"DEFENDERS CAPTURED %s" % sector_name.to_upper()
				)
			else:
				show_mission_event.rpc(
					"%s NEUTRALIZED" % sector_name.to_upper()
				)

	sector_ticket_accumulator += delta
	if sector_ticket_accumulator >= SECTOR_TICKET_INTERVAL:
		sector_ticket_accumulator = 0.0
		var attacker_sectors := 0
		var defender_sectors := 0
		for control_value in sector_control.values():
			var control: int = int(control_value)
			if control == 0:
				attacker_sectors += 1
			elif control == 1:
				defender_sectors += 1

		if attacker_sectors >= 2:
			attacker_tickets = mini(
				INITIAL_TEAM_TICKETS,
				attacker_tickets + 1
			)
		if defender_sectors >= 2:
			defender_tickets = mini(
				INITIAL_TEAM_TICKETS,
				defender_tickets + 1
			)

	sync_sector_state.rpc(
		sector_control,
		sector_progress,
		sector_contested
	)

@rpc("authority", "call_local", "unreliable")
func sync_sector_state(
	new_control: Dictionary,
	new_progress: Dictionary,
	new_contested: Dictionary
) -> void:
	sector_control = new_control.duplicate(true)
	sector_progress = new_progress.duplicate(true)
	sector_contested = new_contested.duplicate(true)

func _update_sector_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return

	for sector_name_value in sector_positions.keys():
		var sector_name: String = str(sector_name_value)
		var control: int = int(
			sector_control.get(sector_name, -1)
		)
		var contested: bool = bool(
			sector_contested.get(sector_name, false)
		)
		var progress: int = int(round(float(
			sector_progress.get(sector_name, 0.0)
		)))

		var marker: Label3D = (
			sector_markers.get(sector_name) as Label3D
		)
		var light: OmniLight3D = (
			sector_lights.get(sector_name) as OmniLight3D
		)
		var color := Color(0.72, 0.72, 0.72)
		var owner_text := "NEUTRAL"

		if control == 0:
			color = Color(0.20, 0.58, 1.0)
			owner_text = "ATTACKERS"
		elif control == 1:
			color = Color(1.0, 0.25, 0.16)
			owner_text = "DEFENDERS"

		if contested:
			color = Color(1.0, 0.76, 0.12)
			owner_text = "CONTESTED"

		if marker != null:
			marker.text = (
				"%s · %s · %+d%%"
				% [sector_name.to_upper(), owner_text, progress]
			)
			marker.modulate = color
		if light != null:
			light.light_color = color
			light.light_energy = (
				2.8 if contested else 1.6
			)

func sector_status_text() -> String:
	var parts: Array[String] = []
	for sector_name_value in [
		"Village",
		"Rail Yard",
		"Fort"
	]:
		var sector_name: String = str(sector_name_value)
		var control: int = int(
			sector_control.get(sector_name, -1)
		)
		var code := "N"
		if bool(sector_contested.get(sector_name, false)):
			code = "X"
		elif control == 0:
			code = "A"
		elif control == 1:
			code = "D"
		parts.append("%s:%s" % [
			sector_name.substr(0, 1),
			code
		])
	return " ".join(parts)

func tactical_map_text() -> String:
	var village := _sector_map_code("Village")
	var rail := _sector_map_code("Rail Yard")
	var fort := _sector_map_code("Fort")
	var objective_name := (
		"BRIDGE"
		if objective_stage == 0
		else "BUNKER"
	)

	return (
		"OPERATION BLACK RIVER\n"
		+ "════════════════════════════════════════════\n"
		+ "       NORTH ROAD / VILLAGE APPROACH\n"
		+ "  [VILLAGE %s]          [RAIL YARD %s]\n"
		+ "          \\              //\n"
		+ "           \\  BLACK RIVER //\n"
		+ "            [ACTIVE: %s]\n"
		+ "                 ||\n"
		+ "          [SUPPLY DEPOT]\n"
		+ "                 ||\n"
		+ "             [FORT %s]\n"
		+ "════════════════════════════════════════════\n"
		+ "A=Attackers  D=Defenders  N=Neutral  X=Contested"
	) % [village, rail, objective_name, fort]

func _sector_map_code(sector_name: String) -> String:
	if bool(sector_contested.get(sector_name, false)):
		return "X"
	var control: int = int(
		sector_control.get(sector_name, -1)
	)
	if control == 0:
		return "A"
	if control == 1:
		return "D"
	return "N"

func bot_route_waypoint(
	player: Node3D,
	route_index: int
) -> Vector3:
	var team_id: int = int(player.get("team"))
	var role: int = int(player.get("bot_squad_role"))
	var routes: Array[Array] = []

	if team_id == 0:
		routes = [
			[
				Vector3(-36.0, 1.0, -28.0),
				Vector3(-28.0, 1.0, -18.0),
				Vector3(-18.0, 1.0, -8.0),
				Vector3(-5.0, 1.0, 0.0),
				Vector3(18.0, 1.0, 16.0),
				Vector3(30.0, 1.0, 25.0)
			],
			[
				Vector3(-38.0, 1.0, 22.0),
				Vector3(-28.0, 1.0, 20.0),
				Vector3(-14.0, 1.0, 10.0),
				Vector3(0.0, 1.0, 5.0),
				Vector3(20.0, 1.0, -18.0),
				Vector3(30.0, 1.0, 25.0)
			],
			[
				Vector3(-25.0, 1.0, 0.0),
				Vector3(-10.0, 1.0, 0.0),
				Vector3(5.0, 1.0, 0.0),
				Vector3(18.0, 1.0, 8.0),
				Vector3(30.0, 1.0, 25.0)
			],
			[
				Vector3(-30.0, 1.0, 3.0),
				Vector3(-18.0, 1.0, 8.0),
				Vector3(-8.2, 1.0, 7.8),
				Vector3(8.0, 1.0, 8.0),
				Vector3(25.0, 1.0, 15.0)
			]
		]
	else:
		routes = [
			[
				Vector3(38.0, 1.0, 29.0),
				Vector3(30.0, 1.0, 25.0),
				Vector3(18.0, 1.0, 16.0),
				Vector3(5.0, 1.0, 2.0),
				Vector3(-18.0, 1.0, -8.0),
				Vector3(-30.0, 1.0, -18.0)
			],
			[
				Vector3(39.0, 1.0, -28.0),
				Vector3(25.0, 1.0, -20.0),
				Vector3(14.0, 1.0, -9.0),
				Vector3(0.0, 1.0, -4.0),
				Vector3(-20.0, 1.0, 9.0),
				Vector3(-30.0, 1.0, 20.0)
			],
			[
				Vector3(31.0, 1.0, 25.0),
				Vector3(20.0, 1.0, 14.0),
				Vector3(8.0, 1.0, 3.0),
				Vector3(-5.0, 1.0, 0.0),
				Vector3(-25.0, 1.0, 0.0)
			],
			[
				Vector3(30.0, 1.0, 25.0),
				Vector3(20.0, 1.0, 10.0),
				Vector3(8.0, 1.0, 8.0),
				Vector3(-8.2, 1.0, 7.8),
				Vector3(-26.0, 1.0, 4.0)
			]
		]

	var selected_route: Array = routes[
		clampi(role, 0, routes.size() - 1)
	]
	return Vector3(selected_route[
		posmod(route_index, selected_route.size())
	])

func sector_forward_spawn(
	team_id: int
) -> Variant:
	var priority: Array[String] = (
		["Fort", "Rail Yard", "Village"]
		if team_id == 0
		else ["Village", "Rail Yard", "Fort"]
	)
	for sector_name in priority:
		if int(sector_control.get(sector_name, -1)) != team_id:
			continue
		var center: Vector3 = Vector3(
			sector_positions.get(sector_name, Vector3.ZERO)
		)
		return center + Vector3(
			-3.0 if team_id == 0 else 3.0,
			1.0,
			0.0
		)
	return null

func _command_post_node() -> Node3D:
	return get_node_or_null("CommandPost") as Node3D

func _update_command_post_capture(delta: float) -> void:
	if not multiplayer.is_server() or match_over:
		return
	if objective_stage == 0:
		command_post_contested = false
		return

	var command_post: Node3D = _command_post_node()
	if command_post == null:
		return

	var attackers := 0
	var defenders := 0
	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if not bool(player.get("alive")) or bool(player.get("downed")):
			continue
		if player.global_position.distance_to(
			command_post.global_position
		) > COMMAND_POST_RADIUS:
			continue

		if int(player.get("team")) == 0:
			attackers += 1
		else:
			defenders += 1

	command_post_contested = attackers > 0 and defenders > 0
	if attackers == defenders:
		return

	var advantage: int = clampi(abs(attackers - defenders), 1, 3)
	var capture_rate: float = (
		100.0 / COMMAND_POST_CAPTURE_SECONDS
	) * float(advantage)

	if attackers > defenders:
		command_post_progress = minf(
			100.0,
			command_post_progress + capture_rate * delta
		)
	else:
		command_post_progress = maxf(
			-100.0,
			command_post_progress - capture_rate * delta
		)

	var new_control := command_post_control
	if command_post_progress >= 100.0:
		new_control = 0
	elif command_post_progress <= -100.0:
		new_control = 1
	elif absf(command_post_progress) < 8.0:
		new_control = -1

	if new_control != command_post_control:
		command_post_control = new_control
		if command_post_control == 0:
			attacker_tickets = mini(
				INITIAL_TEAM_TICKETS,
				attacker_tickets + 5
			)
			push_kill_feed.rpc(
				"ATTACKERS captured the command post — forward spawn active"
			)
		elif command_post_control == 1:
			defender_tickets = mini(
				INITIAL_TEAM_TICKETS,
				defender_tickets + 5
			)
			push_kill_feed.rpc(
				"DEFENDERS captured the command post — forward spawn active"
			)
		else:
			push_kill_feed.rpc("Command post neutralized")

func _should_overtime_continue() -> bool:
	if dynamite_armed or command_post_contested:
		return true

	var target: Node3D = (
		get_node_or_null("BridgeBuildSite") as Node3D
		if objective_stage == 0
		else get_node_or_null("Objective") as Node3D
	)
	if target == null:
		return false

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if int(player.get("team")) != 0:
			continue
		if not bool(player.get("alive")) or bool(player.get("downed")):
			continue
		if player.global_position.distance_to(target.global_position) <= 5.0:
			return true

	return false

func _living_team_count(team_id: int) -> int:
	var count := 0
	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if int(player.get("team")) != team_id:
			continue
		if bool(player.get("alive")):
			count += 1
	return count

func _check_ticket_victory() -> void:
	if match_over:
		return
	if attacker_tickets <= 0 and _living_team_count(0) <= 0:
		_end_match("DEFENDERS WIN — attackers exhausted")
	elif defender_tickets <= 0 and _living_team_count(1) <= 0:
		_end_match("ATTACKERS WIN — defenders exhausted")

func _ticket_value(team_id: int) -> int:
	return attacker_tickets if team_id == 0 else defender_tickets

func _consume_ticket(team_id: int) -> void:
	if team_id == 0:
		attacker_tickets = maxi(0, attacker_tickets - 1)
	else:
		defender_tickets = maxi(0, defender_tickets - 1)

func _update_battlefield_atmosphere() -> void:
	if battlefield_environment == null or battlefield_sun == null:
		return

	var match_fraction: float = clampf(
		1.0 - (
			match_time_remaining / MATCH_LENGTH_SECONDS
		),
		0.0,
		1.0
	)
	var pulse: float = sin(atmosphere_elapsed * 0.08) * 0.02
	var daylight := Color(0.12, 0.16, 0.19)
	var dusk := Color(0.24, 0.10, 0.08)
	battlefield_environment.background_color = daylight.lerp(
		dusk,
		match_fraction * 0.62
	) + Color(pulse, pulse, pulse)
	battlefield_environment.ambient_light_energy = lerpf(
		0.78,
		0.50,
		match_fraction
	)
	battlefield_sun.rotation_degrees.x = lerpf(
		-55.0,
		-18.0,
		match_fraction
	)
	battlefield_sun.light_energy = lerpf(
		1.0,
		0.62,
		match_fraction
	)

func _parse_command_line() -> void:
	var args := OS.get_cmdline_user_args()
	var is_server := "--server" in args or DisplayServer.get_name() == "headless"
	var port := PORT_DEFAULT
	var connect_address := ""
	var bots_argument_seen := false

	for i in args.size():
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
		elif args[i] == "--connect" and i + 1 < args.size():
			connect_address = args[i + 1]
		elif args[i] == "--bots" and i + 1 < args.size():
			desired_bot_count = clampi(int(args[i + 1]), 0, 16)
			bots_argument_seen = true
		elif args[i] == "--bot-skill" and i + 1 < args.size():
			bot_skill = clampf(float(args[i + 1]), 0.5, 2.0)

	if is_server:
		if DisplayServer.get_name() != "headless" and not bots_argument_seen:
			desired_bot_count = 0
		start_server(port)
	elif connect_address != "":
		join_server(connect_address, port)
	else:
		_show_connection_menu()

func start_server(port: int = PORT_DEFAULT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_CLIENTS)
	if err != OK:
		push_error("Unable to start server: %s" % error_string(err))
		get_tree().quit(1)
		return
	multiplayer.multiplayer_peer = peer
	if progression_store != null:
		progression_store.load_database()
	print(
		"Frontline Objective v%s protocol %d listening on UDP %d" % [
			BUILD_VERSION,
			NETWORK_PROTOCOL,
			port
		]
	)
	print("Requested bot count: %d" % desired_bot_count)
	print("Bot skill multiplier: %.2f" % bot_skill)

	for index in range(desired_bot_count):
		_spawn_bot(index)

	print(
		"Server roster ready: %d total actors, %d bots" % [
			players.size(),
			desired_bot_count
		]
	)

func join_server(address: String, port: int = PORT_DEFAULT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		push_error("Unable to connect: %s" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	if status_label: status_label.text = "Connecting to %s:%d..." % [address, port]

func get_local_profile_settings() -> Dictionary:
	return local_profile.duplicate(true)

func _linear_to_db(value: float) -> float:
	if value <= 0.001:
		return -80.0
	return linear_to_db(value)

func _set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(
		bus_index,
		_linear_to_db(value)
	)

func _apply_profile_audio_settings() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_set_bus_volume(
		"Master",
		float(local_profile.get("master_volume", 0.85))
	)
	_set_bus_volume(
		"SFX",
		float(local_profile.get("effects_volume", 0.90))
	)
	_set_bus_volume(
		"Music",
		float(local_profile.get("music_volume", 0.65))
	)

func _apply_profile_to_local_player() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	var local_id: int = multiplayer.get_unique_id()
	if not players.has(local_id):
		return
	var player: Node = players[local_id] as Node
	if (
		player != null
		and player.has_method("apply_local_profile_settings")
	):
		player.call(
			"apply_local_profile_settings",
			local_profile
		)

func _profile_slider_row(
	parent: VBoxContainer,
	label_text: String,
	minimum: float,
	maximum: float,
	step: float,
	initial: float
) -> HSlider:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(180, 28)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = initial
	slider.custom_minimum_size = Vector2(270, 28)
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(70, 28)
	value_label.text = "%.2f" % initial
	slider.value_changed.connect(
		func(value: float) -> void:
			value_label.text = "%.2f" % value
	)
	row.add_child(value_label)
	return slider

func _build_profile_panel() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if profile_panel != null:
		return

	profile_canvas = CanvasLayer.new()
	profile_canvas.name = "ProfileSettingsCanvas"
	profile_canvas.layer = 125
	add_child(profile_canvas)

	profile_panel = PanelContainer.new()
	profile_panel.name = "ProfileSettingsPanel"
	profile_panel.position = Vector2(120, 55)
	profile_panel.custom_minimum_size = Vector2(590, 610)
	profile_panel.visible = false
	profile_canvas.add_child(profile_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	profile_panel.add_child(box)

	var title := Label.new()
	title.text = "PLAYER PROFILE & SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	box.add_child(title)

	var description := Label.new()
	description.text = (
		"Saved locally and used automatically on every compatible server."
	)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(description)

	var name_label := Label.new()
	name_label.text = "PLAYER NAME"
	box.add_child(name_label)

	profile_name_input = LineEdit.new()
	profile_name_input.max_length = 20
	profile_name_input.text = str(
		local_profile.get("player_name", "Soldier")
	)
	box.add_child(profile_name_input)

	var team_row := HBoxContainer.new()
	box.add_child(team_row)
	var team_label := Label.new()
	team_label.text = "PREFERRED TEAM"
	team_label.custom_minimum_size = Vector2(180, 32)
	team_row.add_child(team_label)
	profile_team_option = OptionButton.new()
	profile_team_option.add_item("Attackers", 0)
	profile_team_option.add_item("Defenders", 1)
	profile_team_option.selected = int(
		local_profile.get("preferred_team", 0)
	)
	team_row.add_child(profile_team_option)

	var class_row := HBoxContainer.new()
	box.add_child(class_row)
	var class_label := Label.new()
	class_label.text = "PREFERRED CLASS"
	class_label.custom_minimum_size = Vector2(180, 32)
	class_row.add_child(class_label)
	profile_class_option = OptionButton.new()
	var profile_class_names: Array[String] = [
		"Soldier",
		"Medic",
		"Engineer",
		"Field Ops",
		"Scout"
	]
	for profile_class_name in profile_class_names:
		profile_class_option.add_item(profile_class_name)
	profile_class_option.selected = int(
		local_profile.get("preferred_class", 0)
	)
	class_row.add_child(profile_class_option)

	var controls_title := Label.new()
	controls_title.text = "KEYBINDINGS"
	controls_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(controls_title)

	profile_binding_buttons.clear()
	var active_bindings: Dictionary = (
		InputBindingManagerScript.sanitize_bindings(
			local_profile.get("keybindings", {})
		)
	)
	for binding_action in (
		InputBindingManagerScript.SUPPORTED_ACTIONS.keys()
	):
		var binding_row := HBoxContainer.new()
		box.add_child(binding_row)
		var binding_label := Label.new()
		binding_label.text = (
			InputBindingManagerScript.action_label(
				str(binding_action)
			)
		)
		binding_label.custom_minimum_size = Vector2(250, 28)
		binding_row.add_child(binding_label)

		var binding_button := Button.new()
		binding_button.custom_minimum_size = Vector2(190, 28)
		binding_button.text = InputBindingManagerScript.key_name(
			int(active_bindings[binding_action])
		)
		var action_to_capture := str(binding_action)
		binding_button.pressed.connect(
			func() -> void:
				_begin_binding_capture(action_to_capture)
		)
		binding_row.add_child(binding_button)
		profile_binding_buttons[action_to_capture] = binding_button

	profile_sensitivity_slider = _profile_slider_row(
		box,
		"Mouse sensitivity",
		0.0005,
		0.0100,
		0.0001,
		float(local_profile.get("mouse_sensitivity", 0.0025))
	)
	profile_fov_slider = _profile_slider_row(
		box,
		"Field of view",
		60.0,
		110.0,
		1.0,
		float(local_profile.get("field_of_view", 75.0))
	)
	profile_hud_scale_slider = _profile_slider_row(
		box,
		"HUD scale",
		0.70,
		1.40,
		0.05,
		float(local_profile.get("hud_scale", 1.0))
	)
	profile_master_slider = _profile_slider_row(
		box,
		"Master volume",
		0.0,
		1.0,
		0.05,
		float(local_profile.get("master_volume", 0.85))
	)
	profile_effects_slider = _profile_slider_row(
		box,
		"Effects volume",
		0.0,
		1.0,
		0.05,
		float(local_profile.get("effects_volume", 0.90))
	)
	profile_music_slider = _profile_slider_row(
		box,
		"Music volume",
		0.0,
		1.0,
		0.05,
		float(local_profile.get("music_volume", 0.65))
	)

	profile_transfer_path = LineEdit.new()
	profile_transfer_path.text = "user://frontline_profile_export.cfg"
	profile_transfer_path.placeholder_text = "Profile backup path"
	box.add_child(profile_transfer_path)

	var transfer_row := HBoxContainer.new()
	box.add_child(transfer_row)
	var export_button := Button.new()
	export_button.text = "EXPORT PROFILE"
	export_button.pressed.connect(_export_profile)
	transfer_row.add_child(export_button)
	var import_button := Button.new()
	import_button.text = "IMPORT PROFILE"
	import_button.pressed.connect(_import_profile)
	transfer_row.add_child(import_button)

	var button_row := HBoxContainer.new()
	box.add_child(button_row)

	var save_button := Button.new()
	save_button.text = "SAVE & APPLY"
	save_button.custom_minimum_size = Vector2(270, 45)
	save_button.pressed.connect(_save_profile_from_panel)
	button_row.add_child(save_button)

	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.custom_minimum_size = Vector2(270, 45)
	close_button.pressed.connect(
		func() -> void:
			_set_profile_panel_visible(false)
	)
	button_row.add_child(close_button)

	profile_status_label = Label.new()
	profile_status_label.text = "F8 opens this panel during play."
	profile_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(profile_status_label)

func _begin_binding_capture(action_id: String) -> void:
	profile_waiting_for_action = action_id
	if profile_status_label != null:
		profile_status_label.text = (
			"Press a key for %s · Escape cancels"
			% InputBindingManagerScript.action_label(action_id)
		)

func _capture_binding_key(key_code: int) -> void:
	if profile_waiting_for_action.is_empty():
		return
	var bindings: Dictionary = (
		InputBindingManagerScript.sanitize_bindings(
			local_profile.get("keybindings", {})
		)
	)
	bindings[profile_waiting_for_action] = key_code
	local_profile["keybindings"] = bindings
	if profile_binding_buttons.has(profile_waiting_for_action):
		var binding_button: Button = (
			profile_binding_buttons[profile_waiting_for_action]
			as Button
		)
		if binding_button != null:
			binding_button.text = (
				InputBindingManagerScript.key_name(key_code)
			)
	profile_waiting_for_action = ""
	InputBindingManagerScript.apply_bindings(bindings)
	if profile_status_label != null:
		profile_status_label.text = "Keybinding updated."

func _export_profile() -> void:
	var path := profile_transfer_path.text.strip_edges()
	var error: Error = profile_manager.export_profile(path)
	if profile_status_label != null:
		profile_status_label.text = (
			"Profile exported to %s" % path
			if error == OK
			else "Export failed: %d" % error
		)

func _import_profile() -> void:
	var path := profile_transfer_path.text.strip_edges()
	var error: Error = profile_manager.import_profile(path)
	if error != OK:
		if profile_status_label != null:
			profile_status_label.text = "Import failed: %d" % error
		return
	local_profile = profile_manager.load_profile()
	InputBindingManagerScript.apply_bindings(
		Dictionary(local_profile.get("keybindings", {}))
	)
	_apply_profile_audio_settings()
	_apply_profile_to_local_player()
	if profile_status_label != null:
		profile_status_label.text = (
			"Profile imported. Reopen settings to refresh fields."
		)

func _save_profile_from_panel() -> void:
	if profile_manager == null:
		return

	local_profile = profile_manager.update({
		"player_name": profile_name_input.text,
		"preferred_team": profile_team_option.selected,
		"preferred_class": profile_class_option.selected,
		"mouse_sensitivity": profile_sensitivity_slider.value,
		"field_of_view": profile_fov_slider.value,
		"hud_scale": profile_hud_scale_slider.value,
		"master_volume": profile_master_slider.value,
		"effects_volume": profile_effects_slider.value,
		"music_volume": profile_music_slider.value,
		"keybindings": InputBindingManagerScript.sanitize_bindings(
			local_profile.get("keybindings", {})
		),
		"last_server": (
			connection_address.text
			if connection_address != null
			else local_profile.get("last_server", "127.0.0.1")
		),
		"last_port": (
			int(connection_port.value)
			if connection_port != null
			else int(local_profile.get("last_port", PORT_DEFAULT))
		)
	})

	InputBindingManagerScript.apply_bindings(
		Dictionary(local_profile.get("keybindings", {}))
	)
	_apply_profile_audio_settings()
	_apply_profile_to_local_player()
	if connection_address != null and connection_port != null:
		local_profile = profile_manager.set_server_preference(
			connection_address.text.strip_edges(),
			int(connection_port.value),
			profile_team_option.selected,
			profile_class_option.selected
		)

	if connection_player_name != null:
		connection_player_name.text = str(
			local_profile.get("player_name", "Soldier")
		)

	if multiplayer.multiplayer_peer != null:
		request_player_profile.rpc_id(
			1,
			str(local_profile.get("player_name", "Soldier")),
			str(local_profile.get("player_id", ""))
		)

	if profile_status_label != null:
		profile_status_label.text = (
			"Saved to user://frontline_profile.cfg"
		)

func _set_profile_panel_visible(visible_value: bool) -> void:
	if profile_panel == null:
		_build_profile_panel()
	if profile_panel == null:
		return
	profile_panel_visible = visible_value
	profile_panel.visible = visible_value
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
		if visible_value
		else Input.MOUSE_MODE_CAPTURED
	)

func _build_progression_panel() -> void:
	if DisplayServer.get_name() == "headless" or progression_panel != null:
		return
	progression_canvas = CanvasLayer.new()
	progression_canvas.layer = 124
	add_child(progression_canvas)
	progression_panel = PanelContainer.new()
	progression_panel.position = Vector2(110,70)
	progression_panel.custom_minimum_size = Vector2(660,540)
	progression_panel.visible = false
	progression_canvas.add_child(progression_panel)
	var box := VBoxContainer.new()
	progression_panel.add_child(box)
	var title := Label.new()
	title.text = "CAREER & MATCH HISTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",25)
	box.add_child(title)
	progression_label = Label.new()
	progression_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	progression_label.add_theme_font_size_override("font_size",15)
	box.add_child(progression_label)
	var close_button := Button.new()
	close_button.text = "CLOSE · F7"
	close_button.pressed.connect(
		func() -> void:
			_set_progression_visible(false)
	)
	box.add_child(close_button)
	_update_progression_panel()

func _history_text() -> String:
	var history: Array = Array(local_profile.get("match_history",[]))
	if history.is_empty():
		return "No completed matches stored on this client."
	var lines: Array[String] = []
	var number := 1
	for raw_entry in history:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = Dictionary(raw_entry)
		lines.append(
			"%d. %s · %dK/%dD/%dA · OBJ %d · %d XP"
			% [
				number,
				"WIN" if bool(entry.get("won",false)) else "LOSS",
				int(entry.get("kills",0)),
				int(entry.get("deaths",0)),
				int(entry.get("assists",0)),
				int(entry.get("objective",0)),
				int(entry.get("xp",0))
			]
		)
		number += 1
		if number > 8:
			break
	return "\n".join(lines)

func _update_progression_panel() -> void:
	if progression_label == null:
		return
	var career := (
		ServerProgressionStoreScript.summary(local_progression)
		if not local_progression.is_empty()
		else "No server career record received yet."
	)
	progression_label.text = (
		"CURRENT SERVER CAREER\n" + career
		+ "\n\nRECENT MATCHES\n" + _history_text()
	)

func _set_progression_visible(value: bool) -> void:
	_build_progression_panel()
	if progression_panel == null:
		return
	progression_visible = value
	progression_panel.visible = value
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
		if value else Input.MOUSE_MODE_CAPTURED
	)
	_update_progression_panel()

func _refresh_connection_server_list() -> void:
	if connection_server_list == null:
		return
	connection_server_list.clear()
	connection_server_list.add_item("Recent & Favorite Servers")
	connection_server_list.set_item_metadata(0, {})

	var seen := {}
	for source_group in [
		Array(local_profile.get("favorite_servers", [])),
		Array(local_profile.get("recent_servers", []))
	]:
		for raw_entry in source_group:
			if not raw_entry is Dictionary:
				continue
			var entry: Dictionary = Dictionary(raw_entry)
			var key := "%s:%d" % [
				str(entry.get("address", "")),
				int(entry.get("port", PORT_DEFAULT))
			]
			if seen.has(key):
				continue
			seen[key] = true
			connection_server_list.add_item(
				str(entry.get("label", key))
			)
			var item_index := connection_server_list.item_count - 1
			connection_server_list.set_item_metadata(
				item_index,
				entry
			)

func _on_connection_server_selected(index: int) -> void:
	if connection_server_list == null or index <= 0:
		return
	var metadata: Variant = (
		connection_server_list.get_item_metadata(index)
	)
	if not metadata is Dictionary:
		return
	var entry: Dictionary = Dictionary(metadata)
	connection_address.text = str(entry.get("address", ""))
	connection_port.value = int(
		entry.get("port", PORT_DEFAULT)
	)

func _add_current_server_to_favorites() -> void:
	if profile_manager == null:
		return
	local_profile = profile_manager.remember_server(
		connection_address.text.strip_edges(),
		int(connection_port.value),
		true
	)
	_refresh_connection_server_list()
	if status_label != null:
		status_label.text = "Server saved to favorites."

func _show_connection_menu() -> void:
	_build_profile_panel()
	_build_progression_panel()
	if connection_panel != null and is_instance_valid(connection_panel):
		connection_panel.visible = true
		if status_label != null:
			status_label.text = "Enter server address and connect."
		return

	var canvas := CanvasLayer.new()
	canvas.name = "ConnectionCanvas"
	add_child(canvas)

	connection_panel = PanelContainer.new()
	connection_panel.name = "ConnectionPanel"
	connection_panel.position = Vector2(70, 30)
	connection_panel.custom_minimum_size = Vector2(460, 250)
	canvas.add_child(connection_panel)

	var box := VBoxContainer.new()
	connection_panel.add_child(box)

	var title := Label.new()
	title.text = "FRONTLINE: OBJECTIVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	connection_server_list = OptionButton.new()
	connection_server_list.add_item("Recent & Favorite Servers")
	connection_server_list.item_selected.connect(
		_on_connection_server_selected
	)
	box.add_child(connection_server_list)
	_refresh_connection_server_list()

	connection_player_name = LineEdit.new()
	connection_player_name.placeholder_text = "Player name"
	connection_player_name.max_length = 20
	connection_player_name.text = str(
		local_profile.get("player_name", "Soldier")
	)
	box.add_child(connection_player_name)

	connection_address = LineEdit.new()
	connection_address.placeholder_text = "Server IP"
	connection_address.text = str(
		local_profile.get("last_server", "127.0.0.1")
	)
	box.add_child(connection_address)

	connection_port = SpinBox.new()
	connection_port.min_value = 1
	connection_port.max_value = 65535
	connection_port.value = int(
		local_profile.get("last_port", PORT_DEFAULT)
	)
	box.add_child(connection_port)

	connection_join_button = Button.new()
	connection_join_button.text = "Join Server"
	connection_join_button.pressed.connect(
		func() -> void:
			if connection_join_button != null:
				connection_join_button.disabled = true
			if status_label != null:
				status_label.text = "Connecting…"

			local_profile = profile_manager.update({
				"player_name": connection_player_name.text,
				"last_server": connection_address.text.strip_edges(),
				"last_port": int(connection_port.value)
			})
			local_profile = profile_manager.remember_server(
				connection_address.text.strip_edges(),
				int(connection_port.value),
				false
			)
			join_server(
				connection_address.text.strip_edges(),
				int(connection_port.value)
			)
	)
	box.add_child(connection_join_button)

	connection_favorite_button = Button.new()
	connection_favorite_button.text = "Add Current Server to Favorites"
	connection_favorite_button.pressed.connect(
		_add_current_server_to_favorites
	)
	box.add_child(connection_favorite_button)

	var settings_button := Button.new()
	settings_button.text = "Player Profile & Settings"
	settings_button.pressed.connect(
		func() -> void:
			_set_profile_panel_visible(true)
	)
	box.add_child(settings_button)

	status_label = Label.new()
	status_label.text = "WASD · Mouse · E interact · Q ability · Tab scoreboard"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status_label)

func _on_connected_to_server() -> void:
	print("Connected as peer %d" % multiplayer.get_unique_id())
	if status_label != null:
		status_label.text = "Connected. Verifying protocol…"
	if connection_panel != null:
		connection_panel.visible = false
	if connection_join_button != null:
		connection_join_button.disabled = false

func _on_connection_failed() -> void:
	push_error("Connection failed")

	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	if connection_panel != null:
		connection_panel.visible = true
	if connection_join_button != null:
		connection_join_button.disabled = false
	if status_label != null:
		status_label.text = (
			"Connection failed. Check the VPS IP, port 27960, " +
			"firewall, and server process."
	)

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return

	verified_peers[id] = false
	receive_server_protocol.rpc_id(
		id,
		NETWORK_PROTOCOL,
		BUILD_VERSION
	)

	var team := next_team
	next_team = 1 - next_team
	player_teams[id] = team; player_names[id] = "Player%d" % id
	for existing_id_value in players:
		var existing_id: int = int(existing_id_value)
		var existing: Node3D = players[existing_id] as Node3D
		if existing == null:
			continue
		spawn_player.rpc_id(
			id,
			existing_id,
			int(existing.get("team")),
			str(existing.get("player_name")),
			existing.global_position
		)

	for pack_value in supply_packs.values():
		var pack: Node3D = pack_value as Node3D
		if pack == null:
			continue
		spawn_supply_pack.rpc_id(
			id,
			int(pack.get("pack_id")),
			int(pack.get("team")),
			int(pack.get("pack_type")),
			int(pack.get("amount")),
			pack.global_position
		)

	for grenade_value in grenades.values():
		var grenade: Node3D = grenade_value as Node3D
		if grenade == null:
			continue
		spawn_grenade.rpc_id(
			id,
			int(grenade.get("grenade_id")),
			int(grenade.get("owner_id")),
			int(grenade.get("owner_team")),
			grenade.global_position,
			Vector3(grenade.get("velocity")),
			float(grenade.get("fuse_remaining"))
		)
	spawn_player.rpc(id, team, player_names[id], _get_spawn(team, id))

func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server(): return
	remove_player.rpc(id)
	player_teams.erase(id)
	player_names.erase(id)
	verified_peers.erase(id)

@rpc("authority", "call_remote", "reliable")
func receive_server_protocol(
	server_protocol: int,
	server_version: String
) -> void:
	if multiplayer.is_server():
		return

	if server_protocol != NETWORK_PROTOCOL:
		protocol_verified = false
		protocol_message = (
			"VERSION MISMATCH: client v%s protocol %d, server v%s protocol %d"
			% [
				BUILD_VERSION,
				NETWORK_PROTOCOL,
				server_version,
				server_protocol
			]
		)
		push_error(protocol_message)
		if status_label != null:
			status_label.text = protocol_message
		return

	protocol_verified = true
	protocol_message = "Connected: v%s protocol %d" % [
		server_version,
		server_protocol
	]
	print(protocol_message)
	client_protocol_ack.rpc_id(
		1,
		NETWORK_PROTOCOL,
		BUILD_VERSION
	)
	request_player_profile.rpc_id(
		1,
		str(local_profile.get("player_name", "Soldier")),
		str(local_profile.get("player_id", ""))
	)
	_apply_profile_to_local_player()

@rpc("any_peer", "call_remote", "reliable")
func client_protocol_ack(
	client_protocol: int,
	client_version: String
) -> void:
	if not multiplayer.is_server():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	if client_protocol != NETWORK_PROTOCOL:
		print(
			"Disconnecting peer %d: client v%s protocol %d, server v%s protocol %d"
			% [
				sender_id,
				client_version,
				client_protocol,
				BUILD_VERSION,
				NETWORK_PROTOCOL
			]
		)
		multiplayer.multiplayer_peer.disconnect_peer(sender_id)
		return

	verified_peers[sender_id] = true
	print(
		"Peer %d verified: client v%s protocol %d"
		% [sender_id, client_version, client_protocol]
	)

func is_peer_protocol_verified(peer_id: int) -> bool:
	if peer_id >= BOT_PEER_ID_START:
		return true
	return bool(verified_peers.get(peer_id, false))

func _player_from_remote_sender() -> Node3D:
	if not multiplayer.is_server():
		return null

	var sender_id: int = multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		return null
	if not players.has(sender_id):
		print(
			"Rejected gameplay RPC: sender %d has no player node"
			% sender_id
		)
		return null

	return players[sender_id] as Node3D

@rpc("any_peer", "call_remote", "unreliable_ordered", 2)
func submit_player_input(
	requested_peer_id: int,
	move: Vector2,
	yaw: float,
	look_pitch: float,
	wants_jump: bool,
	wants_sprint: bool,
	wants_crouch: bool,
	wants_aim: bool,
	sequence: int
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player == null:
		return
	player.call(
		"server_receive_input",
		move,
		yaw,
		look_pitch,
		wants_jump,
		wants_sprint,
		wants_crouch,
		wants_aim,
		sequence
	)
	var sender_id: int = multiplayer.get_remote_sender_id()
	receive_input_ack.rpc_id(sender_id, sequence)

@rpc("any_peer", "call_remote", "reliable")
func request_squad_ping(
	requested_peer_id: int,
	direction: Vector3
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player == null:
		return

	var head: Node3D = player.get_node_or_null("Head") as Node3D
	if head == null:
		return

	var normalized_direction: Vector3 = direction.normalized()
	var start_position: Vector3 = head.global_position
	var end_position: Vector3 = (
		start_position + normalized_direction * 45.0
	)

	var viewport: Viewport = get_viewport()
	if viewport != null and viewport.world_3d != null:
		var query := PhysicsRayQueryParameters3D.create(
			start_position,
			end_position
		)
		query.exclude = [player]
		var hit: Dictionary = (
			viewport.world_3d.direct_space_state.intersect_ray(
				query
			)
		)
		if not hit.is_empty():
			end_position = Vector3(
				hit.get("position", end_position)
			)

	show_squad_ping.rpc(
		int(player.get("team")),
		end_position,
		str(player.get("player_name"))
	)

@rpc("authority", "call_local", "reliable")
func show_squad_ping(
	ping_team: int,
	ping_position: Vector3,
	sender_name: String
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var local_id: int = multiplayer.get_unique_id()
	if players.has(local_id):
		var local_player: Node = players[local_id] as Node
		if local_player != null:
			if int(local_player.get("team")) != ping_team:
				return

	var marker := Label3D.new()
	marker.name = "SquadPing"
	marker.text = "▲  %s" % sender_name
	marker.position = ping_position + Vector3.UP * 0.45
	marker.font_size = 30
	marker.outline_size = 10
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.fixed_size = false
	marker.modulate = Color(0.22, 0.88, 1.0)
	add_child(marker)

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 5.0
	timer.timeout.connect(marker.queue_free)
	marker.add_child(timer)
	timer.start()

	push_kill_feed.rpc("%s marked a squad target" % sender_name)

func server_call_artillery(caller: Node3D, target_position: Vector3) -> void:
	if not multiplayer.is_server() or caller == null:
		return
	target_position.y = 0.15
	pending_artillery.append({
		"team": int(caller.get("team")),
		"owner_id": int(caller.get("peer_id")),
		"position": target_position,
		"remaining": ARTILLERY_WARNING_SECONDS
	})
	show_artillery_warning.rpc(target_position, ARTILLERY_WARNING_SECONDS)
	push_kill_feed.rpc("%s called artillery" % str(caller.get("player_name")))

func _update_pending_artillery(delta: float) -> void:
	if not multiplayer.is_server():
		return
	var completed: Array[int] = []
	for index in pending_artillery.size():
		var strike: Dictionary = pending_artillery[index]
		strike["remaining"] = float(strike.get("remaining", 0.0)) - delta
		pending_artillery[index] = strike
		if float(strike["remaining"]) <= 0.0:
			_execute_artillery_strike(strike)
			completed.append(index)
	completed.reverse()
	for index in completed:
		pending_artillery.remove_at(index)

func _execute_artillery_strike(strike: Dictionary) -> void:
	var position: Vector3 = Vector3(strike.get("position", Vector3.ZERO))
	var strike_team: int = int(strike.get("team", -1))
	var owner_id: int = int(strike.get("owner_id", 0))
	for player_value in players.values():
		var target: Node3D = player_value as Node3D
		if target == null or not bool(target.get("alive")):
			continue
		if int(target.get("team")) == strike_team:
			continue
		var distance: float = target.global_position.distance_to(position)
		if distance > ARTILLERY_RADIUS:
			continue
		var falloff: float = 1.0 - clampf(distance / ARTILLERY_RADIUS, 0.0, 1.0)
		var damage: int = maxi(18, int(round(ARTILLERY_DAMAGE * falloff)))
		target.call("server_take_damage", damage, owner_id)
	for constructible_value in constructibles.values():
		var constructible: Node = constructible_value as Node
		var constructible_3d: Node3D = constructible as Node3D
		if constructible == null or constructible_3d == null:
			continue
		if not constructible.has_method("server_take_damage"):
			continue
		if constructible_3d.global_position.distance_to(position) <= ARTILLERY_RADIUS:
			constructible.call("server_take_damage", ARTILLERY_DAMAGE, owner_id)
	show_artillery_impact.rpc(position)

@rpc("authority", "call_local", "reliable")
func show_artillery_warning(target_position: Vector3, delay_seconds: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var marker := Label3D.new()
	marker.text = "ARTILLERY %.1fs" % delay_seconds
	marker.position = target_position + Vector3.UP
	marker.font_size = 34
	marker.outline_size = 12
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.fixed_size = false
	marker.modulate = Color(1.0, 0.24, 0.08)
	add_child(marker)
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = delay_seconds
	timer.timeout.connect(marker.queue_free)
	marker.add_child(timer)
	timer.start()

@rpc("authority", "call_local", "reliable")
func show_artillery_impact(target_position: Vector3) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var root: Node3D = Node3D.new()
	root.position = target_position
	add_child(root)
	for offset in [Vector3.ZERO, Vector3(2.2,0,1.4), Vector3(-1.8,0,-1.9), Vector3(1.3,0,-2.4)]:
		var flash := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.8
		sphere.height = 1.6
		flash.mesh = sphere
		flash.position = offset + Vector3.UP * 0.5
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.albedo_color = Color(1.0, 0.32, 0.04)
		material.emission = Color(1.0, 0.18, 0.02)
		flash.material_override = material
		root.add_child(flash)
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.35
	timer.timeout.connect(root.queue_free)
	root.add_child(timer)
	timer.start()

func create_sensor_beacon(owner: Node3D) -> void:
	if not multiplayer.is_server() or owner == null:
		return
	var owner_id: int = int(owner.get("peer_id"))
	var old_ids: Array[int] = []
	for beacon_id_value in sensor_beacons:
		var beacon_id: int = int(beacon_id_value)
		var old_beacon: Node = sensor_beacons[beacon_id] as Node
		if old_beacon != null and int(old_beacon.get("owner_id")) == owner_id:
			old_ids.append(beacon_id)
	for old_id in old_ids:
		server_remove_sensor_beacon(old_id)
	var id: int = next_sensor_beacon_id
	next_sensor_beacon_id += 1
	var position: Vector3 = owner.global_position + (-owner.global_transform.basis.z * 1.5)
	position.y = 0.0
	spawn_sensor_beacon.rpc(id, owner_id, int(owner.get("team")), position, SENSOR_BEACON_DURATION, SENSOR_BEACON_RADIUS)

@rpc("authority", "call_local", "reliable")
func spawn_sensor_beacon(beacon_id: int, owner_id: int, team: int, position: Vector3, duration: float, radius: float) -> void:
	if sensor_beacons.has(beacon_id):
		return
	var beacon := Node3D.new()
	beacon.name = "SensorBeacon_%d" % beacon_id
	beacon.set_script(SensorBeaconScript)
	add_child(beacon)
	beacon.call("configure", beacon_id, owner_id, team, position, duration, radius)
	sensor_beacons[beacon_id] = beacon

func server_sensor_beacon_pulse(beacon: Node3D) -> void:
	if not multiplayer.is_server() or beacon == null:
		return
	var beacon_team: int = int(beacon.get("team"))
	var radius: float = float(beacon.get("radius"))
	for player_value in players.values():
		var target: Node3D = player_value as Node3D
		if target == null or int(target.get("team")) == beacon_team:
			continue
		if not bool(target.get("alive")):
			continue
		if target.global_position.distance_to(beacon.global_position) <= radius:
			target.call("server_set_spotted", 2600)

func server_remove_sensor_beacon(beacon_id: int) -> void:
	if multiplayer.is_server():
		remove_sensor_beacon.rpc(beacon_id)

@rpc("authority", "call_local", "reliable")
func remove_sensor_beacon(beacon_id: int) -> void:
	if not sensor_beacons.has(beacon_id):
		return

	var beacon_variant: Variant = sensor_beacons.get(beacon_id)
	sensor_beacons.erase(beacon_id)

	if beacon_variant == null:
		return
	if not is_instance_valid(beacon_variant):
		return

	var beacon: Node = beacon_variant as Node
	if beacon != null and not beacon.is_queued_for_deletion():
		beacon.queue_free()

func repair_nearby_barricades(engineer: Node3D, amount: int) -> int:
	if not multiplayer.is_server() or engineer == null:
		return 0
	var repaired := 0
	for constructible_value in constructibles.values():
		var barricade: Node = constructible_value as Node
		var barricade_3d: Node3D = barricade as Node3D
		if barricade == null or barricade_3d == null:
			continue
		if int(barricade.get("team")) != int(engineer.get("team")):
			continue
		if engineer.global_position.distance_to(barricade_3d.global_position) > 8.0:
			continue
		var health: int = int(barricade.get("health"))
		var maximum: int = int(barricade.get("maximum_health"))
		if health >= maximum:
			continue
		var new_health: int = mini(maximum, health + amount)
		barricade.set("health", new_health)
		barricade.call("_update_health_label_rpc", new_health)
		repaired += 1
	return repaired

@rpc("any_peer", "call_remote", "reliable")
func request_engineer_barricade(requested_peer_id: int, position_hint: Vector3, rotation_y: float) -> void:
	var engineer: Node3D = _player_from_remote_sender()
	if engineer == null or int(engineer.get("player_class")) != 2:
		return
	if not bool(engineer.get("alive")) or bool(engineer.get("downed")):
		return
	var engineer_id: int = int(engineer.get("peer_id"))
	var owned_ids: Array = engineer_constructibles.get(engineer_id, [])
	while owned_ids.size() >= MAX_BARRICADES_PER_ENGINEER:
		var oldest_id: int = int(owned_ids.pop_front())
		server_destroy_constructible(oldest_id, 0)
	var forward_position: Vector3 = engineer.global_position + (-engineer.global_transform.basis.z * 2.4)
	forward_position.y = 0.0
	if forward_position.distance_to(position_hint) > 4.0:
		position_hint = forward_position
	position_hint.y = 0.0
	var id: int = next_constructible_id
	next_constructible_id += 1
	owned_ids.append(id)
	engineer_constructibles[engineer_id] = owned_ids
	spawn_constructible.rpc(id, engineer_id, int(engineer.get("team")), position_hint, rotation_y, 180)
	engineer.call("add_xp", 5, "field fortification")
	push_kill_feed.rpc("%s deployed a barricade" % str(engineer.get("player_name")))

@rpc("authority", "call_local", "reliable")
func spawn_constructible(constructible_id: int, owner_id: int, team: int, spawn_position: Vector3, rotation_y: float, health: int) -> void:
	if constructibles.has(constructible_id):
		return
	var barricade := StaticBody3D.new()
	barricade.name = "Barricade_%d" % constructible_id
	barricade.set_script(ConstructibleScript)
	add_child(barricade)
	barricade.call("configure", constructible_id, owner_id, team, spawn_position, rotation_y, health)
	constructibles[constructible_id] = barricade

func server_destroy_constructible(constructible_id: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or not constructibles.has(constructible_id):
		return
	var barricade: Node = constructibles[constructible_id] as Node
	var owner_id := 0
	if barricade != null:
		owner_id = int(barricade.get("owner_id"))
	if engineer_constructibles.has(owner_id):
		var owned: Array = engineer_constructibles[owner_id]
		owned.erase(constructible_id)
		engineer_constructibles[owner_id] = owned
	remove_constructible.rpc(constructible_id)
	if attacker_id != 0 and players.has(attacker_id):
		players[attacker_id].call("add_xp", 4, "fortification destroyed")

@rpc("authority", "call_local", "reliable")
func remove_constructible(constructible_id: int) -> void:
	if not constructibles.has(constructible_id):
		return

	var barricade_variant: Variant = constructibles.get(
		constructible_id
	)
	constructibles.erase(constructible_id)

	if barricade_variant == null:
		return
	if not is_instance_valid(barricade_variant):
		return

	var barricade: Node = barricade_variant as Node
	if barricade != null and not barricade.is_queued_for_deletion():
		barricade.queue_free()

@rpc("any_peer", "call_remote", "reliable")
func request_player_fire(
	requested_peer_id: int,
	origin: Vector3,
	direction: Vector3
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_fire", direction)

@rpc("any_peer", "call_remote", "reliable")
func request_player_grenade(
	requested_peer_id: int,
	origin: Vector3,
	direction: Vector3
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_throw_grenade_request", direction)

@rpc("any_peer", "call_remote", "reliable")
func request_player_reload(requested_peer_id: int) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_reload_request")

@rpc("any_peer", "call_remote", "reliable")
func request_player_weapon(
	requested_peer_id: int,
	desired_index: int
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_weapon_switch_request", desired_index)

@rpc("any_peer", "call_remote", "reliable")
func request_player_interact(requested_peer_id: int) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_interact_request")

@rpc("any_peer", "call_remote", "reliable")
func request_player_ability(requested_peer_id: int) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_ability_request")

@rpc("any_peer", "call_remote", "reliable")
func request_player_profile(
	requested_name: String,
	requested_player_id: String = ""
) -> void:
	if not multiplayer.is_server():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	if not players.has(sender_id):
		return

	var safe_identity := requested_player_id.strip_edges().substr(
		0,
		64
	)
	if safe_identity.length() >= 16:
		player_identity_ids[sender_id] = safe_identity
		if progression_store != null:
			receive_progression.rpc_id(
				sender_id,
				progression_store.record_for(safe_identity)
			)

	var safe_name: String = PlayerProfileScript.sanitize_player_name(
		requested_name
	)

	# Prevent exact duplicate names while keeping the requested identity clear.
	var base_name := safe_name
	var suffix := 2
	while safe_name in player_names.values():
		if str(player_names.get(sender_id, "")) == safe_name:
			break
		safe_name = "%s%d" % [base_name.substr(0, 17), suffix]
		suffix += 1

	player_names[sender_id] = safe_name
	var player: Node3D = players[sender_id] as Node3D
	if player != null:
		player.set("player_name", safe_name)

	apply_player_name.rpc(sender_id, safe_name)
	push_kill_feed.rpc("%s joined the battle" % safe_name)

@rpc("authority", "call_local", "reliable")
func apply_player_name(peer_id: int, safe_name: String) -> void:
	player_names[peer_id] = safe_name
	if players.has(peer_id):
		var player: Node3D = players[peer_id] as Node3D
		if player != null:
			player.set("player_name", safe_name)

@rpc("authority", "call_remote", "reliable")
func receive_progression(record: Dictionary) -> void:
	local_progression = record.duplicate(true)
	_update_progression_panel()

@rpc("authority", "call_remote", "reliable")
func receive_round_history(
	summary: Dictionary,
	record: Dictionary
) -> void:
	local_progression = record.duplicate(true)
	if profile_manager != null:
		local_profile = profile_manager.append_match(summary)
	_update_progression_panel()

@rpc("any_peer", "call_remote", "reliable")
func request_player_team_and_class(
	requested_peer_id: int,
	requested_team: int,
	requested_class: int
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player == null:
		return

	var safe_team: int = clampi(requested_team, 0, 1)
	var safe_class: int = clampi(requested_class, 0, 4)

	var sender_id: int = multiplayer.get_remote_sender_id()
	player_teams[sender_id] = safe_team
	player.call("server_set_team_and_class", safe_team, safe_class)

	print(
		"Peer %d selected team=%d class=%d" % [
			sender_id,
			safe_team,
			safe_class
		]
	)

func server_scout_recon(
	scout: Node3D,
	radius: float = 36.0,
	duration_ms: int = 8000
) -> int:
	if not multiplayer.is_server() or scout == null:
		return 0

	var scout_team: int = int(scout.get("team"))
	var spotted_count := 0

	for player_value in players.values():
		var candidate: Node3D = player_value as Node3D
		if candidate == null or candidate == scout:
			continue
		if int(candidate.get("team")) == scout_team:
			continue
		if not bool(candidate.get("alive")):
			continue
		if scout.global_position.distance_to(candidate.global_position) > radius:
			continue

		candidate.call("server_apply_spotted", duration_ms)
		spotted_count += 1

	if spotted_count > 0:
		scout.call("add_xp", spotted_count * 3, "recon spotting")

	push_kill_feed.rpc(
		"%s spotted %d enemies" % [
			str(scout.get("player_name")),
			spotted_count
		]
	)
	return spotted_count

@rpc("any_peer", "call_remote", "reliable")
func request_player_class(
	requested_peer_id: int,
	class_index: int
) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player != null:
		player.call("server_class_request", class_index)

@rpc("authority", "call_remote", "unreliable_ordered", 3)
func receive_input_ack(sequence: int) -> void:
	if multiplayer.is_server():
		return
	last_server_input_ack = sequence

func _broadcast_player_snapshots() -> void:
	if not multiplayer.is_server():
		return

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue

		var head: Node3D = player.get_node_or_null("Head") as Node3D
		var head_pitch: float = 0.0
		if head != null:
			head_pitch = head.rotation.x

		receive_player_snapshot.rpc(
			int(player.get("peer_id")),
			player.global_position,
			player.rotation.y,
			head_pitch,
			int(player.get("health")),
			int(player.get("ammo_in_mag")),
			int(player.get("reserve_ammo")),
			bool(player.get("alive")),
			bool(player.get("downed")),
			bool(player.get("is_reloading")),
			int(player.get("player_class")),
			int(player.get("team")),
			int(player.get("kills")),
			int(player.get("deaths")),
			int(player.get("xp")),
			int(player.get("current_weapon_index")),
			int(player.get("grenades_remaining")),
			bool(player.get("is_crouching")),
			int(player.call("spawn_protection_remaining_ms")),
			int(player.call("ability_cooldown_remaining_ms")),
			int(player.call("spotted_remaining_ms")),
			float(player.get("stamina")),
			int(player.call("suppression_remaining_ms")),
			int(player.get("smoke_grenades")),
			int(player.call("heavy_fire_remaining_ms"))
		)

@rpc("authority", "call_remote", "unreliable_ordered", 1)
func receive_player_snapshot(
	peer_id: int,
	pos: Vector3,
	yaw: float,
	head_pitch: float,
	hp: int,
	magazine: int,
	reserve: int,
	is_alive: bool,
	is_downed: bool,
	reloading: bool,
	class_id: int,
	player_team: int,
	kill_count: int,
	death_count: int,
	experience: int,
	weapon_index: int,
	grenade_count: int,
	crouching: bool,
	spawn_protection_ms: int,
	ability_cooldown_ms: int,
	spotted_ms: int,
	stamina_value: float,
	suppression_ms: int,
	smoke_count: int,
	heavy_fire_ms: int
) -> void:
	if multiplayer.is_server():
		return

	if not players.has(peer_id):
		# The reliable spawn packet has not arrived yet. Dropping this
		# unreliable snapshot is safe; a newer snapshot will follow.
		return

	var player: Node = players[peer_id] as Node
	if player == null:
		return

	player.call(
		"apply_player_snapshot",
		pos,
		yaw,
		head_pitch,
		hp,
		magazine,
		reserve,
		is_alive,
		is_downed,
		reloading,
		class_id,
		player_team,
		kill_count,
		death_count,
		experience,
		weapon_index,
		grenade_count,
		crouching,
		spawn_protection_ms,
		ability_cooldown_ms,
		spotted_ms,
		stamina_value,
		suppression_ms,
		smoke_count,
		heavy_fire_ms
	)

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, team: int, pname: String, spawn_position: Vector3) -> void:
	if players.has(peer_id): return
	var player = PlayerScene.instantiate()
	player.name = str(peer_id)
	player.peer_id = peer_id
	player.team = team
	player.player_name = pname
	player.position = spawn_position
	add_child(player)
	players[peer_id] = player

	if peer_id == multiplayer.get_unique_id():
		_apply_profile_to_local_player()

	if multiplayer.is_server():
		print(
			"Spawned %s peer=%d team=%d at %s" % [
				pname,
				peer_id,
				team,
				spawn_position
			]
		)

@rpc("authority", "call_local", "reliable")
func remove_player(peer_id: int) -> void:
	if players.has(peer_id): players[peer_id].queue_free(); players.erase(peer_id)

func _get_spawn(team: int, peer_id: int) -> Vector3:
	var safe_team: int = clampi(team, 0, 1)
	var points: Array = spawn_points.get(safe_team, spawn_points[0])

	var rally_spawn: Variant = _rally_spawn_position(
		safe_team,
		peer_id
	)
	if rally_spawn is Vector3:
		return rally_spawn as Vector3

	var sector_spawn: Variant = sector_forward_spawn(safe_team)
	if sector_spawn is Vector3:
		var validated_sector: Dictionary = _validate_spawn_candidate(
			sector_spawn as Vector3,
			peer_id
		)
		if bool(validated_sector.get("valid", false)):
			return Vector3(validated_sector.get("position"))

	if (
		objective_stage >= 1
		and command_post_control == safe_team
	):
		points = forward_spawn_points.get(
			safe_team,
			points
		)
	var start_index: int = posmod(peer_id, points.size())

	for offset in range(points.size()):
		var candidate_index: int = posmod(
			start_index + offset,
			points.size()
		)
		var base_candidate: Vector3 = points[candidate_index]
		var validated: Dictionary = _validate_spawn_candidate(
			base_candidate,
			peer_id
		)
		if bool(validated.get("valid", false)):
			return Vector3(validated.get("position"))

	# Try nearby offsets around the preferred team side.
	var team_x: float = -15.0 if safe_team == 0 else 15.0
	var fallback_offsets: Array[Vector3] = [
		Vector3(team_x, 1.0, 0.0),
		Vector3(team_x, 1.0, 4.0),
		Vector3(team_x, 1.0, -4.0),
		Vector3(team_x - (2.0 if safe_team == 0 else -2.0), 1.0, 7.5),
		Vector3(team_x - (2.0 if safe_team == 0 else -2.0), 1.0, -7.5)
	]

	for fallback in fallback_offsets:
		var validated_fallback: Dictionary = _validate_spawn_candidate(
			fallback,
			peer_id
		)
		if bool(validated_fallback.get("valid", false)):
			return Vector3(validated_fallback.get("position"))

	# Last-resort point is still placed above known solid team ground.
	var emergency := Vector3(
		-17.0 if safe_team == 0 else 17.0,
		1.15,
		0.0
	)
	push_warning(
		"No fully clear spawn found for peer %d; using emergency spawn %s"
		% [peer_id, emergency]
	)
	return emergency

func server_recover_stuck_player(
	peer_id: int,
	team_id: int,
	current_position: Vector3
) -> Vector3:
	if not multiplayer.is_server():
		return current_position

	var candidates: Array = spawn_points.get(
		clampi(team_id, 0, 1),
		[]
	)
	var best_position := current_position
	var best_distance := INF

	for candidate_value in candidates:
		var candidate: Vector3 = Vector3(candidate_value)
		var result: Dictionary = _validate_spawn_candidate(
			candidate,
			peer_id
		)
		if not bool(result.get("valid", false)):
			continue
		var validated: Vector3 = Vector3(
			result.get("position", candidate)
		)
		var distance: float = current_position.distance_to(validated)
		if distance < best_distance:
			best_distance = distance
			best_position = validated

	return best_position

func _spawn_enemy_staging_position(team_id: int) -> Vector3:
	return Vector3(56.0,0.0,10.0) if team_id == 0 else Vector3(-56.0,0.0,-10.0)

func _validate_spawn_candidate(
	base_candidate: Vector3,
	peer_id: int
) -> Dictionary:
	if not multiplayer.is_server():
		return {
			"valid": true,
			"position": base_candidate
		}

	var viewport: Viewport = get_viewport()
	if viewport == null:
		return {
			"valid": false,
			"position": base_candidate
		}

	var world: World3D = viewport.world_3d
	if world == null:
		return {
			"valid": false,
			"position": base_candidate
		}

	var space_state: PhysicsDirectSpaceState3D = (
		world.direct_space_state
	)

	# Find actual floor below the candidate rather than trusting its Y value.
	var ray_from := Vector3(
		base_candidate.x,
		base_candidate.y + 6.0,
		base_candidate.z
	)
	var ray_to := Vector3(
		base_candidate.x,
		base_candidate.y - 20.0,
		base_candidate.z
	)
	var floor_query := PhysicsRayQueryParameters3D.create(
		ray_from,
		ray_to
	)
	floor_query.collision_mask = 1
	floor_query.collide_with_areas = false
	floor_query.collide_with_bodies = true

	var floor_hit: Dictionary = space_state.intersect_ray(
		floor_query
	)
	if floor_hit.is_empty():
		return {
			"valid": false,
			"position": base_candidate
		}

	var floor_normal: Vector3 = Vector3(
		floor_hit.get("normal", Vector3.ZERO)
	)
	if floor_normal.dot(Vector3.UP) < 0.65:
		return {
			"valid": false,
			"position": base_candidate
		}

	var floor_position: Vector3 = Vector3(
		floor_hit.get("position", base_candidate)
	)

	# Player capsule is 1.8 m tall with a 0.45 m radius.
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.52
	capsule.height = 1.95

	var spawn_position := floor_position + Vector3.UP * 0.96
	var shape_query := PhysicsShapeQueryParameters3D.new()
	shape_query.shape = capsule
	shape_query.transform = Transform3D(
		Basis.IDENTITY,
		spawn_position
	)
	shape_query.collision_mask = 1
	shape_query.collide_with_areas = false
	shape_query.collide_with_bodies = true
	shape_query.margin = 0.10

	var excluded: Array[RID] = []
	if players.has(peer_id):
		var existing_player: CollisionObject3D = (
			players[peer_id] as CollisionObject3D
		)
		if existing_player != null:
			excluded.append(existing_player.get_rid())
	shape_query.exclude = excluded

	var overlaps: Array[Dictionary] = (
		space_state.intersect_shape(shape_query, 16)
	)

	# Ignore the floor body itself only when the capsule is merely resting
	# above it; any other overlap means the point is obstructed.
	for overlap in overlaps:
		var collider: Object = overlap.get("collider")
		if collider == floor_hit.get("collider"):
			continue
		return {
			"valid": false,
			"position": spawn_position
		}

	# Keep players separated even if their collision layers later change.
	for player_value in players.values():
		var other_player: Node3D = player_value as Node3D
		if other_player == null:
			continue
		if int(other_player.get("peer_id")) == peer_id:
			continue
		if not bool(other_player.get("alive")):
			continue
		if other_player.global_position.distance_to(spawn_position) < 1.4:
			return {
				"valid": false,
				"position": spawn_position
			}

	var spawn_team := 0
	if player_teams.has(peer_id):
		spawn_team = int(player_teams[peer_id])
	var enemy_staging := _spawn_enemy_staging_position(spawn_team)
	if spawn_position.distance_to(enemy_staging) < 18.0:
		return {
			"valid": false,
			"position": spawn_position
		}

	return {
		"valid": true,
		"position": spawn_position
	}

func _respawn_wave() -> void:
	for peer_id_value in players:
		var peer_id: int = int(peer_id_value)
		var player: Node3D = players[peer_id] as Node3D
		if player == null:
			continue
		if not bool(player.get("alive")):
			var player_team: int = int(player.get("team"))
			if _ticket_value(player_team) <= 0:
				continue
			player.call(
				"server_respawn",
				_get_spawn(player_team, peer_id)
			)

func server_engineer_interact(engineer: Node3D) -> bool:
	if not multiplayer.is_server() or match_over:
		return false

	var engineer_team: int = int(engineer.get("team"))
	var engineer_id: int = int(engineer.get("peer_id"))

	if objective_stage == 0:
		var build_site := get_node_or_null("BridgeBuildSite")
		if engineer_team == 0 and build_site and engineer.global_position.distance_to(build_site.global_position) <= 3.5:
			bridge_progress = mini(bridge_required, bridge_progress + 1)
			engineer.add_xp(5, "construction")
			_update_objective_visuals()
			if bridge_progress >= bridge_required:
				objective_stage = 1
				var bridge: Node = get_node_or_null("ConstructedBridge")
				if bridge:
					bridge.visible = true
					bridge.process_mode = Node.PROCESS_MODE_INHERIT
				push_kill_feed.rpc("%s constructed the bridge" % player_names.get(engineer_id, "Engineer"))
				engineer.add_xp(50, "bridge completed")
				_update_objective_visuals()
			return true
		return false

	var objective := get_node_or_null("Objective")
	if not objective or engineer.global_position.distance_to(objective.global_position) > 3.5:
		return false

	if engineer_team == 0:
		return arm_dynamite(engineer_id)

	if dynamite_armed:
		defuse_progress = mini(defuse_required, defuse_progress + 1)
		engineer.add_xp(5, "defusing")
		if defuse_progress >= defuse_required:
			dynamite_armed = false
			dynamite_remaining = 0.0
			defuse_progress = 0
			_update_objective_visuals()
			push_kill_feed.rpc("%s defused the charge" % player_names.get(engineer_id, "Engineer"))
			engineer.add_xp(40, "charge defused")
		return true

	return false

func arm_dynamite(engineer_id: int) -> bool:
	if not multiplayer.is_server() or match_over or objective_stage != 1 or dynamite_armed:
		return false
	dynamite_armed = true
	dynamite_remaining = DYNAMITE_FUSE_SECONDS
	defuse_progress = 0
	_update_objective_visuals()
	push_kill_feed.rpc("%s armed the bunker charge" % player_names.get(engineer_id, "Engineer"))
	if players.has(engineer_id):
		players[engineer_id].add_xp(25, "charge armed")
	return true

func damage_objective(amount: int, attacker_team: int) -> void:
	if not multiplayer.is_server() or match_over or attacker_team != 0: return
	objective_health = maxi(0, objective_health - amount)
	if objective_health <= 0: _end_match("ATTACKERS WIN — objective destroyed")

func register_elimination(victim_id: int, attacker_id: int) -> void:
	var victim: Node3D = players.get(victim_id) as Node3D
	if victim != null:
		_consume_ticket(int(victim.get("team")))

	if players.has(attacker_id) and attacker_id != victim_id:
		var attacker: Node3D = players[attacker_id] as Node3D
		if attacker != null:
			attacker.set(
				"kills",
				int(attacker.get("kills")) + 1
			)
			attacker.call("add_xp", 10, "elimination")
			attacker.call("server_register_elimination")

	if victim != null:
		var contributors: Dictionary = victim.call(
			"recent_damage_contributors"
		)
		for contributor_id_value in contributors:
			var contributor_id: int = int(contributor_id_value)
			if contributor_id == attacker_id:
				continue
			if contributor_id == victim_id:
				continue
			if not players.has(contributor_id):
				continue

			var contributor: Node3D = players[
				contributor_id
			] as Node3D
			if contributor == null:
				continue

			contributor.call("add_xp", 5, "assist")
			contributor.call("server_confirm_assist")
			push_kill_feed.rpc(
				"%s assisted against %s" % [
					player_names.get(
						contributor_id,
						"Player"
					),
					player_names.get(victim_id, "Player")
				]
			)

	push_kill_feed.rpc(
		"%s eliminated %s" % [
			player_names.get(attacker_id, "World"),
			player_names.get(victim_id, "Player")
		]
	)

@rpc("any_peer", "call_remote", "reliable")
func request_player_smoke(requested_peer_id: int, origin: Vector3, direction: Vector3) -> void:
	var player: Node3D = _player_from_remote_sender()
	if player == null or int(player.get("smoke_grenades")) <= 0:
		return
	if not bool(player.get("alive")) or bool(player.get("downed")):
		return
	player.set("smoke_grenades", int(player.get("smoke_grenades")) - 1)
	var landing_position: Vector3 = origin + direction.normalized() * 10.0
	landing_position.y = 0.15
	var smoke_id: int = next_smoke_id
	next_smoke_id += 1
	spawn_smoke.rpc(smoke_id, int(player.get("team")), landing_position, 12.0, 5.5)

@rpc("authority", "call_local", "reliable")
func spawn_smoke(smoke_id: int, team: int, spawn_position: Vector3, duration: float, radius: float) -> void:
	if smoke_clouds.has(smoke_id):
		return
	var cloud := Node3D.new()
	cloud.name = "Smoke_%d" % smoke_id
	cloud.set_script(SmokeCloudScript)
	add_child(cloud)
	cloud.call("configure", smoke_id, team, spawn_position, duration, radius)
	smoke_clouds[smoke_id] = cloud

func server_remove_smoke(smoke_id: int) -> void:
	if multiplayer.is_server():
		remove_smoke.rpc(smoke_id)

@rpc("authority", "call_local", "reliable")
func remove_smoke(smoke_id: int) -> void:
	if not smoke_clouds.has(smoke_id):
		return

	var cloud_variant: Variant = smoke_clouds.get(smoke_id)
	smoke_clouds.erase(smoke_id)

	if cloud_variant == null:
		return
	if not is_instance_valid(cloud_variant):
		return

	var cloud: Node = cloud_variant as Node
	if cloud != null and not cloud.is_queued_for_deletion():
		cloud.queue_free()

func line_blocked_by_smoke(
	start_position: Vector3,
	end_position: Vector3
) -> bool:
	var segment: Vector3 = end_position - start_position
	var segment_length_sq: float = segment.length_squared()
	if segment_length_sq <= 0.001:
		return false

	var stale_ids: Array[int] = []

	for smoke_id_value in smoke_clouds:
		var smoke_id: int = int(smoke_id_value)
		var cloud_variant: Variant = smoke_clouds.get(smoke_id)

		if cloud_variant == null or not is_instance_valid(cloud_variant):
			stale_ids.append(smoke_id)
			continue

		var cloud: Node3D = cloud_variant as Node3D
		if cloud == null or cloud.is_queued_for_deletion():
			stale_ids.append(smoke_id)
			continue

		var t: float = clampf(
			(
				cloud.global_position - start_position
			).dot(segment) / segment_length_sq,
			0.0,
			1.0
		)
		var closest: Vector3 = start_position + segment * t
		var radius: float = float(cloud.get("radius"))

		if closest.distance_to(cloud.global_position) <= radius:
			for stale_id in stale_ids:
				smoke_clouds.erase(stale_id)
			return true

	for stale_id in stale_ids:
		smoke_clouds.erase(stale_id)

	return false

func server_throw_grenade(
	owner: Node3D,
	origin: Vector3,
	direction: Vector3
) -> bool:
	if not multiplayer.is_server() or match_over:
		return false
	if owner == null:
		return false

	var owner_id: int = int(owner.get("peer_id"))
	var owner_team: int = int(owner.get("team"))
	var grenade_id: int = next_grenade_id
	next_grenade_id += 1

	var safe_direction: Vector3 = direction.normalized()
	var initial_velocity: Vector3 = safe_direction * 13.0 + Vector3.UP * 4.5

	spawn_grenade.rpc(
		grenade_id,
		owner_id,
		owner_team,
		origin,
		initial_velocity,
		3.0
	)
	return true

@rpc("authority", "call_local", "reliable")
func spawn_grenade(
	grenade_id: int,
	owner_id: int,
	owner_team: int,
	spawn_position: Vector3,
	initial_velocity: Vector3,
	fuse_seconds: float
) -> void:
	if grenades.has(grenade_id):
		return

	var grenade: Node3D = GrenadeScene.instantiate() as Node3D
	if grenade == null:
		return

	grenade.name = "Grenade_%d" % grenade_id
	add_child(grenade)
	grenade.call(
		"configure",
		grenade_id,
		owner_id,
		owner_team,
		spawn_position,
		initial_velocity,
		fuse_seconds
	)
	grenades[grenade_id] = grenade

func server_explode_grenade(
	grenade_id: int,
	explosion_position: Vector3,
	owner_id: int,
	owner_team: int,
	radius: float,
	maximum_damage: int
) -> void:
	if not multiplayer.is_server():
		return
	if not grenades.has(grenade_id):
		return

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		if not bool(player.get("alive")):
			continue

		var player_team: int = int(player.get("team"))
		if player_team == owner_team:
			continue

		var distance: float = explosion_position.distance_to(
			player.global_position
		)
		if distance > radius:
			continue

		var damage_scale: float = 1.0 - clampf(distance / radius, 0.0, 1.0)
		var damage: int = maxi(1, int(round(maximum_damage * damage_scale)))
		player.call("server_take_damage", damage, owner_id)

		if players.has(owner_id):
			var grenade_owner: Node3D = players[owner_id] as Node3D
			if grenade_owner != null:
				grenade_owner.call("server_confirm_hit")

	explode_grenade.rpc(grenade_id, explosion_position)

@rpc("authority", "call_local", "reliable")
func explode_grenade(
	grenade_id: int,
	explosion_position: Vector3
) -> void:
	if grenades.has(grenade_id):
		var grenade: Node = grenades[grenade_id] as Node
		if grenade != null:
			grenade.queue_free()
		grenades.erase(grenade_id)

	if (
		DisplayServer.get_name() != "headless"
		and ResourceLoader.exists("res://audio/explosion.wav")
	):
		var explosion_resource: Resource = load(
			"res://audio/explosion.wav"
		)
		if explosion_resource is AudioStream:
			var explosion_audio := AudioStreamPlayer3D.new()
			explosion_audio.stream = (
				explosion_resource as AudioStream
			)
			explosion_audio.global_position = explosion_position
			explosion_audio.max_distance = 45.0
			explosion_audio.volume_db = -2.0
			add_child(explosion_audio)
			explosion_audio.finished.connect(
				explosion_audio.queue_free
			)
			explosion_audio.play()

	var flash := MeshInstance3D.new()
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.35
	flash_mesh.height = 0.7
	flash.mesh = flash_mesh
	flash.global_position = explosion_position

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.42, 0.08, 0.8)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.25, 0.02)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = material
	add_child(flash)

	_spawn_explosion_debris(explosion_position)

	var shockwave := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.22
	ring_mesh.outer_radius = 0.34
	shockwave.mesh = ring_mesh
	shockwave.global_position = explosion_position + Vector3(0.0,0.18,0.0)
	shockwave.rotation_degrees.x = 90.0
	var ring_material := StandardMaterial3D.new()
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.albedo_color = Color(1.0,0.72,0.22,0.70)
	shockwave.material_override = ring_material
	add_child(shockwave)
	var ring_tween := create_tween()
	ring_tween.set_parallel(true)
	ring_tween.tween_property(shockwave,"scale",Vector3.ONE*8.5,0.34)
	ring_tween.tween_property(ring_material,"albedo_color",Color(1.0,0.72,0.22,0.0),0.34)
	ring_tween.chain().tween_callback(shockwave.queue_free)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector3.ONE * 6.0, 0.22)
	tween.tween_property(
		material,
		"albedo_color",
		Color(1.0, 0.42, 0.08, 0.0),
		0.22
	)
	tween.chain().tween_callback(flash.queue_free)

func create_supply_pack(owner: Node3D, pack_type: int, amount: int) -> void:
	if not multiplayer.is_server():
		return

	var id: int = next_supply_pack_id
	next_supply_pack_id += 1

	var spawn_position: Vector3 = (
		owner.global_position
		+ (-owner.global_transform.basis.z * 1.2)
	)
	spawn_position.y = 0.35

	var owner_team: int = int(owner.get("team"))
	spawn_supply_pack.rpc(
		id,
		owner_team,
		pack_type,
		amount,
		spawn_position
	)

@rpc("authority", "call_local", "reliable")
func spawn_supply_pack(
	pack_id: int,
	team: int,
	pack_type: int,
	amount: int,
	spawn_position: Vector3
) -> void:
	if supply_packs.has(pack_id):
		return

	var pack := Node3D.new()
	pack.set_script(SupplyPackScript)
	pack.pack_id = pack_id
	pack.team = team
	pack.pack_type = pack_type
	pack.amount = amount
	pack.position = spawn_position

	add_child(pack)
	supply_packs[pack_id] = pack

@rpc("authority", "call_local", "reliable")
func remove_supply_pack(pack_id: int) -> void:
	if supply_packs.has(pack_id): supply_packs[pack_id].queue_free(); supply_packs.erase(pack_id)

func _winner_team(message: String) -> int:
	if message.to_upper().begins_with("ATTACKERS WIN"):
		return 0
	if message.to_upper().begins_with("DEFENDERS WIN"):
		return 1
	return -1

func _commit_progression(message: String) -> void:
	if not multiplayer.is_server() or progression_store == null:
		return
	var winner := _winner_team(message)
	for peer_value in players:
		var peer_id := int(peer_value)
		var actor: Node3D = players[peer_id] as Node3D
		if actor == null or bool(actor.get("is_bot")):
			continue
		var identity := str(player_identity_ids.get(peer_id,""))
		if identity.length() < 16:
			continue
		var won := winner >= 0 and int(actor.get("team")) == winner
		var stats := {
			"kills": int(actor.get("kills")),
			"deaths": int(actor.get("deaths")),
			"assists": int(actor.get("assists")),
			"objective": int(actor.get("objective_points")),
			"xp": int(actor.get("round_xp"))
		}
		var record: Dictionary = progression_store.commit(
			identity,
			str(actor.get("player_name")),
			stats,
			won
		)
		var summary := stats.duplicate(true)
		summary["server"] = "Frontline Server"
		summary["result"] = message
		summary["won"] = won
		receive_round_history.rpc_id(peer_id,summary,record)

func _end_match(message: String) -> void:
	if match_over:
		return

	match_over = true
	_commit_progression(message)
	round_restart_remaining = ROUND_RESTART_SECONDS
	announce.rpc(message)
	show_round_results.rpc(
		message,
		scoreboard_text() + "\n\n" + round_awards_text(),
		ROUND_RESTART_SECONDS
	)
	print(message)

@rpc("authority", "call_remote", "unreliable_ordered")
func broadcast_match_state(
	time_remaining: float,
	wave_remaining: float,
	health_remaining: int,
	stage: int,
	build_progress: int,
	build_required: int,
	armed: bool,
	fuse_remaining: float,
	current_defuse: int,
	required_defuse: int,
	attacker_ticket_count: int,
	defender_ticket_count: int,
	post_control: int,
	post_progress: float,
	post_contested: bool,
	overtime: bool
) -> void:
	match_time_remaining = time_remaining
	spawn_wave_remaining = wave_remaining
	objective_health = health_remaining
	objective_stage = stage
	bridge_progress = build_progress
	bridge_required = build_required
	dynamite_armed = armed
	dynamite_remaining = fuse_remaining
	defuse_progress = current_defuse
	defuse_required = required_defuse
	attacker_tickets = attacker_ticket_count
	defender_tickets = defender_ticket_count
	command_post_control = post_control
	command_post_progress = post_progress
	command_post_contested = post_contested
	overtime_active = overtime

	var bridge: Node = get_node_or_null("ConstructedBridge")
	if bridge:
		bridge.visible = objective_stage >= 1
		bridge.process_mode = (
			Node.PROCESS_MODE_INHERIT
			if objective_stage >= 1
			else Node.PROCESS_MODE_DISABLED
		)

	_update_objective_visuals()

@rpc("authority", "call_local", "unreliable")
func show_shot_effect(
	start_position: Vector3,
	end_position: Vector3,
	hit_player: bool,
	headshot: bool
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var effect_root := Node3D.new()
	effect_root.name = "ShotEffect"
	add_child(effect_root)

	var tracer := MeshInstance3D.new()
	var line_mesh := ImmediateMesh.new()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	line_mesh.surface_set_color(
		Color(1.0, 0.82, 0.32, 0.95)
	)
	var tracer_start: Vector3 = start_position
	var shot_length: float = start_position.distance_to(end_position)
	if shot_length > 9.0:
		tracer_start = end_position.lerp(
			start_position,
			9.0 / shot_length
		)
	line_mesh.surface_add_vertex(tracer_start)
	line_mesh.surface_set_color(
		Color(1.0, 0.42, 0.08, 0.20)
	)
	line_mesh.surface_add_vertex(end_position)
	line_mesh.surface_end()
	tracer.mesh = line_mesh

	var tracer_material := StandardMaterial3D.new()
	tracer_material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)
	tracer_material.vertex_color_use_as_albedo = true
	tracer_material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)
	tracer.material_override = tracer_material
	effect_root.add_child(tracer)
	_ensure_combat_effects_manager()
	if combat_effects_manager != null:
		combat_effects_manager.call(
			"spawn_surface_impact",
			self,
			end_position,
			(start_position - end_position).normalized(),
			hit_player
		)

	var impact := MeshInstance3D.new()
	var impact_mesh := SphereMesh.new()
	impact_mesh.radius = 0.035 if not headshot else 0.060
	impact_mesh.height = 0.070 if not headshot else 0.120
	impact.mesh = impact_mesh
	impact.position = end_position

	var impact_material := StandardMaterial3D.new()
	impact_material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)
	impact_material.emission_enabled = true
	impact_material.albedo_color = (
		Color(1.0, 0.12, 0.05)
		if hit_player
		else Color(0.95, 0.72, 0.28)
	)
	impact_material.emission = impact_material.albedo_color
	impact.material_override = impact_material
	effect_root.add_child(impact)

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.075
	timer.timeout.connect(effect_root.queue_free)
	effect_root.add_child(timer)
	timer.start()

@rpc("authority", "call_local", "reliable")
func push_kill_feed(message: String) -> void:
	kill_feed.push_front(message)
	if kill_feed.size() > 5: kill_feed.resize(5)
	print(message)

func _round_results_style(
	background: Color,
	border: Color,
	border_width: int = 3
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 18.0
	style.content_margin_bottom = 18.0
	return style

func _build_round_results_ui() -> void:
	if DisplayServer.get_name() == "headless":
		return

	round_results_layer = CanvasLayer.new()
	round_results_layer.layer = 60
	add_child(round_results_layer)

	var dimmer := ColorRect.new()
	dimmer.name = "RoundResultsDimmer"
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.018, 0.018, 0.72)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dimmer.visible = false
	round_results_layer.add_child(dimmer)

	round_results_panel = PanelContainer.new()
	round_results_panel.name = "RoundResultsPanel"
	round_results_panel.set_anchors_preset(Control.PRESET_CENTER)
	round_results_panel.position = Vector2(-410, -285)
	round_results_panel.size = Vector2(820, 570)
	round_results_panel.add_theme_stylebox_override(
		"panel",
		_round_results_style(
			Color(0.035, 0.040, 0.037, 0.97),
			Color(0.56, 0.50, 0.30, 0.98)
		)
	)
	round_results_panel.visible = false
	round_results_layer.add_child(round_results_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	round_results_panel.add_child(layout)

	round_results_title = Label.new()
	round_results_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	round_results_title.add_theme_font_size_override("font_size", 30)
	round_results_title.add_theme_color_override(
		"font_color",
		Color(0.95, 0.83, 0.34)
	)
	round_results_title.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.95)
	)
	round_results_title.add_theme_constant_override(
		"shadow_offset_x",
		2
	)
	round_results_title.add_theme_constant_override(
		"shadow_offset_y",
		2
	)
	layout.add_child(round_results_title)

	var separator := HSeparator.new()
	layout.add_child(separator)

	round_results_summary = Label.new()
	round_results_summary.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	round_results_summary.vertical_alignment = (
		VERTICAL_ALIGNMENT_TOP
	)
	round_results_summary.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	round_results_summary.add_theme_font_size_override(
		"font_size",
		16
	)
	round_results_summary.add_theme_color_override(
		"font_color",
		Color(0.91, 0.90, 0.84)
	)
	round_results_summary.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	layout.add_child(round_results_summary)

	round_results_countdown = Label.new()
	round_results_countdown.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	round_results_countdown.add_theme_font_size_override(
		"font_size",
		20
	)
	round_results_countdown.add_theme_color_override(
		"font_color",
		Color(0.78, 0.84, 0.90)
	)
	layout.add_child(round_results_countdown)

	# Keep the legacy reference valid for any existing calls.
	round_results_label = round_results_summary

	announcement_layer = CanvasLayer.new()
	announcement_layer.layer = 55
	add_child(announcement_layer)

	announcement_panel = PanelContainer.new()
	announcement_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	announcement_panel.position = Vector2(-330, 28)
	announcement_panel.size = Vector2(660, 70)
	announcement_panel.add_theme_stylebox_override(
		"panel",
		_round_results_style(
			Color(0.035, 0.038, 0.034, 0.91),
			Color(0.55, 0.49, 0.27, 0.96),
			2
		)
	)
	announcement_panel.visible = false
	announcement_layer.add_child(announcement_panel)

	announcement_label = Label.new()
	announcement_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	announcement_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	announcement_label.add_theme_font_size_override(
		"font_size",
		23
	)
	announcement_label.add_theme_color_override(
		"font_color",
		Color(0.96, 0.90, 0.65)
	)
	announcement_panel.add_child(announcement_label)

func _compact_round_scoreboard(final_scoreboard: String) -> String:
	var compact_lines: Array[String] = []
	for raw_line in final_scoreboard.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty():
			if (
				not compact_lines.is_empty()
				and not compact_lines[-1].is_empty()
			):
				compact_lines.append("")
			continue
		if line.begins_with("FRONTLINE:"):
			continue
		if line.begins_with("Time "):
			compact_lines.append(line)
			continue
		if line.begins_with("Objective:"):
			compact_lines.append(line)
			continue
		if line.begins_with("Sector Control:"):
			compact_lines.append(line)
			continue
		if line in ["ATTACKERS", "DEFENDERS", "ROUND AWARDS"]:
			compact_lines.append("")
			compact_lines.append(line)
			continue
		if line.begins_with("PLAYER"):
			compact_lines.append(
				"PLAYER          CLASS       K/D/A   OBJ   XP"
			)
			continue
		if line.begins_with("CP "):
			compact_lines.append("")
			compact_lines.append(line)
			continue
		compact_lines.append(line)
	return "\n".join(compact_lines)

@rpc("authority", "call_local", "reliable")
func show_round_results(
	result_message: String,
	final_scoreboard: String,
	restart_seconds: float
) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if (
		round_results_panel == null
		or round_results_title == null
		or round_results_summary == null
	):
		return

	var dimmer := round_results_layer.get_node_or_null(
		"RoundResultsDimmer"
	) as ColorRect
	if dimmer != null:
		dimmer.visible = true

	round_results_title.text = result_message.to_upper()
	round_results_summary.text = _compact_round_scoreboard(
		final_scoreboard
	)
	round_results_countdown.text = (
		"Next round begins in %.0f seconds"
		% restart_seconds
	)
	round_results_panel.visible = true
	if announcement_panel != null:
		announcement_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

@rpc("authority", "call_local", "reliable")
func hide_round_results() -> void:
	if round_results_panel != null:
		round_results_panel.visible = false
	if round_results_layer != null:
		var dimmer := round_results_layer.get_node_or_null(
			"RoundResultsDimmer"
		) as ColorRect
		if dimmer != null:
			dimmer.visible = false

@rpc("authority", "call_local", "reliable")
func announce(message: String) -> void:
	print(message)
	if DisplayServer.get_name() == "headless":
		return
	if announcement_panel == null or announcement_label == null:
		return
	if round_results_panel != null and round_results_panel.visible:
		return

	announcement_label.text = message
	announcement_panel.visible = true
	announcement_hide_ms = Time.get_ticks_msec() + 3200

func _update_announcement_ui() -> void:
	if (
		announcement_panel != null
		and announcement_panel.visible
		and announcement_hide_ms > 0
		and Time.get_ticks_msec() >= announcement_hide_ms
	):
		announcement_panel.visible = false
		announcement_hide_ms = 0

func _update_command_post_stations() -> void:
	if not multiplayer.is_server() or objective_stage == 0 or command_post_control < 0:
		return
	var command_post: Node3D = _command_post_node()
	if command_post == null:
		return
	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null or int(player.get("team")) != command_post_control:
			continue
		if not bool(player.get("alive")) or player.global_position.distance_to(command_post.global_position) > 6.5:
			continue
		var max_health: int = int(player.call("_class_health", int(player.get("player_class"))))
		var current_health: int = int(player.get("health"))
		if current_health < max_health:
			player.set("health", mini(max_health, current_health + 4))
		var reserve: int = int(player.get("reserve_ammo"))
		var maximum_reserve: int = int(player.call("_weapon_reserve_ammo"))
		if reserve < maximum_reserve:
			player.set("reserve_ammo", mini(maximum_reserve, reserve + 7))
			player.call("_store_current_weapon_ammo")

func _update_station_visuals() -> void:
	if command_health_station == null or command_ammo_station == null:
		return
	var active: bool = objective_stage >= 1 and command_post_control >= 0
	command_health_station.visible = active
	command_ammo_station.visible = active
	if not active:
		return
	var owner_color := Color(0.18, 0.48, 1.0) if command_post_control == 0 else Color(1.0, 0.22, 0.16)
	for station in [command_health_station, command_ammo_station]:
		var material: StandardMaterial3D = station.material_override as StandardMaterial3D
		if material != null:
			material.emission = owner_color * 0.45

func _update_command_post_visuals() -> void:
	_update_station_visuals()
	if (
		command_post_marker == null
		or command_post_progress_label == null
		or command_post_beacon == null
	):
		return

	if objective_stage == 0:
		command_post_marker.text = "COMMAND POST LOCKED"
		command_post_progress_label.text = "Build the bridge first"
		command_post_marker.modulate = Color(0.62, 0.62, 0.65)
		command_post_beacon.light_color = Color(0.55, 0.55, 0.58)
		return

	var owner_text := "NEUTRAL"
	var owner_color := Color(0.72, 0.72, 0.72)
	if command_post_control == 0:
		owner_text = "ATTACKER FORWARD POST"
		owner_color = Color(0.20, 0.48, 1.0)
	elif command_post_control == 1:
		owner_text = "DEFENDER FORWARD POST"
		owner_color = Color(1.0, 0.22, 0.16)

	if command_post_contested:
		owner_text = "COMMAND POST CONTESTED"
		owner_color = Color(1.0, 0.72, 0.10)

	command_post_marker.text = owner_text
	command_post_marker.modulate = owner_color
	command_post_progress_label.text = (
		"Capture %+d%%" % int(round(command_post_progress))
	)
	command_post_progress_label.modulate = owner_color.lightened(0.2)
	command_post_beacon.light_color = owner_color
	command_post_beacon.light_energy = (
		2.8 if command_post_contested else 1.8
	)

func _update_objective_visuals() -> void:
	if objective_marker == null or objective_progress_label == null:
		return

	if match_over:
		objective_marker.text = "ROUND COMPLETE"
		objective_marker.modulate = Color(1.0, 0.82, 0.22)
		objective_progress_label.text = (
			"Restart in %.1fs" % round_restart_remaining
		)
	elif objective_stage == 0:
		var build_percent: int = int(round(
			100.0 * float(bridge_progress)
			/ float(maxi(1, bridge_required))
		))
		objective_marker.text = "BUILD THE BRIDGE"
		objective_marker.modulate = Color(0.92, 0.76, 0.16)
		objective_progress_label.text = "%d%%  (%d/%d)" % [
			build_percent,
			bridge_progress,
			bridge_required
		]
	elif dynamite_armed:
		objective_marker.text = "CHARGE ARMED"
		objective_marker.modulate = Color(1.0, 0.16, 0.08)
		objective_progress_label.text = (
			"Fuse %.1fs  ·  Defuse %d/%d"
			% [
				dynamite_remaining,
				defuse_progress,
				defuse_required
			]
		)
	else:
		objective_marker.text = "DESTROY THE BUNKER"
		objective_marker.modulate = Color(0.90, 0.22, 0.14)
		objective_progress_label.text = "Integrity %d%%" % objective_health

	if dynamite_model != null:
		dynamite_model.visible = dynamite_armed
	if dynamite_light != null:
		dynamite_light.visible = dynamite_armed
		if dynamite_armed:
			var pulse: float = 1.4 + sin(
				Time.get_ticks_msec() * 0.012
			) * 0.8
			dynamite_light.light_energy = pulse

func interaction_prompt_for(player: Node3D) -> String:
	if player == null or not bool(player.get("alive")):
		return ""

	var player_class: int = int(player.get("player_class"))
	var player_team: int = int(player.get("team"))
	var player_position: Vector3 = player.global_position

	if player_class != 2:
		if objective_stage == 0:
			return "Engineer required to construct the bridge"
		if dynamite_armed and player_team == 1:
			return "Engineer required to defuse the charge"
		return ""

	if objective_stage == 0:
		var build_site: Node3D = get_node_or_null(
			"BridgeBuildSite"
		) as Node3D
		if build_site == null:
			return ""
		var distance: float = player_position.distance_to(
			build_site.global_position
		)
		if distance <= 4.5:
			return "Hold E: Construct bridge  %d/%d" % [
				bridge_progress,
				bridge_required
			]
		return "Reach the yellow bridge construction zone"

	var objective: Node3D = get_node_or_null("Objective") as Node3D
	if objective == null:
		return ""

	var objective_distance: float = player_position.distance_to(
		objective.global_position
	)
	if player_team == 0:
		if dynamite_armed:
			return "Defend the armed charge  %.1fs" % dynamite_remaining
		if objective_distance <= 4.5:
			return "Hold E: Arm dynamite"
		return "Reach the bunker and arm dynamite"

	if dynamite_armed:
		if objective_distance <= 4.5:
			return "Hold E: Defuse charge  %d/%d" % [
				defuse_progress,
				defuse_required
			]
		return "Reach the bunker and defuse the charge"

	return "Defend the bunker"

func objective_status_text() -> String:
	if match_over:
		return "Round restarts in %.1fs" % round_restart_remaining

	var overtime_text := " · OVERTIME" if overtime_active else ""
	var guns_text: String = emplacement_status_text()
	var post_text := (
		"Neutral"
		if command_post_control < 0
		else (
			"Attackers"
			if command_post_control == 0
			else "Defenders"
		)
	)

	if objective_stage == 0:
		return (
			"Stage 1: Build bridge %d/%d · Tickets %d-%d · %s%s"
			% [
				bridge_progress,
				bridge_required,
				attacker_tickets,
				defender_tickets,
				guns_text + " · " + sector_status_text(),
				overtime_text
			]
		)

	if dynamite_armed:
		return (
			"Charge %.1fs · Defuse %d/%d · CP %s · Tickets %d-%d · %s%s"
			% [
				dynamite_remaining,
				defuse_progress,
				defuse_required,
				post_text,
				attacker_tickets,
				defender_tickets,
				guns_text,
				overtime_text
			]
		)

	return (
		"Destroy bunker %d%% · CP %s · Tickets %d-%d · %s%s"
		% [
			objective_health,
			post_text,
			attacker_tickets,
			defender_tickets,
			guns_text,
			overtime_text
		]
	)

func round_awards_text() -> String:
	if players.is_empty():
		return "ROUND AWARDS\nNo eligible players"

	var mvp: Node3D = null
	var top_fragger: Node3D = null
	var top_support: Node3D = null
	var top_objective: Node3D = null
	var survivor: Node3D = null

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue

		if (
			mvp == null
			or int(player.get("round_xp"))
			> int(mvp.get("round_xp"))
		):
			mvp = player

		if (
			top_fragger == null
			or int(player.get("kills"))
			> int(top_fragger.get("kills"))
		):
			top_fragger = player

		if (
			top_support == null
			or int(player.get("assists"))
			> int(top_support.get("assists"))
		):
			top_support = player

		if (
			top_objective == null
			or int(player.get("objective_points"))
			> int(top_objective.get("objective_points"))
		):
			top_objective = player

		if survivor == null:
			survivor = player
		else:
			var player_deaths: int = int(player.get("deaths"))
			var survivor_deaths: int = int(survivor.get("deaths"))
			if (
				player_deaths < survivor_deaths
				or (
					player_deaths == survivor_deaths
					and int(player.get("kills"))
					> int(survivor.get("kills"))
				)
			):
				survivor = player

	var lines: Array[String] = ["ROUND AWARDS"]

	if mvp != null:
		lines.append(
			"MVP: %s · %d round XP"
			% [
				str(mvp.get("player_name")),
				int(mvp.get("round_xp"))
			]
		)

	if top_fragger != null:
		lines.append(
			"Top Fragger: %s · %d eliminations"
			% [
				str(top_fragger.get("player_name")),
				int(top_fragger.get("kills"))
			]
		)

	if top_support != null:
		lines.append(
			"Support: %s · %d assists"
			% [
				str(top_support.get("player_name")),
				int(top_support.get("assists"))
			]
		)

	if top_objective != null:
		lines.append(
			"Objective Specialist: %s · %d objective score"
			% [
				str(top_objective.get("player_name")),
				int(top_objective.get("objective_points"))
			]
		)

	if survivor != null:
		lines.append(
			"Survivor: %s · %d deaths"
			% [
				str(survivor.get("player_name")),
				int(survivor.get("deaths"))
			]
		)

	lines.append("")
	lines.append("Current Objective: %s" % objective_status_text())
	lines.append("Sector Control: %s" % sector_status_text())
	return "\n".join(lines)

func scoreboard_text() -> String:
	# Keep scoreboard generation self-contained. Do not call scoreboard_text()
	# or recursively append round_awards_text() from either formatter.
	var class_names: Array[String] = [
		"Soldier",
		"Medic",
		"Engineer",
		"Field Ops",
		"Scout"
	]

	var lines: Array[String] = [
		"FRONTLINE: OBJECTIVE · OPERATION BLACK RIVER",
		(
			"Time %02d:%02d    ATK Tickets %d    DEF Tickets %d"
			% [
				int(match_time_remaining) / 60,
				int(match_time_remaining) % 60,
				attacker_tickets,
				defender_tickets
			]
		),
		"Objective: %s" % objective_status_text(),
		"Sector Control: %s" % sector_status_text(),
		"",
		"ATTACKERS",
		"PLAYER             CLASS        K   D   A   OBJ   XP   RANK"
	]

	var sorted_players: Array = players.values()
	sorted_players.sort_custom(
		func(a: Node3D, b: Node3D) -> bool:
			if int(a.get("team")) != int(b.get("team")):
				return int(a.get("team")) < int(b.get("team"))
			if int(a.get("round_xp")) != int(b.get("round_xp")):
				return int(a.get("round_xp")) > int(b.get("round_xp"))
			return int(a.get("kills")) > int(b.get("kills"))
	)

	for team_id in [0, 1]:
		if team_id == 1:
			lines.append("")
			lines.append("DEFENDERS")
			lines.append(
				"PLAYER             CLASS        K   D   A   OBJ   XP   RANK"
			)

		var team_found := false
		for player_value in sorted_players:
			var player: Node3D = player_value as Node3D
			if player == null or int(player.get("team")) != team_id:
				continue
			team_found = true
			var class_id: int = clampi(
				int(player.get("player_class")),
				0,
				class_names.size() - 1
			)
			var bot_suffix := " [BOT]" if bool(player.get("is_bot")) else ""
			lines.append(
				"%-18s %-12s %2d  %2d  %2d  %4d  %4d  %s%s"
				% [
					str(player.get("player_name")),
					class_names[class_id],
					int(player.get("kills")),
					int(player.get("deaths")),
					int(player.get("assists")),
					int(player.get("objective_points")),
					int(player.get("xp")),
					str(player.call("rank_name")),
					bot_suffix
				]
			)

		if not team_found:
			lines.append("-- No deployed players --")

	lines.append("")
	lines.append("ROUND AWARDS")
	var awards: String = round_awards_text()
	for award_line in awards.split("\n"):
		if award_line != "ROUND AWARDS":
			lines.append(award_line)

	lines.append("")
	lines.append(
		"CP %s · DEPOT %s · Protocol %d · Build %s"
		% [
			(
				"Neutral"
				if command_post_control < 0
				else (
					"Attackers"
					if command_post_control == 0
					else "Defenders"
				)
			),
			(
				"Neutral"
				if supply_depot_control < 0
				else (
					"Attackers"
					if supply_depot_control == 0
					else "Defenders"
				)
			),
			NETWORK_PROTOCOL,
			BUILD_VERSION
		]
	)

	return "\n".join(lines)


func _spawn_bot(index: int) -> void:
	if not multiplayer.is_server():
		return

	var bot_id: int = next_bot_peer_id
	next_bot_peer_id += 1
	var bot_team: int = index % 2
	var class_id: int = index % 5
	var bot_name := "Bot%02d" % (index + 1)

	spawn_player(
		bot_id,
		bot_team,
		bot_name,
		_get_spawn(bot_team, bot_id)
	)
	_configure_bot(bot_id, class_id)
	print(
		"Bot spawned: %s id=%d team=%d class=%d" % [
			bot_name,
			bot_id,
			bot_team,
			class_id
		]
	)

func _configure_bot(bot_id: int, class_id: int) -> void:
	if not players.has(bot_id):
		return

	var bot: Node3D = players[bot_id] as Node3D
	if bot == null:
		return

	bot.set("is_bot", true)
	bot.set("player_class", class_id)
	var squad_role: int = posmod(bot_id, 4)
	bot.set("bot_squad_role", squad_role)
	bot.set("bot_role_initialized", true)
	bot.call("server_apply_class", class_id)

func bot_squad_id(bot: Node3D) -> int:
	if bot == null:
		return 0
	return SquadCoordinatorScript.squad_id(
		int(bot.get("peer_id"))
	)

func _squad_key(team_id: int, squad_id: int) -> String:
	return "%d:%d" % [team_id, squad_id]

func bot_squad_order(bot: Node3D) -> String:
	if bot == null:
		return "REGROUP"
	return SquadCoordinatorScript.order_name(
		int(bot.get("team")),
		objective_stage,
		dynamite_armed,
		command_post_control
	)

func squad_order_text(team_id: int) -> String:
	return SquadCoordinatorScript.order_name(
		team_id,
		objective_stage,
		dynamite_armed,
		command_post_control
	)

func _valid_shared_target(
	target_id: int,
	observer_team: int
) -> Node3D:
	if not players.has(target_id):
		return null
	var target: Node3D = players[target_id] as Node3D
	if target == null:
		return null
	if int(target.get("team")) == observer_team:
		return null
	if not bool(target.get("alive")):
		return null
	if bool(target.get("downed")):
		return null
	return target

func report_squad_enemy(
	observer: Node3D,
	target: Node3D
) -> void:
	if observer == null or target == null:
		return
	var team_id: int = int(observer.get("team"))
	var squad_id: int = bot_squad_id(observer)
	var key: String = _squad_key(team_id, squad_id)
	squad_shared_targets[key] = {
		"target_id": int(target.get("peer_id")),
		"expires_ms": Time.get_ticks_msec() + 2800
	}

func bot_shared_enemy(observer: Node3D) -> Node3D:
	if observer == null:
		return null

	var now: int = Time.get_ticks_msec()
	if now >= squad_claim_reset_ms:
		squad_target_claims.clear()
		squad_claim_reset_ms = now + 900

	var team_id: int = int(observer.get("team"))
	var squad_id: int = bot_squad_id(observer)
	var key: String = _squad_key(team_id, squad_id)

	if squad_shared_targets.has(key):
		var shared: Dictionary = Dictionary(
			squad_shared_targets[key]
		)
		if now <= int(shared.get("expires_ms", 0)):
			var shared_target: Node3D = _valid_shared_target(
				int(shared.get("target_id", -1)),
				team_id
			)
			if shared_target != null:
				return shared_target
		squad_shared_targets.erase(key)

	var best: Node3D = null
	var best_score := -INF
	for candidate_value in players.values():
		var candidate: Node3D = candidate_value as Node3D
		if candidate == null or candidate == observer:
			continue
		if int(candidate.get("team")) == team_id:
			continue
		if not bool(candidate.get("alive")):
			continue
		if bool(candidate.get("downed")):
			continue

		var candidate_id: int = int(candidate.get("peer_id"))
		var claimed_count: int = int(
			squad_target_claims.get(candidate_id, 0)
		)
		var score: float = SquadCoordinatorScript.target_score(
			observer,
			candidate,
			claimed_count
		)
		if score > best_score:
			best_score = score
			best = candidate

	if best != null:
		var best_id: int = int(best.get("peer_id"))
		squad_target_claims[best_id] = (
			int(squad_target_claims.get(best_id, 0)) + 1
		)
		report_squad_enemy(observer, best)
	return best

func bot_squad_leader(bot: Node3D) -> Node3D:
	if bot == null:
		return null
	var team_id: int = int(bot.get("team"))
	var squad_id: int = bot_squad_id(bot)
	var best: Node3D = null
	var best_id := 2147483647

	for candidate_value in players.values():
		var candidate: Node3D = candidate_value as Node3D
		if candidate == null:
			continue
		if int(candidate.get("team")) != team_id:
			continue
		if bot_squad_id(candidate) != squad_id:
			continue
		if not bool(candidate.get("alive")):
			continue
		if bool(candidate.get("downed")):
			continue
		var candidate_id: int = int(candidate.get("peer_id"))
		if candidate_id < best_id:
			best_id = candidate_id
			best = candidate
	return best

func bot_squad_support_goal(
	bot: Node3D,
	class_id: int
) -> Variant:
	if bot == null:
		return null

	var team_id: int = int(bot.get("team"))
	var squad_id: int = bot_squad_id(bot)
	var escort: Node3D = null

	for candidate_value in players.values():
		var candidate: Node3D = candidate_value as Node3D
		if candidate == null or candidate == bot:
			continue
		if int(candidate.get("team")) != team_id:
			continue
		if bot_squad_id(candidate) != squad_id:
			continue
		if not bool(candidate.get("alive")):
			continue
		if bool(candidate.get("downed")):
			continue
		if int(candidate.get("player_class")) == 2:
			escort = candidate
			break

	if escort == null:
		escort = bot_squad_leader(bot)
	if escort == null or escort == bot:
		return null

	var forward: Vector3 = -escort.global_transform.basis.z
	var offset: Vector3 = SquadCoordinatorScript.formation_offset(
		int(bot.get("peer_id")),
		int(bot.get("bot_squad_role")),
		forward
	)

	if class_id == 1:
		offset *= 0.72
	elif class_id == 3:
		offset *= 1.20

	var support_goal: Vector3 = escort.global_position + offset
	if support_goal.distance_to(bot.global_position) < 1.25:
		return null
	if escort.velocity.length() < 0.10:
		var objective_goal: Vector3 = bot_goal_position(bot)
		if objective_goal.distance_to(bot.global_position) > 5.0:
			return objective_goal
	return support_goal

func bot_tactical_anchor(
	bot: Node3D,
	class_id: int,
	squad_role: int
) -> Vector3:
	if bot == null:
		return Vector3.ZERO

	return TacticalDirectorScript.tactical_anchor(
		bot,
		class_id,
		squad_role,
		objective_stage,
		bot_goal_position(bot)
	)

func bot_cover_position(
	bot: Node3D,
	threat_position: Vector3
) -> Vector3:
	return TacticalDirectorScript.cover_position(
		bot,
		threat_position
	)


func bot_goal_position(bot: Node3D) -> Vector3:
	if bot == null:
		return Vector3.ZERO

	var bot_team: int = int(bot.get("team"))
	var bot_id: int = int(bot.get("peer_id"))
	var patrol_variant: int = posmod(bot_id, 4)
	var lateral_offsets: Array[float] = [-6.0, -2.0, 2.0, 6.0]
	var lateral: float = lateral_offsets[patrol_variant]

	if (
		objective_stage >= 1
		and command_post_control != bot_team
	):
		var command_post: Node3D = _command_post_node()
		if command_post != null:
			return command_post.global_position + Vector3(
				0.0,
				0.0,
				lateral * 0.28
			)

	if bot_team == 0:
		if objective_stage == 0:
			var build_site: Node3D = get_node_or_null(
				"BridgeBuildSite"
			) as Node3D
			if build_site != null:
				return build_site.global_position + Vector3(
					-2.0,
					0.0,
					lateral * 0.35
				)

		var objective: Node3D = get_node_or_null(
			"Objective"
		) as Node3D
		if objective != null:
			return objective.global_position + Vector3(
				-3.0,
				0.0,
				lateral * 0.45
			)

		return Vector3(6.0, 1.0, lateral)

	if dynamite_armed:
		var defense_objective: Node3D = get_node_or_null(
			"Objective"
		) as Node3D
		if defense_objective != null:
			return defense_objective.global_position + Vector3(
				3.0,
				0.0,
				lateral * 0.45
			)

	if objective_stage == 0:
		return Vector3(-2.0, 1.0, lateral)

	return Vector3(7.0, 1.0, lateral)

func nearest_enemy(from_player: Node3D) -> Node3D:
	var best: Node3D = null
	var best_distance: float = INF
	var from_team: int = int(from_player.get("team"))

	for candidate_value in players.values():
		var candidate: Node3D = candidate_value as Node3D
		if candidate == null or candidate == from_player:
			continue

		if int(candidate.get("team")) == from_team:
			continue
		if not bool(candidate.get("alive")) or bool(candidate.get("downed")):
			continue

		var distance: float = from_player.global_position.distance_to(
			candidate.global_position
		)
		if distance < best_distance:
			best = candidate
			best_distance = distance

	return best

func nearest_downed_teammate(from_player: Node3D) -> Node3D:
	var best: Node3D = null
	var best_distance: float = INF
	var from_team: int = int(from_player.get("team"))

	for candidate_value in players.values():
		var candidate: Node3D = candidate_value as Node3D
		if candidate == null or candidate == from_player:
			continue

		if int(candidate.get("team")) != from_team:
			continue
		if not bool(candidate.get("alive")) or not bool(candidate.get("downed")):
			continue

		var distance: float = from_player.global_position.distance_to(
			candidate.global_position
		)
		if distance < best_distance:
			best = candidate
			best_distance = distance

	return best

func _reset_round() -> void:
	hide_round_results.rpc()
	match_over = false
	match_time_remaining = MATCH_LENGTH_SECONDS
	spawn_wave_remaining = SPAWN_WAVE_SECONDS
	objective_health = 100
	attacker_tickets = INITIAL_TEAM_TICKETS
	defender_tickets = INITIAL_TEAM_TICKETS
	command_post_control = -1
	command_post_progress = 0.0
	command_post_contested = false
	supply_depot_control = -1
	supply_depot_progress = 0.0
	supply_depot_contested = false
	supply_depot_ticket_accumulator = 0.0
	sector_ticket_accumulator = 0.0
	for sector_name_value in sector_positions.keys():
		var sector_name: String = str(sector_name_value)
		sector_control[sector_name] = -1
		sector_progress[sector_name] = 0.0
		sector_contested[sector_name] = false
	overtime_active = false
	atmosphere_elapsed = 0.0

	for rally_team in rally_points.keys():
		remove_rally_point(int(rally_team))
	objective_stage = 0
	squad_shared_targets.clear()
	squad_target_claims.clear()
	squad_order_revision += 1
	bridge_progress = 0
	defuse_progress = 0
	dynamite_armed = false
	dynamite_remaining = 0.0
	round_restart_remaining = 0.0

	for grenade_value in grenades.values():
		var grenade: Node = grenade_value as Node
		if grenade != null:
			grenade.queue_free()
	grenades.clear()

	for constructible_value in constructibles.values():
		var constructible: Node = constructible_value as Node
		if constructible != null:
			constructible.queue_free()
	constructibles.clear()
	engineer_constructibles.clear()

	var smoke_values: Array = smoke_clouds.values()
	smoke_clouds.clear()
	for smoke_value in smoke_values:
		if smoke_value == null or not is_instance_valid(smoke_value):
			continue
		var smoke_node: Node = smoke_value as Node
		if (
			smoke_node != null
			and not smoke_node.is_queued_for_deletion()
		):
			smoke_node.queue_free()

	var beacon_values: Array = sensor_beacons.values()
	sensor_beacons.clear()
	for beacon_value in beacon_values:
		if beacon_value == null or not is_instance_valid(beacon_value):
			continue
		var beacon_node: Node = beacon_value as Node
		if (
			beacon_node != null
			and not beacon_node.is_queued_for_deletion()
		):
			beacon_node.queue_free()
	pending_artillery.clear()
	_reset_destructible_cover()

	var bridge: Node = get_node_or_null("ConstructedBridge")
	if bridge:
		bridge.visible = false
		bridge.process_mode = Node.PROCESS_MODE_DISABLED

	for player_value in players.values():
		var player: Node3D = player_value as Node3D
		if player == null:
			continue
		player.set("kills", 0)
		player.set("deaths", 0)
		player.set("assists", 0)
		player.set("objective_points", 0)
		player.set("round_xp", 0)
		player.call(
			"server_force_respawn",
			_get_spawn(
				int(player.get("team")),
				int(player.get("peer_id"))
			)
		)

	push_kill_feed.rpc("New round started")
	announce.rpc("ROUND START · Secure the bridge and command post")

func _run_structure_collision_audit() -> void:
	if DisplayServer.get_name() == "headless":
		return

	structure_collision_report = (
		StructureCollisionAuditorScript.audit_and_repair(self)
	)
	print(
		"Structure collision audit: %s"
		% structure_collision_report
	)

func structure_collision_status_text() -> String:
	if structure_collision_report.is_empty():
		return "Structure collision audit has not run."
	return (
		"STRUCTURE COLLISION\n"
		+ "Scanned %d · Structural %d\n"
		+ "Protected %d · Trimesh %d\n"
		+ "Box fallback %d · Failed %d"
	) % [
		int(structure_collision_report.get("scanned_meshes", 0)),
		int(structure_collision_report.get("structural_meshes", 0)),
		int(structure_collision_report.get("already_protected", 0)),
		int(structure_collision_report.get("trimesh_generated", 0)),
		int(structure_collision_report.get("box_fallbacks", 0)),
		int(structure_collision_report.get("failed", 0))
	]

func _build_world() -> void:
	var env := WorldEnvironment.new()
	battlefield_environment = Environment.new()
	battlefield_environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.08, 0.16, 0.25)
	sky_material.sky_horizon_color = Color(0.56, 0.63, 0.68)
	sky_material.ground_bottom_color = Color(0.08, 0.09, 0.08)
	sky_material.ground_horizon_color = Color(0.38, 0.38, 0.34)
	sky_material.sun_angle_max = 18.0
	sky.sky_material = sky_material
	battlefield_environment.sky = sky
	battlefield_environment.background_energy_multiplier = 0.85
	battlefield_environment.ambient_light_source = (
		Environment.AMBIENT_SOURCE_COLOR
	)
	battlefield_environment.ambient_light_color = Color(0.7, 0.75, 0.8)
	battlefield_environment.ambient_light_energy = 0.92
	battlefield_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	battlefield_environment.fog_enabled = true
	battlefield_environment.fog_light_color = Color(0.52, 0.57, 0.60)
	battlefield_environment.fog_light_energy = 0.65
	battlefield_environment.fog_density = 0.008
	battlefield_environment.volumetric_fog_enabled = true
	battlefield_environment.volumetric_fog_density = 0.018
	battlefield_environment.volumetric_fog_length = 70.0
	battlefield_environment.glow_enabled = true
	battlefield_environment.glow_intensity = 0.65
	env.environment = battlefield_environment
	add_child(env)

	battlefield_sun = DirectionalLight3D.new()
	battlefield_sun.rotation_degrees = Vector3(-55, -35, 0)
	battlefield_sun.shadow_enabled = true
	battlefield_sun.light_energy = 1.28
	battlefield_sun.shadow_bias = 0.035
	battlefield_sun.shadow_normal_bias = 1.15
	battlefield_sun.directional_shadow_max_distance = 90.0
	add_child(battlefield_sun)

	_make_static_box("GroundWest", Vector3(-11, -0.5, 0), Vector3(18, 1, 24), Color(0.22, 0.27, 0.22))
	_make_static_box("GroundEast", Vector3(11, -0.5, 0), Vector3(18, 1, 24), Color(0.22, 0.27, 0.22))
	_make_static_box("River", Vector3(0, -1.0, 0), Vector3(4, 0.4, 24), Color(0.08, 0.24, 0.34))
	_make_static_box("WallNorth", Vector3(0, 2, -12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	_make_static_box("WallSouth", Vector3(0, 2, 12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	_make_static_box("WestCover", Vector3(-7, 1, -5), Vector3(3, 2, 3), Color(0.32, 0.28, 0.22))
	_make_static_box("EastCover", Vector3(6, 1, 5), Vector3(3, 2, 3), Color(0.32, 0.28, 0.22))

	# Expanded side routes and elevation.
	_make_static_box(
		"WestLaneCoverA",
		Vector3(-12.0, 0.75, 7.2),
		Vector3(2.5, 1.5, 3.0),
		Color(0.30, 0.27, 0.21)
	)
	_make_static_box(
		"WestLaneCoverB",
		Vector3(-7.0, 0.65, 8.3),
		Vector3(3.0, 1.3, 2.0),
		Color(0.28, 0.25, 0.20)
	)
	_make_static_box(
		"EastLaneCoverA",
		Vector3(12.0, 0.75, -7.2),
		Vector3(2.5, 1.5, 3.0),
		Color(0.30, 0.27, 0.21)
	)
	_make_static_box(
		"EastLaneCoverB",
		Vector3(7.0, 0.65, -8.3),
		Vector3(3.0, 1.3, 2.0),
		Color(0.28, 0.25, 0.20)
	)
	_make_static_box(
		"WestRaisedPlatform",
		Vector3(-9.5, 1.0, 2.8),
		Vector3(5.0, 2.0, 3.0),
		Color(0.24, 0.23, 0.20)
	)
	_make_static_box(
		"EastRaisedPlatform",
		Vector3(9.5, 1.0, -2.8),
		Vector3(5.0, 2.0, 3.0),
		Color(0.24, 0.23, 0.20)
	)
	_make_static_box(
		"CenterNorthCover",
		Vector3(-2.8, 0.75, -7.0),
		Vector3(2.0, 1.5, 4.0),
		Color(0.34, 0.31, 0.25)
	)
	_make_static_box(
		"CenterSouthCover",
		Vector3(2.8, 0.75, 7.0),
		Vector3(2.0, 1.5, 4.0),
		Color(0.34, 0.31, 0.25)
	)

	_build_operation_black_river_expansion()
	_build_asset_based_village_pass()

	for sector_name_value in sector_positions.keys():
		var sector_name: String = str(sector_name_value)
		var sector_root := Node3D.new()
		sector_root.name = "Sector_%s" % sector_name.replace(" ", "_")
		sector_root.position = Vector3(
			sector_positions.get(sector_name, Vector3.ZERO)
		)
		add_child(sector_root)

		var ring := MeshInstance3D.new()
		var ring_mesh := CylinderMesh.new()
		ring_mesh.top_radius = SECTOR_CAPTURE_RADIUS
		ring_mesh.bottom_radius = SECTOR_CAPTURE_RADIUS
		ring_mesh.height = 0.08
		ring.mesh = ring_mesh
		ring.position.y = 0.06
		var ring_material := StandardMaterial3D.new()
		ring_material.transparency = (
			BaseMaterial3D.TRANSPARENCY_ALPHA
		)
		ring_material.albedo_color = Color(0.7, 0.7, 0.7, 0.16)
		ring_material.shading_mode = (
			BaseMaterial3D.SHADING_MODE_UNSHADED
		)
		ring.material_override = ring_material
		sector_root.add_child(ring)

		var marker := Label3D.new()
		marker.position = Vector3(0.0, 4.0, 0.0)
		marker.font_size = 26
		marker.outline_size = 10
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.fixed_size = false
		sector_root.add_child(marker)
		sector_markers[sector_name] = marker

		var light := OmniLight3D.new()
		light.position = Vector3(0.0, 2.2, 0.0)
		light.omni_range = 8.0
		light.light_energy = 1.6
		sector_root.add_child(light)
		sector_lights[sector_name] = light

	_build_asset_based_rail_and_fort_pass()
	_initialize_battlefield_particles()
	_build_breakable_environment()
	_build_high_fidelity_environment_pass()
	_build_wwii_detail_pass()
	_build_urban_realism_pass()
	_build_alley_detail_pass()
	_ensure_combat_effects_manager()
	_apply_wwii_material_library()
	_build_battlefield_atmosphere()
	_build_battlefield_dressing_pass()
	_build_combat_atmosphere_pass()
	_build_map_expansion_pass()
	_build_expanded_ground_collision()
	_build_structure_collision_pass()
	_validate_structure_collision_layout()

	# Combined-arms battlefield expansion.
	_make_static_box(
		"NorthObservationTower",
		Vector3(-5.5, 2.0, -10.0),
		Vector3(4.0, 4.0, 3.0),
		Color(0.24, 0.23, 0.21)
	)
	_make_static_box(
		"SouthObservationTower",
		Vector3(5.5, 2.0, 10.0),
		Vector3(4.0, 4.0, 3.0),
		Color(0.24, 0.23, 0.21)
	)
	_make_static_box(
		"NorthTrenchFloor",
		Vector3(-3.5, 0.15, -8.7),
		Vector3(8.0, 0.30, 2.2),
		Color(0.20, 0.18, 0.15)
	)
	_make_static_box(
		"SouthTrenchFloor",
		Vector3(3.5, 0.15, 8.7),
		Vector3(8.0, 0.30, 2.2),
		Color(0.20, 0.18, 0.15)
	)

	_create_destructible_cover(
		Vector3(-5.0, 0.0, -3.8),
		deg_to_rad(8.0),
		Vector3(3.4, 1.9, 0.75)
	)
	_create_destructible_cover(
		Vector3(4.8, 0.0, 3.8),
		deg_to_rad(-10.0),
		Vector3(3.4, 1.9, 0.75)
	)
	_create_destructible_cover(
		Vector3(-8.5, 0.0, 5.5),
		deg_to_rad(82.0),
		Vector3(3.0, 1.7, 0.70)
	)
	_create_destructible_cover(
		Vector3(8.5, 0.0, -5.5),
		deg_to_rad(98.0),
		Vector3(3.0, 1.7, 0.70)
	)

	_create_field_emplacement(
		0,
		0,
		Vector3(2.0, 0.0, -8.2),
		deg_to_rad(-90.0)
	)
	_create_field_emplacement(
		1,
		1,
		Vector3(8.0, 0.0, -8.2),
		deg_to_rad(90.0)
	)

	for foliage_data in [
		[Vector3(-12.5, 0.0, -4.5), 1.25],
		[Vector3(-10.0, 0.0, 9.0), 1.10],
		[Vector3(11.8, 0.0, 5.5), 1.35],
		[Vector3(13.0, 0.0, -8.5), 1.15],
		[Vector3(-6.5, 0.0, 11.5), 0.95],
		[Vector3(6.0, 0.0, -11.0), 1.05]
	]:
		_create_foliage_sprite(
			Vector3(foliage_data[0]),
			float(foliage_data[1])
		)

	for attacker_spawn in spawn_points[0]:
		_create_spawn_beam(Vector3(attacker_spawn), 0)
	for defender_spawn in spawn_points[1]:
		_create_spawn_beam(Vector3(defender_spawn), 1)

	_make_spawn_zone(
		"AttackersSpawnZone",
		Vector3(-15.0, 0.08, 0.0),
		Vector3(7.0, 0.12, 19.0),
		Color(0.12, 0.30, 0.85, 0.34)
	)
	_make_spawn_zone(
		"DefendersSpawnZone",
		Vector3(15.0, 0.08, 0.0),
		Vector3(7.0, 0.12, 19.0),
		Color(0.82, 0.16, 0.12, 0.34)
	)

	var supply_depot := Node3D.new()
	supply_depot.name = "SupplyDepot"
	supply_depot.position = Vector3(-8.2, 0.0, 7.8)
	add_child(supply_depot)

	_make_marker(
		supply_depot,
		Vector3(4.8, 0.14, 4.8),
		Color(0.52, 0.48, 0.24)
	)

	for crate_offset in [
		Vector3(-1.2, 0.45, 0.0),
		Vector3(1.2, 0.45, 0.0),
		Vector3(0.0, 0.45, 1.2)
	]:
		var crate := MeshInstance3D.new()
		var crate_mesh := BoxMesh.new()
		crate_mesh.size = Vector3(0.9, 0.9, 0.9)
		crate.mesh = crate_mesh
		crate.position = crate_offset
		var crate_material := StandardMaterial3D.new()
		crate_material.albedo_color = Color(0.44, 0.34, 0.16)
		crate_material.roughness = 0.92
		crate.material_override = crate_material
		supply_depot.add_child(crate)

	supply_depot_marker = Label3D.new()
	supply_depot_marker.position = Vector3(0.0, 2.7, 0.0)
	supply_depot_marker.font_size = 28
	supply_depot_marker.outline_size = 10
	supply_depot_marker.billboard = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	supply_depot_marker.fixed_size = false
	supply_depot.add_child(supply_depot_marker)

	supply_depot_progress_label = Label3D.new()
	supply_depot_progress_label.position = Vector3(0.0, 2.25, 0.0)
	supply_depot_progress_label.font_size = 21
	supply_depot_progress_label.outline_size = 8
	supply_depot_progress_label.billboard = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	supply_depot_progress_label.fixed_size = false
	supply_depot.add_child(supply_depot_progress_label)

	supply_depot_light = OmniLight3D.new()
	supply_depot_light.position = Vector3(0.0, 2.0, 0.0)
	supply_depot_light.omni_range = 7.0
	supply_depot_light.light_energy = 1.6
	supply_depot.add_child(supply_depot_light)

	var command_post := Node3D.new()
	command_post.name = "CommandPost"
	command_post.position = Vector3(5.0, 0.2, -8.0)
	add_child(command_post)

	_make_marker(
		command_post,
		Vector3(5.5, 0.16, 5.5),
		Color(0.42, 0.42, 0.46)
	)

	var radio_mesh := MeshInstance3D.new()
	var radio_box := BoxMesh.new()
	radio_box.size = Vector3(1.4, 1.7, 1.1)
	radio_mesh.mesh = radio_box
	radio_mesh.position = Vector3(0.0, 0.85, 0.0)
	var radio_material := StandardMaterial3D.new()
	radio_material.albedo_texture = tex_metal
	radio_material.albedo_color = Color(0.58, 0.60, 0.54)
	radio_material.metallic = 0.3
	radio_mesh.material_override = radio_material
	command_post.add_child(radio_mesh)

	command_post_marker = Label3D.new()
	command_post_marker.name = "CommandPostMarker"
	command_post_marker.position = Vector3(0.0, 3.0, 0.0)
	command_post_marker.font_size = 34
	command_post_marker.outline_size = 10
	command_post_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	command_post_marker.fixed_size = false
	command_post.add_child(command_post_marker)

	command_post_progress_label = Label3D.new()
	command_post_progress_label.position = Vector3(0.0, 2.55, 0.0)
	command_post_progress_label.font_size = 24
	command_post_progress_label.outline_size = 8
	command_post_progress_label.billboard = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	command_post_progress_label.fixed_size = false
	command_post.add_child(command_post_progress_label)

	command_post_beacon = OmniLight3D.new()
	command_post_beacon.position = Vector3(0.0, 2.0, 0.0)
	command_post_beacon.omni_range = 7.0
	command_post_beacon.light_energy = 1.8
	command_post.add_child(command_post_beacon)

	command_health_station = MeshInstance3D.new()
	command_health_station.name = "HealthStation"
	var health_station_mesh := BoxMesh.new()
	health_station_mesh.size = Vector3(1.25, 0.8, 1.0)
	command_health_station.mesh = health_station_mesh
	command_health_station.position = Vector3(-2.0, 0.4, 0.0)
	var health_station_material := StandardMaterial3D.new()
	health_station_material.albedo_color = Color(0.15, 0.62, 0.24)
	health_station_material.emission_enabled = true
	health_station_material.emission = Color(0.08, 0.35, 0.12)
	command_health_station.material_override = health_station_material
	command_health_station.visible = false
	command_post.add_child(command_health_station)

	command_ammo_station = MeshInstance3D.new()
	command_ammo_station.name = "AmmoStation"
	var ammo_station_mesh := BoxMesh.new()
	ammo_station_mesh.size = Vector3(1.25, 0.8, 1.0)
	command_ammo_station.mesh = ammo_station_mesh
	command_ammo_station.position = Vector3(2.0, 0.4, 0.0)
	var ammo_station_material := StandardMaterial3D.new()
	ammo_station_material.albedo_color = Color(0.76, 0.62, 0.14)
	ammo_station_material.emission_enabled = true
	ammo_station_material.emission = Color(0.38, 0.28, 0.05)
	command_ammo_station.material_override = ammo_station_material
	command_ammo_station.visible = false
	command_post.add_child(command_ammo_station)

	var build_site := Node3D.new()
	build_site.name = "BridgeBuildSite"
	build_site.position = Vector3(-1.2, 0.2, 0)
	add_child(build_site)
	bridge_beacon = OmniLight3D.new()
	bridge_beacon.position = Vector3(0.0, 2.2, 0.0)
	bridge_beacon.omni_range = 7.0
	bridge_beacon.light_color = Color(1.0, 0.72, 0.12)
	bridge_beacon.light_energy = 1.5
	build_site.add_child(bridge_beacon)
	_make_marker(build_site, Vector3(2.0, 0.25, 5.5), Color(0.85, 0.72, 0.18))

	var bridge := StaticBody3D.new()
	bridge.name = "ConstructedBridge"
	bridge.position = Vector3(0, 0.05, 0)
	bridge.visible = false
	bridge.process_mode = Node.PROCESS_MODE_DISABLED
	var bridge_mesh_instance := MeshInstance3D.new()
	var bridge_mesh := BoxMesh.new()
	bridge_mesh.size = Vector3(5, 0.35, 5.5)
	bridge_mesh_instance.mesh = bridge_mesh
	var bridge_material := StandardMaterial3D.new()
	bridge_material.albedo_color = Color(0.30, 0.18, 0.08)
	bridge_mesh_instance.material_override = bridge_material
	bridge.add_child(bridge_mesh_instance)
	var bridge_collision := CollisionShape3D.new()
	var bridge_shape := BoxShape3D.new()
	bridge_shape.size = Vector3(5, 0.35, 5.5)
	bridge_collision.shape = bridge_shape
	bridge.add_child(bridge_collision)
	add_child(bridge)

	var objective := StaticBody3D.new()
	objective.name = "Objective"
	objective.position = Vector3(13, 1.5, 0)
	var mesh_instance := MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(4, 3, 7)
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.16, 0.12)
	mesh_instance.material_override = mat
	objective.add_child(mesh_instance)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(4, 3, 7)
	collision.shape = shape
	objective.add_child(collision)
	add_child(objective)
	bunker_beacon = OmniLight3D.new()
	bunker_beacon.position = Vector3(0.0, 2.4, 0.0)
	bunker_beacon.omni_range = 8.0
	bunker_beacon.light_color = Color(1.0, 0.22, 0.08)
	bunker_beacon.light_energy = 1.5
	objective.add_child(bunker_beacon)

	objective_marker = Label3D.new()
	objective_marker.name = "ObjectiveMarker"
	objective_marker.position = Vector3(13.0, 4.25, 0.0)
	objective_marker.font_size = 42
	objective_marker.outline_size = 12
	objective_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	objective_marker.fixed_size = false
	objective_marker.no_depth_test = false
	add_child(objective_marker)

	objective_progress_label = Label3D.new()
	objective_progress_label.name = "ObjectiveProgress"
	objective_progress_label.position = Vector3(13.0, 3.7, 0.0)
	objective_progress_label.font_size = 28
	objective_progress_label.outline_size = 10
	objective_progress_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	objective_progress_label.fixed_size = false
	add_child(objective_progress_label)

	dynamite_model = MeshInstance3D.new()
	dynamite_model.name = "DynamiteModel"
	var dynamite_mesh := BoxMesh.new()
	dynamite_mesh.size = Vector3(0.65, 0.28, 0.30)
	dynamite_model.mesh = dynamite_mesh
	dynamite_model.position = Vector3(10.85, 1.45, 0.0)
	var dynamite_material := StandardMaterial3D.new()
	dynamite_material.albedo_color = Color(0.65, 0.10, 0.07)
	dynamite_material.emission_enabled = true
	dynamite_material.emission = Color(0.42, 0.03, 0.02)
	dynamite_model.material_override = dynamite_material
	dynamite_model.visible = false
	add_child(dynamite_model)

	dynamite_light = OmniLight3D.new()
	dynamite_light.name = "DynamiteLight"
	dynamite_light.position = Vector3(10.85, 1.55, 0.0)
	dynamite_light.light_color = Color(1.0, 0.10, 0.04)
	dynamite_light.omni_range = 4.0
	dynamite_light.light_energy = 2.3
	dynamite_light.visible = false
	add_child(dynamite_light)
	call_deferred("_run_structure_collision_audit")

func _make_spawn_zone(
	zone_name: String,
	zone_position: Vector3,
	zone_size: Vector3,
	zone_color: Color
) -> void:
	var zone := MeshInstance3D.new()
	zone.name = zone_name
	zone.position = zone_position

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = zone_size
	zone.mesh = mesh

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = zone_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(
		zone_color.r * 0.25,
		zone_color.g * 0.25,
		zone_color.b * 0.25
	)
	zone.material_override = material
	add_child(zone)

func _make_marker(parent: Node3D, size: Vector3, color: Color) -> void:
	var marker := MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	marker.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.35
	material.emission_enabled = true
	material.emission = color * 0.2
	marker.material_override = material
	parent.add_child(marker)

func _make_static_box(
	node_name: String,
	pos: Vector3,
	size: Vector3,
	color: Color
) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var mesh_instance := MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	if (
		"Cover" in node_name
		or "Tower" in node_name
		or "Trench" in node_name
		or "Platform" in node_name
	):
		material.albedo_texture = tex_metal
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
