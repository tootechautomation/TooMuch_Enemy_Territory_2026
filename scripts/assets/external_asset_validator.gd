extends RefCounted
class_name ExternalAssetValidator

static func _bounds_for(root: Node3D) -> AABB:
	var result := AABB()
	var initialized := false
	for child in root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var local_aabb: AABB = mesh_instance.get_aabb()
		var transform_to_root: Transform3D = (
			root.global_transform.affine_inverse()
			* mesh_instance.global_transform
		)
		var transformed: AABB = transform_to_root * local_aabb
		if not initialized:
			result = transformed
			initialized = true
		else:
			result = result.merge(transformed)
	return result

static func validate_character(model: Node3D) -> Dictionary:
	var report := {
		"valid": true,
		"mesh_count": 0,
		"skeleton_count": 0,
		"animation_player_count": 0,
		"animation_count": 0,
		"weapon_socket": false,
		"height_m": 0.0,
		"warnings": []
	}
	if model == null:
		report["valid"] = false
		report["warnings"] = ["character model is null"]
		return report

	report["mesh_count"] = model.find_children(
		"*", "MeshInstance3D", true
	).size()
	report["skeleton_count"] = model.find_children(
		"*", "Skeleton3D", true
	).size()
	var animation_players := model.find_children(
		"*", "AnimationPlayer", true
	)
	report["animation_player_count"] = animation_players.size()
	var animation_count := 0
	for value in animation_players:
		var animation_player := value as AnimationPlayer
		animation_count += animation_player.get_animation_list().size()
	report["animation_count"] = animation_count

	var socket_names := [
		"WeaponSocket",
		"weapon_socket",
		"RightHandSocket",
		"hand_r"
	]
	for socket_name in socket_names:
		if model.find_child(socket_name, true, false) != null:
			report["weapon_socket"] = true
			break

	var bounds: AABB = _bounds_for(model)
	report["height_m"] = bounds.size.y

	var warnings: Array[String] = []
	if int(report["mesh_count"]) == 0:
		warnings.append("no MeshInstance3D nodes")
	if int(report["skeleton_count"]) == 0:
		warnings.append("no Skeleton3D; model is not rigged")
	if int(report["animation_count"]) == 0:
		warnings.append("no animations found")
	if not bool(report["weapon_socket"]):
		warnings.append("no recognized weapon socket")
	var height: float = float(report["height_m"])
	if height > 0.0 and (height < 1.4 or height > 2.3):
		warnings.append(
			"unexpected character height %.2fm" % height
	)
	report["warnings"] = warnings
	return report

static func validate_environment(model: Node3D) -> Dictionary:
	var report := {
		"valid": true,
		"mesh_count": 0,
		"static_body_count": 0,
		"collision_shape_count": 0,
		"size": Vector3.ZERO,
		"warnings": []
	}
	if model == null:
		report["valid"] = false
		report["warnings"] = ["environment model is null"]
		return report

	report["mesh_count"] = model.find_children(
		"*", "MeshInstance3D", true
	).size()
	report["static_body_count"] = model.find_children(
		"*", "StaticBody3D", true
	).size()
	report["collision_shape_count"] = model.find_children(
		"*", "CollisionShape3D", true
	).size()
	var bounds: AABB = _bounds_for(model)
	report["size"] = bounds.size

	var warnings: Array[String] = []
	if int(report["mesh_count"]) == 0:
		warnings.append("no MeshInstance3D nodes")
	if int(report["collision_shape_count"]) == 0:
		warnings.append("no authored collision")
	report["warnings"] = warnings
	return report
