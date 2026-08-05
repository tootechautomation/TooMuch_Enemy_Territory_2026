extends Node

const PlayerScene = preload("res://scenes/player.tscn")
const PORT_DEFAULT := 27960
const MAX_CLIENTS := 32
const MATCH_LENGTH_SECONDS := 600.0
const SPAWN_WAVE_SECONDS := 10.0

var players: Dictionary = {}
var player_teams: Dictionary = {}
var player_names: Dictionary = {}
var spawn_points := {
	0: [Vector3(-12, 1, 0), Vector3(-12, 1, 4), Vector3(-12, 1, -4)],
	1: [Vector3(12, 1, 0), Vector3(12, 1, 4), Vector3(12, 1, -4)]
}
var next_team := 0
var objective_health := 100
var match_time_remaining := MATCH_LENGTH_SECONDS
var spawn_wave_remaining := SPAWN_WAVE_SECONDS
var match_over := false
var status_label: Label

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
	broadcast_match_state.rpc(match_time_remaining, spawn_wave_remaining, objective_health)
	if match_time_remaining <= 0.0:
		_end_match("DEFENDERS WIN — time expired")

func _parse_command_line() -> void:
	var args := OS.get_cmdline_user_args()
	var is_server := "--server" in args or DisplayServer.get_name() == "headless"
	var port := PORT_DEFAULT
	var connect_address := ""
	for i in args.size():
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
		elif args[i] == "--connect" and i + 1 < args.size():
			connect_address = args[i + 1]
	if is_server:
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
	print("Frontline dedicated server listening on UDP %d" % port)

func join_server(address: String, port: int = PORT_DEFAULT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		push_error("Unable to connect: %s" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	if status_label:
		status_label.text = "Connecting to %s:%d..." % [address, port]

func _show_connection_menu() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(30, 30)
	panel.custom_minimum_size = Vector2(390, 190)
	canvas.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = "FRONTLINE: OBJECTIVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var address := LineEdit.new()
	address.placeholder_text = "Server IP"
	address.text = "127.0.0.1"
	box.add_child(address)
	var port := SpinBox.new()
	port.min_value = 1
	port.max_value = 65535
	port.value = PORT_DEFAULT
	box.add_child(port)
	var join := Button.new()
	join.text = "Join Server"
	box.add_child(join)
	status_label = Label.new()
	status_label.text = "WASD · Mouse · E objective · 1–5 class"
	box.add_child(status_label)
	join.pressed.connect(func():
		join_server(address.text.strip_edges(), int(port.value))
		panel.hide()
	)

func _on_connected_to_server() -> void:
	print("Connected as peer %d" % multiplayer.get_unique_id())

func _on_connection_failed() -> void:
	if status_label:
		status_label.text = "Connection failed."
	push_error("Connection failed")

func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	var team := next_team
	next_team = 1 - next_team
	player_teams[id] = team
	player_names[id] = "Player%d" % id
	for existing_id in players:
		var existing = players[existing_id]
		spawn_player.rpc_id(id, existing_id, existing.team, existing.player_name, existing.global_position)
	spawn_player.rpc(id, team, player_names[id], _get_spawn(team, id))
	print("Peer %d joined team %d" % [id, team])

func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return
	remove_player.rpc(id)
	player_teams.erase(id)
	player_names.erase(id)
	print("Peer %d disconnected" % id)

@rpc("authority", "call_local", "reliable")
func spawn_player(peer_id: int, team: int, pname: String, spawn_position: Vector3) -> void:
	if players.has(peer_id):
		return
	var player = PlayerScene.instantiate()
	player.name = str(peer_id)
	player.peer_id = peer_id
	player.team = team
	player.player_name = pname
	player.position = spawn_position
	add_child(player)
	players[peer_id] = player

@rpc("authority", "call_local", "reliable")
func remove_player(peer_id: int) -> void:
	if players.has(peer_id):
		players[peer_id].queue_free()
		players.erase(peer_id)

func _get_spawn(team: int, peer_id: int) -> Vector3:
	var points: Array = spawn_points.get(team, spawn_points[0])
	return points[peer_id % points.size()]

func _respawn_wave() -> void:
	for peer_id in players:
		var player = players[peer_id]
		if not player.alive:
			player.server_respawn(_get_spawn(player.team, peer_id))

func damage_objective(amount: int, attacker_team: int) -> void:
	if not multiplayer.is_server() or match_over or attacker_team != 0:
		return
	objective_health = maxi(0, objective_health - amount)
	if objective_health <= 0:
		_end_match("ATTACKERS WIN — objective destroyed")

func _end_match(message: String) -> void:
	if match_over:
		return
	match_over = true
	announce.rpc(message)
	print(message)

@rpc("authority", "call_remote", "unreliable_ordered")
func broadcast_match_state(time_remaining: float, wave_remaining: float, health_remaining: int) -> void:
	match_time_remaining = time_remaining
	spawn_wave_remaining = wave_remaining
	objective_health = health_remaining

@rpc("authority", "call_local", "reliable")
func announce(message: String) -> void:
	print(message)
	if DisplayServer.get_name() == "headless":
		return
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = message
	label.position = Vector2(390, 50)
	label.add_theme_font_size_override("font_size", 28)
	layer.add_child(label)

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

	_make_static_box("Ground", Vector3(0, -0.5, 0), Vector3(40, 1, 24), Color(0.22, 0.27, 0.22))
	_make_static_box("WallNorth", Vector3(0, 2, -12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	_make_static_box("WallSouth", Vector3(0, 2, 12), Vector3(40, 4, 1), Color(0.35, 0.35, 0.38))
	for z in [-7.0, 0.0, 7.0]:
		_make_static_box("Cover", Vector3(0, 1, z), Vector3(2, 2, 4), Color(0.32, 0.28, 0.22))

	var objective := StaticBody3D.new()
	objective.name = "Objective"
	objective.position = Vector3(8, 1.5, 0)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(3, 3, 3)
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.16, 0.12)
	mesh_instance.material_override = mat
	objective.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3, 3, 3)
	collision.shape = shape
	objective.add_child(collision)
	add_child(objective)

func _make_static_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
