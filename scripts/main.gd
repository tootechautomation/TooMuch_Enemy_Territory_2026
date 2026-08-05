extends Node

const PlayerScene = preload("res://scenes/player.tscn")
const GrenadeScene = preload("res://scenes/grenade.tscn")
const SupplyPackScript = preload("res://scripts/supply_pack.gd")
const ConstructibleScript = preload("res://scripts/constructible.gd")
const SmokeCloudScript = preload("res://scripts/smoke_cloud.gd")
const SensorBeaconScript = preload("res://scripts/sensor_beacon.gd")
const FieldEmplacementScript = preload("res://scripts/field_emplacement.gd")
const DestructibleCoverScript = preload("res://scripts/destructible_cover.gd")
const PORT_DEFAULT := 27960
const MAX_CLIENTS := 32
const BUILD_VERSION := "3.4.4"
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

var tex_metal: Texture2D
var tex_objective: Texture2D
var tex_foliage: Texture2D

var players: Dictionary = {}
var player_teams: Dictionary = {}
var player_names: Dictionary = {}
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
		Vector3(-16.0, 1.0, 0.0),
		Vector3(-16.0, 1.0, 6.5),
		Vector3(-16.0, 1.0, -6.5),
		Vector3(-12.5, 1.0, 8.0),
		Vector3(-12.5, 1.0, -8.0)
	],
	1: [
		Vector3(16.0, 1.0, 0.0),
		Vector3(16.0, 1.0, 6.5),
		Vector3(16.0, 1.0, -6.5),
		Vector3(12.5, 1.0, 8.0),
		Vector3(12.5, 1.0, -8.0)
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
var battlefield_sun: DirectionalLight3D
var atmosphere_elapsed := 0.0
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
	if DisplayServer.get_name() != "headless":
		tex_metal = _load_optional_texture(
			"res://assets/textures/metal_panel.png"
		)
		tex_objective = _load_optional_texture(
			"res://assets/textures/objective_hazard.png"
		)
		tex_foliage = _load_optional_texture(
			"res://assets/textures/foliage_sprite.png"
		)

	_build_world()
	_build_round_results_ui()
	_update_objective_visuals()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	_parse_command_line()

func _process(delta: float) -> void:
	atmosphere_elapsed += delta
	_update_objective_visuals()
	_update_command_post_visuals()
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

	station_accumulator += delta
	if station_accumulator >= COMMAND_POST_STATION_INTERVAL:
		station_accumulator = 0.0
		_update_command_post_stations()

	snapshot_accumulator += delta
	if snapshot_accumulator >= SNAPSHOT_INTERVAL:
		snapshot_accumulator = 0.0
		_broadcast_player_snapshots()

	if match_over:
		round_restart_remaining = maxf(0.0, round_restart_remaining - delta)
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

func _show_connection_menu() -> void:
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

	connection_address = LineEdit.new()
	connection_address.placeholder_text = "Server IP"
	connection_address.text = "127.0.0.1"
	box.add_child(connection_address)

	connection_port = SpinBox.new()
	connection_port.min_value = 1
	connection_port.max_value = 65535
	connection_port.value = PORT_DEFAULT
	box.add_child(connection_port)

	connection_join_button = Button.new()
	connection_join_button.text = "Join Server"
	connection_join_button.pressed.connect(
		func() -> void:
			if connection_join_button != null:
				connection_join_button.disabled = true
			if status_label != null:
				status_label.text = "Connecting…"

			join_server(
				connection_address.text.strip_edges(),
				int(connection_port.value)
			)
	)
	box.add_child(connection_join_button)

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
			"Connection failed. Check the VPS IP, port 27960, "+
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
	marker.fixed_size = true
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
	marker.fixed_size = true
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
	var root := Node3D.new()
	root.position = target_position
	add_child(root)
	for offset in [Vector3.ZERO, Vector3(2.2,0,1.4), Vector3(-1.8,0,-1.9), Vector3(1.3,0,-2.4)]:
		var flash := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.8
		sphere.height = 1.6
		flash.mesh = sphere
		flash.position = offset + Vector3.UP * 0.5
		var material := StandardMaterial3D.new()
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
	capsule.radius = 0.45
	capsule.height = 1.8

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
	shape_query.margin = 0.03

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

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.42, 0.08, 0.8)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.25, 0.02)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = material
	add_child(flash)

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

func _end_match(message: String) -> void:
	if match_over:
		return

	match_over = true
	round_restart_remaining = ROUND_RESTART_SECONDS
	announce.rpc(message)
	show_round_results.rpc(
		message,
		scoreboard_text(),
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
	line_mesh.surface_add_vertex(start_position)
	line_mesh.surface_set_color(
		Color(1.0, 0.42, 0.08, 0.30)
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

	var impact := MeshInstance3D.new()
	var impact_mesh := SphereMesh.new()
	impact_mesh.radius = 0.07 if not headshot else 0.11
	impact_mesh.height = 0.14 if not headshot else 0.22
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
	timer.wait_time = 0.10
	timer.timeout.connect(effect_root.queue_free)
	effect_root.add_child(timer)
	timer.start()

@rpc("authority", "call_local", "reliable")
func push_kill_feed(message: String) -> void:
	kill_feed.push_front(message)
	if kill_feed.size() > 5: kill_feed.resize(5)
	print(message)

func _build_round_results_ui() -> void:
	if DisplayServer.get_name() == "headless":
		return

	round_results_layer = CanvasLayer.new()
	round_results_layer.layer = 40
	add_child(round_results_layer)

	round_results_panel = PanelContainer.new()
	round_results_panel.position = Vector2(300, 95)
	round_results_panel.custom_minimum_size = Vector2(680, 530)
	round_results_panel.visible = false
	round_results_layer.add_child(round_results_panel)

	round_results_label = Label.new()
	round_results_label.add_theme_font_size_override(
		"font_size",
		20
	)
	round_results_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	round_results_panel.add_child(round_results_label)

@rpc("authority", "call_local", "reliable")
func show_round_results(
	result_message: String,
	final_scoreboard: String,
	restart_seconds: float
) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if round_results_panel == null or round_results_label == null:
		return

	round_results_panel.visible = true
	round_results_label.text = (
		"%s\n\n%s\n\nNext round in %.0f seconds"
		% [
			result_message,
			final_scoreboard,
			restart_seconds
		]
	)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

@rpc("authority", "call_local", "reliable")
func hide_round_results() -> void:
	if round_results_panel != null:
		round_results_panel.visible = false

@rpc("authority", "call_local", "reliable")
func announce(message: String) -> void:
	print(message)
	if DisplayServer.get_name() == "headless": return
	var layer := CanvasLayer.new(); add_child(layer)
	var label := Label.new(); label.text = message; label.position = Vector2(390, 50); label.add_theme_font_size_override("font_size", 28); layer.add_child(label)

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
				guns_text,
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

func scoreboard_text() -> String:
	var class_names: Array[String] = [
		"Soldier",
		"Medic",
		"Engineer",
		"FieldOps",
		"Scout"
	]
	var lines: Array[String] = [
		"SCOREBOARD · Tickets ATK %d / DEF %d · Command Post %s" % [
			attacker_tickets,
			defender_tickets,
			(
				"Neutral"
				if command_post_control < 0
				else (
					"Attackers"
					if command_post_control == 0
					else "Defenders"
				)
			)
		],
		"Player          Team  Class      K   D   XP   Rank       Type   State"
	]

	var sorted_players: Array = players.values()
	sorted_players.sort_custom(
		func(a: Node3D, b: Node3D) -> bool:
			if int(a.get("team")) != int(b.get("team")):
				return int(a.get("team")) < int(b.get("team"))
			if int(a.get("kills")) != int(b.get("kills")):
				return int(a.get("kills")) > int(b.get("kills"))
			return int(a.get("xp")) > int(b.get("xp"))
	)

	for player_value in sorted_players:
		var player: Node3D = player_value as Node3D
		if player == null:
			continue

		var is_alive: bool = bool(player.get("alive"))
		var is_downed: bool = bool(player.get("downed"))
		var state: String = (
			"Down"
			if is_downed
			else ("Alive" if is_alive else "Dead")
		)
		var player_team: int = int(player.get("team"))
		var class_id: int = clampi(
			int(player.get("player_class")),
			0,
			class_names.size() - 1
		)
		var rank: String = str(player.call("rank_name"))
		var actor_type := (
			"BOT"
			if bool(player.get("is_bot"))
			else "HUMAN"
		)

		lines.append(
			"%-15s %-5s %-10s %2d  %2d  %3d  %-10s %-6s %s"
			% [
				str(player.get("player_name")),
				"ATK" if player_team == 0 else "DEF",
				class_names[class_id],
				int(player.get("kills")),
				int(player.get("deaths")),
				int(player.get("xp")),
				rank,
				actor_type,
				state
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
	bot.call("server_apply_class", class_id)

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
	overtime_active = false
	atmosphere_elapsed = 0.0
	objective_stage = 0
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
		player.call(
			"server_force_respawn",
			_get_spawn(
				int(player.get("team")),
				int(player.get("peer_id"))
			)
		)

	push_kill_feed.rpc("New round started")

func _build_world() -> void:
	var env := WorldEnvironment.new()
	battlefield_environment = Environment.new()
	battlefield_environment.background_mode = Environment.BG_COLOR
	battlefield_environment.background_color = Color(0.12, 0.16, 0.19)
	battlefield_environment.ambient_light_source = (
		Environment.AMBIENT_SOURCE_COLOR
	)
	battlefield_environment.ambient_light_color = Color(0.7, 0.75, 0.8)
	battlefield_environment.ambient_light_energy = 0.75
	env.environment = battlefield_environment
	add_child(env)

	battlefield_sun = DirectionalLight3D.new()
	battlefield_sun.rotation_degrees = Vector3(-55, -35, 0)
	battlefield_sun.shadow_enabled = true
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
	command_post_marker.fixed_size = true
	command_post.add_child(command_post_marker)

	command_post_progress_label = Label3D.new()
	command_post_progress_label.position = Vector3(0.0, 2.55, 0.0)
	command_post_progress_label.font_size = 24
	command_post_progress_label.outline_size = 8
	command_post_progress_label.billboard = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)
	command_post_progress_label.fixed_size = true
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
	var mesh := BoxMesh.new()
	mesh.size = Vector3(4, 3, 7)
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.16, 0.12)
	mesh_instance.material_override = mat
	objective.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4, 3, 7)
	collision.shape = shape
	objective.add_child(collision)
	add_child(objective)

	objective_marker = Label3D.new()
	objective_marker.name = "ObjectiveMarker"
	objective_marker.position = Vector3(13.0, 4.25, 0.0)
	objective_marker.font_size = 42
	objective_marker.outline_size = 12
	objective_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	objective_marker.fixed_size = true
	objective_marker.no_depth_test = false
	add_child(objective_marker)

	objective_progress_label = Label3D.new()
	objective_progress_label.name = "ObjectiveProgress"
	objective_progress_label.position = Vector3(13.0, 3.7, 0.0)
	objective_progress_label.font_size = 28
	objective_progress_label.outline_size = 10
	objective_progress_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	objective_progress_label.fixed_size = true
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


func _make_spawn_zone(
	zone_name: String,
	zone_position: Vector3,
	zone_size: Vector3,
	zone_color: Color
) -> void:
	var zone := MeshInstance3D.new()
	zone.name = zone_name
	zone.position = zone_position

	var mesh := BoxMesh.new()
	mesh.size = zone_size
	zone.mesh = mesh

	var material := StandardMaterial3D.new()
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
	var mesh := BoxMesh.new()
	mesh.size = size
	marker.mesh = mesh
	var material := StandardMaterial3D.new()
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
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh

	var material := StandardMaterial3D.new()
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

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
