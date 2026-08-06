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
var smoke_puffs: Array[MeshInstance3D] = []

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
	for index in range(7):
		var puff := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = radius * randf_range(0.34, 0.62)
		sphere.height = sphere.radius * 1.65
		puff.mesh = sphere
		puff.position = Vector3(randf_range(-radius*0.55,radius*0.55),randf_range(radius*0.18,radius*0.72),randf_range(-radius*0.55,radius*0.55))
		var material := StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(randf_range(0.48,0.62),randf_range(0.50,0.64),randf_range(0.52,0.66),randf_range(0.34,0.52))
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		puff.material_override = material
		add_child(puff)
		smoke_puffs.append(puff)
	if not smoke_puffs.is_empty():
		cloud_mesh = smoke_puffs[0]

func _process(delta: float) -> void:
	if not _multiplayer_session_active():
		return
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	for index in smoke_puffs.size():
		var puff: MeshInstance3D = smoke_puffs[index]
		if puff == null:
			continue
		puff.rotation.y += delta * (0.08 + index * 0.015)
		puff.position.y += delta * (0.025 + index * 0.002)
		var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.0018 + index) * 0.045
		puff.scale = Vector3.ONE * pulse
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
