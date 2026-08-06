extends Node3D

var rally_id := 0
var team := 0
var owner_id := 0
var lifetime_remaining := 45.0
var contested := false
var main_node: Node
var beacon: OmniLight3D
var status_label: Label3D

func configure(
	new_id: int,
	new_team: int,
	new_owner_id: int,
	spawn_position: Vector3,
	duration: float
) -> void:
	rally_id = new_id
	team = new_team
	owner_id = new_owner_id
	global_position = spawn_position
	lifetime_remaining = duration
	main_node = get_parent()
	_build_visuals()

func _build_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var base := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.72
	cylinder.bottom_radius = 0.90
	cylinder.height = 0.28
	base.mesh = cylinder
	base.position.y = 0.14

	var material := StandardMaterial3D.new()
	material.albedo_color = (
		Color(0.12, 0.42, 0.92)
		if team == 0
		else Color(0.90, 0.16, 0.10)
	)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.35
	base.material_override = material
	add_child(base)

	var mast := MeshInstance3D.new()
	var mast_mesh := CylinderMesh.new()
	mast_mesh.top_radius = 0.05
	mast_mesh.bottom_radius = 0.07
	mast_mesh.height = 2.2
	mast.mesh = mast_mesh
	mast.position.y = 1.15
	mast.material_override = material
	add_child(mast)

	status_label = Label3D.new()
	status_label.position = Vector3(0.0, 2.65, 0.0)
	status_label.font_size = 24
	status_label.outline_size = 9
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.fixed_size = true
	add_child(status_label)

	beacon = OmniLight3D.new()
	beacon.position = Vector3(0.0, 2.0, 0.0)
	beacon.omni_range = 6.0
	beacon.light_color = material.albedo_color
	beacon.light_energy = 1.8
	add_child(beacon)

	_update_visuals()

func _process(delta: float) -> void:
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)

	if beacon != null:
		beacon.light_energy = (
			1.5 + sin(Time.get_ticks_msec() * 0.008) * 0.65
		)

	if multiplayer.multiplayer_peer == null:
		return
	if (
		multiplayer.multiplayer_peer.get_connection_status()
		== MultiplayerPeer.CONNECTION_DISCONNECTED
	):
		return
	if not multiplayer.is_server():
		return

	if main_node != null:
		contested = bool(main_node.call(
			"is_rally_contested",
			team,
			global_position
		))
		sync_rally_state.rpc(
			lifetime_remaining,
			contested
		)

	if lifetime_remaining <= 0.0 and main_node != null:
		set_process(false)
		main_node.call("server_remove_rally_point", team)

@rpc("authority", "call_local", "unreliable")
func sync_rally_state(
	remaining: float,
	is_contested: bool
) -> void:
	lifetime_remaining = remaining
	contested = is_contested
	_update_visuals()

func _update_visuals() -> void:
	if status_label == null:
		return

	if contested:
		status_label.text = "RALLY CONTESTED"
		status_label.modulate = Color(1.0, 0.72, 0.10)
	else:
		status_label.text = "RALLY %.0fs" % lifetime_remaining
		status_label.modulate = (
			Color(0.25, 0.72, 1.0)
			if team == 0
			else Color(1.0, 0.32, 0.22)
		)
