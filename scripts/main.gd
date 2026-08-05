extends Node

const PlayerScene = preload("res://scenes/player.tscn")
const SupplyPackScript = preload("res://scripts/supply_pack.gd")
const PORT_DEFAULT := 27960
const MAX_CLIENTS := 32
const ROUND_RESTART_SECONDS := 10.0
const BOT_PEER_ID_START := 10000
const MATCH_LENGTH_SECONDS := 600.0
const SPAWN_WAVE_SECONDS := 10.0
const DYNAMITE_FUSE_SECONDS := 8.0

var players: Dictionary = {}
var player_teams: Dictionary = {}
var player_names: Dictionary = {}
var supply_packs: Dictionary = {}
var next_supply_pack_id := 1
var spawn_points := {
	0: [Vector3(-12, 1, 0), Vector3(-12, 1, 4), Vector3(-12, 1, -4)],
	1: [Vector3(12, 1, 0), Vector3(12, 1, 4), Vector3(12, 1, -4)]
}
var next_team := 0
var desired_bot_count := 0
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
var kill_feed: Array[String] = []

func _ready() -> void:
	_build_world()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	_parse_command_line()

func _process(delta: float) -> void:
	if not multiplayer.is_server() or match_over:
		return
	match_time_remaining = maxf(0.0, match_time_remaining - delta)
	spawn_wave_remaining -= delta
	if spawn_wave_remaining <= 0.0:
		spawn_wave_remaining += SPAWN_WAVE_SECONDS
		_respawn_wave()
	if dynamite_armed:
		dynamite_remaining = maxf(0.0, dynamite_remaining - delta)
		if dynamite_remaining <= 0.0:
			dynamite_armed = false
			defuse_progress = 0
			damage_objective(100, 0)
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
		defuse_required
	)
	if match_time_remaining <= 0.0:
		_end_match("DEFENDERS WIN — time expired")

func _parse_command_line() -> void:
	var args := OS.get_cmdline_user_args()
	var is_server := "--server" in args or DisplayServer.get_name() == "headless"
	var port := PORT_DEFAULT
	var connect_address := ""
	for i in args.size():
		if args[i] == "--port" and i + 1 < args.size(): port = int(args[i + 1])
		elif args[i] == "--connect" and i + 1 < args.size(): connect_address = args[i + 1]
	if is_server: start_server(port)
	elif connect_address != "": join_server(connect_address, port)
	else: _show_connection_menu()

func start_server(port: int = PORT_DEFAULT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_CLIENTS)
	if err != OK:
		push_error("Unable to start server: %s" % error_string(err))
		get_tree().quit(1)
		return
	multiplayer.multiplayer_peer = peer
	print("Frontline dedicated server listening on UDP %d" % port)

func join_server(address: String, port: int = PORT_DEFAULT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		push_error("Unable to connect: %s" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	if status_label: status_label.text = "Connecting to %s:%d..." % [address, port]

func _show_connection_menu() -> void:
	var canvas := CanvasLayer.new(); add_child(canvas)
	var panel := PanelContainer.new(); panel.position = Vector2(30, 30); panel.custom_minimum_size = Vector2(420, 210); canvas.add_child(panel)
	var box := VBoxContainer.new(); panel.add_child(box)
	var title := Label.new(); title.text = "FRONTLINE: OBJECTIVE"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; box.add_child(title)
	var address := LineEdit.new(); address.placeholder_text = "Server IP"; address.text = "127.0.0.1"; box.add_child(address)
	var port := SpinBox.new(); port.min_value = 1; port.max_value = 65535; port.value = PORT_DEFAULT; box.add_child(port)
	var join := Button.new(); join.text = "Join Server"; box.add_child(join)
	status_label = Label.new(); status_label.text = "WASD · Mouse · E interact · Q ability · Tab scoreboard"; box.add_child(status_label)
	join.pressed.connect(func(): join_server(address.text.strip_edges(), int(port.value)); panel.hide())

func _on_connected_to_server() -> void: print("Connected as peer %d" % multiplayer.get_unique_id())
func _on_connection_failed() -> void:
	if status_label: status_label.text = "Connection failed."
	push_error("Connection failed")

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server(): return
	var team := next_team; next_team = 1 - next_team
	player_teams[id] = team; player_names[id] = "Player%d" % id
	for existing_id in players:
		var existing = players[existing_id]
		spawn_player.rpc_id(id, existing_id, existing.team, existing.player_name, existing.global_position)
	for pack in supply_packs.values(): spawn_supply_pack.rpc_id(id, pack.pack_id, pack.team, pack.pack_type, pack.amount, pack.global_position)
	spawn_player.rpc(id, team, player_names[id], _get_spawn(team, id))

func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server(): return
	remove_player.rpc(id); player_teams.erase(id); player_names.erase(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, team: int, pname: String, spawn_position: Vector3) -> void:
	if players.has(peer_id): return
	var player = PlayerScene.instantiate(); player.name = str(peer_id); player.peer_id = peer_id; player.team = team; player.player_name = pname; player.position = spawn_position
	add_child(player); players[peer_id] = player

@rpc("authority", "call_local", "reliable")
func remove_player(peer_id: int) -> void:
	if players.has(peer_id): players[peer_id].queue_free(); players.erase(peer_id)

func _get_spawn(team: int, peer_id: int) -> Vector3:
	var points: Array = spawn_points.get(team, spawn_points[0]); return points[peer_id % points.size()]

func _respawn_wave() -> void:
	for peer_id in players:
		var player = players[peer_id]
		if not player.alive: player.server_respawn(_get_spawn(player.team, peer_id))

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
			if bridge_progress >= bridge_required:
				objective_stage = 1
				var bridge := get_node_or_null("ConstructedBridge")
				if bridge:
					bridge.visible = true
					bridge.process_mode = Node.PROCESS_MODE_INHERIT
				push_kill_feed.rpc("%s constructed the bridge" % player_names.get(engineer_id, "Engineer"))
				engineer.add_xp(50, "bridge completed")
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
	push_kill_feed.rpc("%s armed the bunker charge" % player_names.get(engineer_id, "Engineer"))
	if players.has(engineer_id):
		players[engineer_id].add_xp(25, "charge armed")
	return true

func damage_objective(amount: int, attacker_team: int) -> void:
	if not multiplayer.is_server() or match_over or attacker_team != 0: return
	objective_health = maxi(0, objective_health - amount)
	if objective_health <= 0: _end_match("ATTACKERS WIN — objective destroyed")

func register_elimination(victim_id: int, attacker_id: int) -> void:
	if players.has(attacker_id) and attacker_id != victim_id:
		players[attacker_id].kills += 1
		players[attacker_id].add_xp(10, "elimination")
	push_kill_feed.rpc("%s eliminated %s" % [player_names.get(attacker_id, "World"), player_names.get(victim_id, "Player")])

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
	if match_over: return
	match_over = true; announce.rpc(message); print(message)

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
	required_defuse: int
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

	var bridge := get_node_or_null("ConstructedBridge")
	if bridge:
		bridge.visible = objective_stage >= 1

@rpc("authority", "call_local", "reliable")
func push_kill_feed(message: String) -> void:
	kill_feed.push_front(message)
	if kill_feed.size() > 5: kill_feed.resize(5)
	print(message)

@rpc("authority", "call_local", "reliable")
func announce(message: String) -> void:
	print(message)
	if DisplayServer.get_name() == "headless": return
	var layer := CanvasLayer.new(); add_child(layer)
	var label := Label.new(); label.text = message; label.position = Vector2(390, 50); label.add_theme_font_size_override("font_size", 28); layer.add_child(label)

func objective_status_text() -> String:
	if match_over:
		return "Round restarts in %.1fs" % round_restart_remaining
	if objective_stage == 0:
		return "Stage 1: Build bridge %d/%d" % [bridge_progress, bridge_required]
	if dynamite_armed:
		return "Stage 2: Charge %.1fs | Defuse %d/%d" % [dynamite_remaining, defuse_progress, defuse_required]
	return "Stage 2: Destroy bunker | Integrity %d%%" % objective_health

func scoreboard_text() -> String:
	var lines := ["SCOREBOARD", "Player          Team       K   D   XP   Rank       State"]
	for player in players.values():
		var state := "Down" if player.downed else ("Alive" if player.alive else "Dead")
		lines.append("%-15s %-10s %2d  %2d  %3d  %-10s %s" % [
			player.player_name,
			"Attackers" if player.team == 0 else "Defenders",
			player.kills,
			player.deaths,
			player.xp,
			player.rank_name(),
			state
		])
	return "\n".join(lines)


func _spawn_bot(index: int) -> void:
	if not multiplayer.is_server():
		return
	var bot_id := next_bot_peer_id
	next_bot_peer_id += 1
	var team := index % 2
	var class_id := index % 5
	_spawn_player.rpc(bot_id, team, "Bot%02d" % (index + 1))
	call_deferred("_configure_bot", bot_id, class_id)

func _configure_bot(bot_id: int, class_id: int) -> void:
	if not players.has(bot_id):
		return
	var bot = players[bot_id]
	bot.is_bot = true
	bot.player_class = class_id
	bot.server_apply_class(class_id)

func nearest_enemy(from_player: Node3D) -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for candidate in players.values():
		if candidate == from_player:
			continue
		if candidate.team == from_player.team or not candidate.alive or candidate.downed:
			continue
		var distance := from_player.global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best

func nearest_downed_teammate(from_player: Node3D) -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for candidate in players.values():
		if candidate == from_player:
			continue
		if candidate.team != from_player.team or not candidate.alive or not candidate.downed:
			continue
		var distance := from_player.global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best

func _reset_round() -> void:
	match_over = false
	match_time_remaining = MATCH_DURATION_SECONDS
	spawn_wave_remaining = SPAWN_WAVE_SECONDS
	objective_health = 100
	objective_stage = 0
	bridge_progress = 0
	defuse_progress = 0
	dynamite_armed = false
	dynamite_remaining = 0.0
	round_restart_remaining = 0.0
	pending_respawns.clear()

	var bridge := get_node_or_null("ConstructedBridge")
	if bridge:
		bridge.visible = false
		bridge.process_mode = Node.PROCESS_MODE_DISABLED

	for player in players.values():
		player.kills = 0
		player.deaths = 0
		player.server_force_respawn(_get_spawn(player.team, player.peer_id))

	push_kill_feed.rpc("New round started")

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.12, 0.16, 0.19)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.7, 0.75, 0.8)
	environment.ambient_light_energy = 0.75
	env.environment = environment
	add_child(env)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.shadow_enabled = true
	add_child(light)

	_make_static_box("GroundWest", Vector3(-11, -0.5, 0), Vector3(18, 1, 24), Color(0.22, 0.27, 0.22))
	_make_static_box("GroundEast", Vector3(11, -0.5, 0), Vector3(18, 1, 24), Color(0.22, 0.27, 0.22))
	_make_static_box("River", Vector3(0, -1.0, 0), Vector3(4, 0.4, 24), Color(0.08, 0.24, 0.34))
	_make_static_box("WallNorth", Vector3(0, 2, -12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	_make_static_box("WallSouth", Vector3(0, 2, 12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	_make_static_box("WestCover", Vector3(-7, 1, -5), Vector3(3, 2, 3), Color(0.32, 0.28, 0.22))
	_make_static_box("EastCover", Vector3(6, 1, 5), Vector3(3, 2, 3), Color(0.32, 0.28, 0.22))

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

func _make_static_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new(); body.name = node_name; body.position = pos
	var mesh_instance := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size = size; mesh_instance.mesh = mesh; var mat := StandardMaterial3D.new(); mat.albedo_color = color; mesh_instance.material_override = mat; body.add_child(mesh_instance)
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = size; collision.shape = shape; body.add_child(collision); add_child(body)
