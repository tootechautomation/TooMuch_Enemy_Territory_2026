extends Node3D
class_name FirstPersonArmsFallback

var player: Node
var weapon_view: Node3D
var root_armature: Node3D

var right_arm: Node3D
var left_arm: Node3D

var current_slot := 0
var pose_blend := 0.0
var sprint_blend := 0.0
var reload_blend := 0.0
var aim_blend := 0.0
var animation_time := 0.0


func initialize(owner_player: Node, view_root: Node3D) -> void:
	player = owner_player
	weapon_view = view_root

	if DisplayServer.get_name() == "headless":
		return
	if player == null or weapon_view == null:
		return

	call_deferred("_build_if_needed")


func _build_if_needed() -> void:
	if weapon_view == null:
		return

	# If a proper imported first-person rig appears later, do not stack this
	# procedural fallback on top of it.
	for child: Node in weapon_view.find_children("*", "", true):
		var key := child.name.to_lower()
		if (
			"firstpersonarm" in key
			or "fp_arm" in key
			or "viewarm" in key
			or "handsrig" in key
		):
			return

	root_armature = Node3D.new()
	root_armature.name = "FirstPersonArmsFallback_v916"
	weapon_view.add_child(root_armature)

	var sleeve_material := _sleeve_material()
	var skin_material := _skin_material()
	var glove_material := _glove_material()

	right_arm = _build_arm(
		"Right",
		Vector3(0.220, -0.235, -0.300),
		Vector3(-10.0, -5.0, -15.0),
		0.53,
		true,
		sleeve_material,
		skin_material,
		glove_material
	)

	left_arm = _build_arm(
		"Left",
		Vector3(-0.205, -0.245, -0.450),
		Vector3(-15.0, 8.0, 18.0),
		0.58,
		false,
		sleeve_material,
		skin_material,
		glove_material
	)

	apply_weapon_slot(int(player.get("current_weapon_index")))


func apply_weapon_slot(slot_index: int) -> void:
	current_slot = clampi(slot_index, 0, 1)

	if right_arm == null or left_arm == null:
		return

	var poses := _base_pose_for_slot(current_slot)
	right_arm.position = poses["right_position"]
	right_arm.rotation_degrees = poses["right_rotation"]
	left_arm.position = poses["left_position"]
	left_arm.rotation_degrees = poses["left_rotation"]


func update_pose(
	delta: float,
	slot_index: int,
	aiming: bool,
	sprinting: bool,
	reloading: bool,
	movement_speed: float,
	suppressed: bool
) -> void:
	if root_armature == null:
		return

	if slot_index != current_slot:
		apply_weapon_slot(slot_index)

	animation_time += delta
	aim_blend = move_toward(
		aim_blend,
		1.0 if aiming else 0.0,
		delta * 9.0
	)
	sprint_blend = move_toward(
		sprint_blend,
		1.0 if sprinting else 0.0,
		delta * 7.5
	)
	reload_blend = move_toward(
		reload_blend,
		1.0 if reloading else 0.0,
		delta * 10.0
	)

	var poses := _base_pose_for_slot(current_slot)
	var right_position: Vector3 = poses["right_position"]
	var right_rotation: Vector3 = poses["right_rotation"]
	var left_position: Vector3 = poses["left_position"]
	var left_rotation: Vector3 = poses["left_rotation"]

	# ADS pulls both hands inward and slightly raises the support hand.
	right_position = right_position.lerp(
		right_position + Vector3(-0.025, 0.025, -0.035),
		aim_blend
	)
	left_position = left_position.lerp(
		left_position + Vector3(0.030, 0.040, 0.055),
		aim_blend
	)

	# Sprint pose lowers the weapon-side arm and tucks support hand.
	right_position += Vector3(
		0.015,
		-0.105,
		0.115
	) * sprint_blend
	right_rotation += Vector3(
		16.0,
		4.0,
		-8.0
	) * sprint_blend

	left_position += Vector3(
		0.045,
		-0.125,
		0.135
	) * sprint_blend
	left_rotation += Vector3(
		20.0,
		-5.0,
		7.0
	) * sprint_blend

	# Reload animation moves the support hand toward the magazine/breech area.
	var reload_wave := sin(animation_time * 7.2)
	left_position += Vector3(
		0.085,
		-0.055 + reload_wave * 0.018,
		0.100
	) * reload_blend
	left_rotation += Vector3(
		16.0,
		-18.0,
		-8.0
	) * reload_blend

	# Small movement sway is applied to the arms independently from the weapon
	# root. This reduces the "hands glued to camera" look.
	if movement_speed > 0.8 and not aiming:
		var movement_scale := clampf(
			movement_speed / 10.0,
			0.0,
			1.0
		)
		var sway_x := sin(animation_time * 7.4) * 0.007 * movement_scale
		var sway_y := absf(cos(animation_time * 7.4)) * 0.005 * movement_scale
		right_position += Vector3(sway_x, -sway_y, 0.0)
		left_position += Vector3(-sway_x * 0.8, -sway_y * 0.8, 0.0)

	# Visual-only suppression tremor, intentionally tiny.
	if suppressed and not aiming:
		var tremor := sin(animation_time * 19.0) * 0.003
		right_position.x += tremor
		left_position.x -= tremor * 0.7

	var blend_weight := clampf(delta * 12.0, 0.0, 1.0)
	right_arm.position = right_arm.position.lerp(
		right_position,
		blend_weight
	)
	left_arm.position = left_arm.position.lerp(
		left_position,
		blend_weight
	)

	right_arm.rotation_degrees = right_arm.rotation_degrees.lerp(
		right_rotation,
		blend_weight
	)
	left_arm.rotation_degrees = left_arm.rotation_degrees.lerp(
		left_rotation,
		blend_weight
	)


func refresh_team_materials() -> void:
	if root_armature == null:
		return

	var sleeve_material := _sleeve_material()
	var glove_material := _glove_material()

	for child: Node in root_armature.find_children("*Sleeve", "", true):
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = sleeve_material

	for child: Node in root_armature.find_children("*Cuff", "", true):
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = glove_material


func _base_pose_for_slot(slot_index: int) -> Dictionary:
	if slot_index == 1:
		return {
			"right_position": Vector3(0.175, -0.215, -0.265),
			"right_rotation": Vector3(-7.0, -4.0, -10.0),
			"left_position": Vector3(-0.105, -0.225, -0.305),
			"left_rotation": Vector3(-9.0, 9.0, 10.0)
		}

	return {
		"right_position": Vector3(0.220, -0.235, -0.300),
		"right_rotation": Vector3(-10.0, -5.0, -15.0),
		"left_position": Vector3(-0.205, -0.245, -0.450),
		"left_rotation": Vector3(-15.0, 8.0, 18.0)
	}


func _build_arm(
	side_name: String,
	position: Vector3,
	rotation_degrees_value: Vector3,
	length: float,
	is_right: bool,
	sleeve_material: Material,
	skin_material: Material,
	glove_material: Material
) -> Node3D:
	var arm_root := Node3D.new()
	arm_root.name = "%sArm" % side_name
	arm_root.position = position
	arm_root.rotation_degrees = rotation_degrees_value
	root_armature.add_child(arm_root)

	# Sleeve/forearm.
	var sleeve := MeshInstance3D.new()
	sleeve.name = "%sSleeve" % side_name
	var sleeve_mesh := CapsuleMesh.new()
	sleeve_mesh.radius = 0.068
	sleeve_mesh.height = length
	sleeve_mesh.radial_segments = 12
	sleeve_mesh.rings = 5
	sleeve.mesh = sleeve_mesh
	sleeve.position = Vector3(0.0, 0.0, length * 0.32)
	sleeve.rotation_degrees.x = 90.0
	sleeve.scale = Vector3(1.0, 0.92, 0.86)
	sleeve.material_override = sleeve_material
	sleeve.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(sleeve)

	# Cuff gives a visible transition from sleeve to hand.
	var cuff := MeshInstance3D.new()
	cuff.name = "%sCuff" % side_name
	var cuff_mesh := CylinderMesh.new()
	cuff_mesh.top_radius = 0.071
	cuff_mesh.bottom_radius = 0.077
	cuff_mesh.height = 0.072
	cuff_mesh.radial_segments = 12
	cuff.mesh = cuff_mesh
	cuff.position = Vector3(0.0, 0.0, length * 0.67)
	cuff.rotation_degrees.x = 90.0
	cuff.material_override = glove_material
	cuff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(cuff)

	# Palm.
	var hand := MeshInstance3D.new()
	hand.name = "%sHand" % side_name
	var hand_mesh := SphereMesh.new()
	hand_mesh.radius = 0.071
	hand_mesh.height = 0.130
	hand_mesh.radial_segments = 12
	hand_mesh.rings = 6
	hand.mesh = hand_mesh
	hand.position = Vector3(0.0, -0.002, length * 0.77)
	hand.scale = Vector3(0.86, 0.66, 1.18)
	hand.rotation_degrees = Vector3(
		7.0 if is_right else -5.0,
		0.0,
		-8.0 if is_right else 8.0
	)
	hand.material_override = skin_material
	hand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(hand)

	# Knuckle block gives the hand more structure without adding bones.
	var knuckles := MeshInstance3D.new()
	knuckles.name = "%sKnuckles" % side_name
	var knuckle_mesh := BoxMesh.new()
	knuckle_mesh.size = Vector3(0.115, 0.043, 0.075)
	knuckles.mesh = knuckle_mesh
	knuckles.position = Vector3(0.0, -0.032, length * 0.81)
	knuckles.material_override = skin_material
	knuckles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(knuckles)

	# Four low-poly fingers around the weapon grip.
	for index: int in range(4):
		var finger := MeshInstance3D.new()
		finger.name = "%sFinger_%d" % [side_name, index]
		var finger_mesh := CapsuleMesh.new()
		finger_mesh.radius = 0.016
		finger_mesh.height = 0.090
		finger_mesh.radial_segments = 8
		finger_mesh.rings = 3
		finger.mesh = finger_mesh
		finger.position = Vector3(
			(-0.037 + float(index) * 0.024)
			* (1.0 if is_right else -1.0),
			-0.038,
			length * 0.845
		)
		finger.rotation_degrees = Vector3(
			76.0,
			4.0 * float(index - 1),
			13.0 if is_right else -13.0
		)
		finger.material_override = skin_material
		finger.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arm_root.add_child(finger)

	var thumb := MeshInstance3D.new()
	thumb.name = "%sThumb" % side_name
	var thumb_mesh := CapsuleMesh.new()
	thumb_mesh.radius = 0.018
	thumb_mesh.height = 0.100
	thumb_mesh.radial_segments = 8
	thumb_mesh.rings = 3
	thumb.mesh = thumb_mesh
	thumb.position = Vector3(
		0.052 if is_right else -0.052,
		-0.010,
		length * 0.80
	)
	thumb.rotation_degrees = Vector3(
		61.0,
		-24.0 if is_right else 24.0,
		34.0 if is_right else -34.0
	)
	thumb.material_override = skin_material
	thumb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(thumb)

	return arm_root


func _sleeve_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var team_id := int(player.get("team"))

	# Allied olive-drab / Axis field-grey. Kept muted so imported weapons remain
	# the focal point rather than the procedural fallback geometry.
	mat.albedo_color = (
		Color(0.24, 0.27, 0.17)
		if team_id == 0
		else Color(0.19, 0.205, 0.19)
	)
	mat.roughness = 0.96
	return mat


func _skin_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.46, 0.31, 0.22)
	mat.roughness = 0.86
	return mat


func _glove_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.105, 0.095, 0.070)
	mat.roughness = 0.94
	return mat
