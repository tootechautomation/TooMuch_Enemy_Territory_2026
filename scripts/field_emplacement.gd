extends Node3D



func _multiplayer_session_active() -> bool:
	var peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if peer == null:
		return false
	return (
		peer.get_connection_status()
		!= MultiplayerPeer.CONNECTION_DISCONNECTED
	)

var emplacement_id := 0
var preferred_team := 0
var effective_team := -1
var range_meters := 31.0
var damage := 18
var fire_interval := 0.28
var fire_accumulator := 0.0
var rotation_speed := 3.0
var main_node: Node
var pivot: Node3D
var barrel_tip: Marker3D
var status_label: Label3D
var team_material: StandardMaterial3D

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

func configure(
	new_id: int,
	new_preferred_team: int,
	new_position: Vector3,
	new_rotation_y: float
) -> void:
	emplacement_id = new_id
	preferred_team = new_preferred_team
	global_position = new_position
	rotation.y = new_rotation_y
	main_node = get_parent()
	_build_visuals()
	_update_control_state()

func _build_visuals() -> void:
	var base_body := StaticBody3D.new()
	base_body.name = "EmplacementBase"
	add_child(base_body)

	var base_collision := CollisionShape3D.new()
	var base_shape := BoxShape3D.new()
	base_shape.size = Vector3(1.8, 1.0, 1.8)
	base_collision.shape = base_shape
	base_collision.position.y = 0.5
	base_body.add_child(base_collision)

	var base_mesh := MeshInstance3D.new()
	var base_box := BoxMesh.new()
	base_box.size = Vector3(1.8, 1.0, 1.8)
	base_mesh.mesh = base_box
	base_mesh.position.y = 0.5
	var base_material := StandardMaterial3D.new()
	base_material.albedo_color = Color(0.20, 0.21, 0.19)
	base_material.roughness = 0.82
	base_mesh.material_override = base_material
	base_body.add_child(base_mesh)

	pivot = Node3D.new()
	pivot.name = "TurretPivot"
	pivot.position = Vector3(0.0, 1.20, 0.0)
	add_child(pivot)

	var receiver := MeshInstance3D.new()
	var receiver_box := BoxMesh.new()
	receiver_box.size = Vector3(0.85, 0.48, 1.0)
	receiver.mesh = receiver_box
	receiver.position = Vector3(0.0, 0.0, -0.20)
	team_material = StandardMaterial3D.new()
	var optional_texture: Texture2D = _load_optional_texture(
		"res://assets/textures/metal_panel.png"
	)
	if optional_texture != null:
		team_material.albedo_texture = optional_texture
	team_material.albedo_color = Color(0.65, 0.65, 0.65)
	team_material.metallic = 0.45
	team_material.roughness = 0.42
	team_material.emission_enabled = true
	team_material.emission = Color(0.06, 0.06, 0.06)
	receiver.material_override = team_material
	pivot.add_child(receiver)

	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.075
	barrel_mesh.bottom_radius = 0.095
	barrel_mesh.height = 2.25
	barrel.mesh = barrel_mesh
	barrel.rotation_degrees.x = 90.0
	barrel.position = Vector3(0.0, 0.0, -1.45)
	barrel.material_override = team_material
	pivot.add_child(barrel)

	barrel_tip = Marker3D.new()
	barrel_tip.position = Vector3(0.0, 0.0, -2.65)
	pivot.add_child(barrel_tip)

	status_label = Label3D.new()
	status_label.position = Vector3(0.0, 2.45, 0.0)
	status_label.font_size = 23
	status_label.outline_size = 8
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.fixed_size = true
	add_child(status_label)

func _process(delta: float) -> void:
	if not _multiplayer_session_active():
		return
	_update_control_state()

	if not multiplayer.is_server():
		return
	if effective_team < 0:
		return
	if main_node == null:
		return

	fire_accumulator = maxf(0.0, fire_accumulator - delta)
	var target: Node3D = _nearest_visible_enemy()
	if target == null:
		return

	var target_position: Vector3 = (
		target.global_position + Vector3.UP * 0.75
	)
	var local_direction: Vector3 = target_position - pivot.global_position
	local_direction.y = 0.0
	if local_direction.length() > 0.01:
		var target_yaw: float = atan2(
			-local_direction.x,
			-local_direction.z
		)
		pivot.rotation.y = lerp_angle(
			pivot.rotation.y,
			target_yaw - rotation.y,
			clampf(delta * rotation_speed, 0.0, 1.0)
		)

	if fire_accumulator <= 0.0:
		fire_accumulator = fire_interval
		_fire_at(target, target_position)

func _update_control_state() -> void:
	if main_node == null:
		return

	var post_control: int = int(main_node.get("command_post_control"))
	effective_team = (
		post_control
		if post_control >= 0
		else -1
	)

	if status_label != null:
		if effective_team < 0:
			status_label.text = "EMPLACEMENT OFFLINE"
			status_label.modulate = Color(0.65, 0.65, 0.65)
		elif effective_team == 0:
			status_label.text = "ATTACKER AUTO-GUN"
			status_label.modulate = Color(0.22, 0.62, 1.0)
		else:
			status_label.text = "DEFENDER AUTO-GUN"
			status_label.modulate = Color(1.0, 0.28, 0.18)

	if team_material != null:
		var active_color := Color(0.36, 0.36, 0.36)
		if effective_team == 0:
			active_color = Color(0.12, 0.38, 0.85)
		elif effective_team == 1:
			active_color = Color(0.78, 0.16, 0.11)
		team_material.albedo_color = active_color
		team_material.emission = active_color * (
			0.35 if effective_team >= 0 else 0.08
		)

func _nearest_visible_enemy() -> Node3D:
	if main_node == null:
		return null

	var best: Node3D = null
	var best_distance := range_meters

	for player_value in main_node.players.values():
		var candidate: Node3D = player_value as Node3D
		if candidate == null:
			continue
		if not bool(candidate.get("alive")):
			continue
		if bool(candidate.get("downed")):
			continue
		if int(candidate.get("team")) == effective_team:
			continue

		var distance: float = global_position.distance_to(
			candidate.global_position
		)
		if distance >= best_distance:
			continue
		if not _has_line_of_sight(candidate):
			continue

		best = candidate
		best_distance = distance

	return best

func _has_line_of_sight(target: Node3D) -> bool:
	var start_position: Vector3 = barrel_tip.global_position
	var end_position: Vector3 = target.global_position + Vector3.UP * 0.75

	if (
		main_node != null
		and main_node.has_method("line_blocked_by_smoke")
		and bool(main_node.call(
			"line_blocked_by_smoke",
			start_position,
			end_position
		))
	):
		return false

	var query := PhysicsRayQueryParameters3D.create(
		start_position,
		end_position
	)
	query.exclude = [self]
	var hit: Dictionary = (
		get_world_3d().direct_space_state.intersect_ray(query)
	)
	return (
		hit.is_empty()
		or hit.get("collider") == target
	)

func _fire_at(target: Node3D, target_position: Vector3) -> void:
	if target == null:
		return

	target.call("server_take_damage", damage, 0)

	if (
		main_node != null
		and main_node.has_method("show_shot_effect")
	):
		main_node.show_shot_effect.rpc(
			barrel_tip.global_position,
			target_position,
			true,
			false
		)
