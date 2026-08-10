extends RefCounted
class_name RealAssetAdapter

static func adapt_character(
	model: Node3D,
	team_id: int = -1
) -> Dictionary:
	var report := {
		"valid": false,
		"height_before": 0.0,
		"height_after": 0.0,
		"scale_multiplier": 1.0,
		"ground_offset": 0.0,
		"skeletons": 0,
		"animations": 0,
		"socket": "",
		"materials_adjusted": 0,
		"team_materials_adjusted": 0
	}
	if model == null:
		return report

	var before := _bounds(model)
	var height := before.size.y
	report["height_before"] = height

	if height > 0.01:
		var target_height := 1.88
		var multiplier := clampf(target_height / height, 0.01, 100.0)
		model.scale *= Vector3.ONE * multiplier
		report["scale_multiplier"] = multiplier

	var after_scale := _bounds(model)
	if after_scale.size.y > 0.01:
		var bottom := after_scale.position.y
		model.position.y -= bottom
		report["ground_offset"] = -bottom

	var final_bounds := _bounds(model)
	report["height_after"] = final_bounds.size.y
	report["skeletons"] = model.find_children(
		"*", "Skeleton3D", true, false
	).size()

	var animation_count := 0
	for value in model.find_children(
		"*", "AnimationPlayer", true, false
	):
		var animation_player := value as AnimationPlayer
		animation_count += animation_player.get_animation_list().size()
	report["animations"] = animation_count

	var socket := find_character_socket(model)
	if socket != null:
		report["socket"] = socket.name

	report["materials_adjusted"] = _clean_materials(model, false)
	report["team_materials_adjusted"] = _apply_team_surface_policy(
		model,
		team_id
	)
	report["valid"] = (
		final_bounds.size.y >= 1.35
		and final_bounds.size.y <= 2.30
		and model.find_children(
			"*",
			"MeshInstance3D",
			true,
			false
		).size() > 0
	)
	return report

static func adapt_weapon(
	model: Node3D,
	target_length: float
) -> Dictionary:
	var report := {
		"valid": false,
		"size_before": Vector3.ZERO,
		"size_after": Vector3.ZERO,
		"scale_multiplier": 1.0,
		"materials_adjusted": 0
	}
	if model == null:
		return report
	var before := _bounds(model)
	report["size_before"] = before.size
	var longest := maxf(before.size.x, maxf(before.size.y, before.size.z))
	if longest > 0.001 and target_length > 0.01:
		var multiplier := clampf(target_length / longest, 0.001, 1000.0)
		model.scale *= Vector3.ONE * multiplier
		report["scale_multiplier"] = multiplier
	var after := _bounds(model)
	report["size_after"] = after.size
	report["materials_adjusted"] = _clean_materials(model, false)
	report["valid"] = after.size.length() > 0.02
	return report

static func adapt_environment(
	model: Node3D,
	target_height: float = 0.0
) -> Dictionary:
	var report := {
		"valid": false,
		"height_before": 0.0,
		"height_after": 0.0,
		"scale_multiplier": 1.0,
		"ground_offset": 0.0,
		"materials_adjusted": 0
	}
	if model == null:
		return report

	var before := _bounds(model)
	report["height_before"] = before.size.y

	if target_height > 0.0 and before.size.y > 0.01:
		var multiplier := clampf(
			target_height / before.size.y,
			0.05,
			20.0
		)
		model.scale *= Vector3.ONE * multiplier
		report["scale_multiplier"] = multiplier

	var scaled := _bounds(model)
	if scaled.size.y > 0.01:
		var bottom := scaled.position.y
		model.position.y -= bottom
		report["ground_offset"] = -bottom

	var final_bounds := _bounds(model)
	report["height_after"] = final_bounds.size.y
	report["materials_adjusted"] = _clean_materials(model, true)
	report["valid"] = final_bounds.size.length() > 0.10
	return report

static func find_character_socket(model: Node3D) -> Node3D:
	if model == null:
		return null
	var exact_names := [
		"WeaponSocket",
		"weapon_socket",
		"RightHandSocket",
		"hand_r",
		"RightHand",
		"mixamorig:RightHand",
		"mixamorig_RightHand",
		"Skeleton_arm_joint_R__3_"
	]
	for socket_name in exact_names:
		var found := model.find_child(socket_name, true, false)
		if found is Node3D:
			return found as Node3D

	for value in model.find_children(
		"*", "BoneAttachment3D", true, false
	):
		var attachment := value as BoneAttachment3D
		var lower := attachment.name.to_lower()
		if "right" in lower and "hand" in lower:
			return attachment
	return null

static func animation_map(model: Node3D) -> Dictionary:
	var result := {}
	var player: AnimationPlayer
	for value in model.find_children(
		"*", "AnimationPlayer", true, false
	):
		player = value as AnimationPlayer
		break
	if player == null:
		return result

	for animation_name in player.get_animation_list():
		var lower := str(animation_name).to_lower()
		if "idle" in lower and not result.has("idle"):
			result["idle"] = animation_name
		elif ("walk" in lower or "move" in lower) and not result.has("walk"):
			result["walk"] = animation_name
		elif ("run" in lower or "sprint" in lower) and not result.has("run"):
			result["run"] = animation_name
		elif "crouch" in lower and not result.has("crouch"):
			result["crouch"] = animation_name
		elif ("fire" in lower or "shoot" in lower) and not result.has("fire"):
			result["fire"] = animation_name
		elif "reload" in lower and not result.has("reload"):
			result["reload"] = animation_name
		elif ("death" in lower or "dead" in lower) and not result.has("downed"):
			result["downed"] = animation_name
	return result

static func _apply_team_surface_policy(
	root: Node3D,
	team_id: int
) -> int:
	if team_id < 0 or team_id > 1:
		return 0
	var adjusted := 0
	var team_tint := (
		Color(0.66, 0.72, 0.42, 1.0)
		if team_id == 0
		else Color(0.58, 0.62, 0.55, 1.0)
	)
	for value in root.find_children(
		"*", "MeshInstance3D", true, false
	):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var source := mesh_instance.get_active_material(surface_index)
			if not source is StandardMaterial3D:
				continue
			var standard := source as StandardMaterial3D
			var identity := (
				mesh_instance.name
				+ " "
				+ standard.resource_name
			).to_lower()
			if not _is_uniform_surface(identity):
				continue
			var material := standard.duplicate() as StandardMaterial3D
			material.albedo_color *= team_tint
			material.metallic = 0.0
			material.roughness = maxf(material.roughness, 0.84)
			material.emission_enabled = false
			if material.normal_enabled:
				material.normal_scale = minf(material.normal_scale, 0.82)
			mesh_instance.set_surface_override_material(
				surface_index,
				material
			)
			adjusted += 1
	return adjusted

static func _is_uniform_surface(identity: String) -> bool:
	for token in [
		"uniform",
		"jacket",
		"shirt",
		"pants",
		"trouser",
		"sleeve",
		"fabric",
		"cloth",
		"body",
		"cesium_man",
		"cesium man"
	]:
		if token in identity:
			return true
	return false

static func _clean_materials(root: Node3D, environment_asset: bool) -> int:
	var adjusted := 0
	for value in root.find_children(
		"*", "MeshInstance3D", true, false
	):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var source := mesh_instance.get_active_material(surface_index)
			if not source is StandardMaterial3D:
				continue
			var material := (source as StandardMaterial3D).duplicate()
			material.roughness = maxf(
				material.roughness,
				0.72 if environment_asset else 0.58
			)
			if environment_asset:
				material.metallic = minf(material.metallic, 0.35)
			material.albedo_color = material.albedo_color.darkened(
				0.05
			)
			mesh_instance.set_surface_override_material(
				surface_index,
				material
			)
			adjusted += 1
	return adjusted

static func _bounds(root: Node3D) -> AABB:
	var result := AABB()
	var initialized := false
	var inverse := root.global_transform.affine_inverse()
	for value in root.find_children(
		"*", "MeshInstance3D", true, false
	):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var relative := inverse * mesh_instance.global_transform
		var transformed := relative * mesh_instance.get_aabb()
		if not initialized:
			result = transformed
			initialized = true
		else:
			result = result.merge(transformed)
	return result
