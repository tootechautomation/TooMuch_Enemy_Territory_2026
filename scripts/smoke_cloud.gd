extends Node3D


func _multiplayer_session_active() -> bool:
	var peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if peer == null:
		return false
	return (
		peer.get_connection_status()
		!= MultiplayerPeer.CONNECTION_DISCONNECTED
	)

var smoke_id := 0
var team := 0
var lifetime_remaining := 12.0
var radius := 5.5
var cloud_mesh: MeshInstance3D

func configure(new_id: int, new_team: int, spawn_position: Vector3, duration: float, new_radius: float) -> void:
	smoke_id = new_id
	team = new_team
	global_position = spawn_position
	lifetime_remaining = duration
	radius = new_radius
	_build_visuals()

func _build_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return
	cloud_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 1.4
	cloud_mesh.mesh = sphere
	cloud_mesh.position.y = radius * 0.45
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.55, 0.58, 0.60, 0.62)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	cloud_mesh.material_override = material
	add_child(cloud_mesh)

func _process(delta: float) -> void:
	if not _multiplayer_session_active():
		return
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	if cloud_mesh != null:
		cloud_mesh.rotation.y += delta * 0.18
		var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.002) * 0.04
		cloud_mesh.scale = Vector3.ONE * pulse
	if lifetime_remaining <= 0.0:
		set_process(false)

		if multiplayer.is_server():
			var main_node: Node = get_parent()
			if main_node != null:
				main_node.call("server_remove_smoke", smoke_id)
			elif not is_queued_for_deletion():
				queue_free()
		elif not is_queued_for_deletion():
			queue_free()
