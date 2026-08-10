extends Node3D
class_name FirstPersonArmsFallback

var player: Node
var weapon_view: Node3D
var root_armature: Node3D

var right_hand: Node3D
var left_hand: Node3D
var right_forearm: MeshInstance3D
var left_forearm: MeshInstance3D

var current_slot := 0
var animation_time := 0.0
var aim_blend := 0.0
var sprint_blend := 0.0
var reload_blend := 0.0


func initialize(owner_player: Node, view_root: Node3D) -> void:
	player = owner_player
	weapon_view = view_root

	if DisplayServer.get_name() == "headless":
		return
	if player == null or weapon_view == null:
		return

	call_deferred("_build_if_needed")


func _quality_preset() -> int:
	if player == null:
		return 1
	if player.has_method("_local_visual_quality_preset"):
		return clampi(
			int(player.call("_local_visual_quality_preset")),
			0,
			2
		)
	return 1


func _build_if_needed() -> void:
	if weapon_view == null:
		return

	# Never stack fallback geometry over a real imported first-person arm rig.
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
	root_armature.name = "FirstPersonArmsFallback_v917"
	weapon_view.add_child(root_armature)

	# HARD SAFETY SCALE:
	# v9.16 used long arm capsules that could intersect the camera and fill the
	# screen. This entire fallback is now constrained to a small viewmodel scale.
	root_armature.scale = Vector3(0.72, 0.72, 0.72)

	var sleeve_material := _sleeve_material()
	var skin_material := _skin_material()
	var glove_material := _glove_material()

	right_hand = _build_compact_hand(
		"Right",
		true,
		skin_material,
		glove_material
	)
	left_hand = _build_compact_hand(
		"Left",
		false,
		skin_material,
		glove_material
	)

	right_forearm = _build_short_forearm(
		"Right",
		sleeve_material,
		glove_material
	)
	left_forearm = _build_short_forearm(
		"Left",
		sleeve_material,
		glove_material
	)

	_apply_quality_visibility()
	apply_weapon_slot(int(player.get("current_weapon_index")))


func _build_compact_hand(
	side_name: String,
	is_right: bool,
	skin_material: Material,
	glove_material: Material
) -> Node3D:
	var hand_root := Node3D.new()
	hand_root.name = "%sHandRoot" % side_name
	root_armature.add_child(hand_root)

	var palm := MeshInstance3D.new()
	palm.name = "%sPalm" % side_name
	var palm_mesh := BoxMesh.new()
	palm_mesh.size = Vector3(0.095, 0.060, 0.125)
	palm.mesh = palm_mesh
	palm.material_override = skin_material
	palm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hand_root.add_child(palm)

	# Three compact grip fingers are enough to read as a hand at gameplay FOV.
	for index: int in range(3):
		var finger := MeshInstance3D.new()
		finger.name = "%sFinger_%d" % [side_name, index]
		var finger_mesh := CapsuleMesh.new()
		finger_mesh.radius = 0.012
		finger_mesh.height = 0.063
		finger_mesh.radial_segments = 6
		finger_mesh.rings = 2
		finger.mesh = finger_mesh
		finger.position = Vector3(
			(-0.028 + float(index) * 0.028)
			* (1.0 if is_right else -1.0),
			-0.043,
			0.015
		)
		finger.rotation_degrees = Vector3(
			78.0,
			0.0,
			10.0 if is_right else -10.0
		)
		finger.material_override = skin_material
		finger.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hand_root.add_child(finger)

	var thumb := MeshInstance3D.new()
	thumb.name = "%sThumb" % side_name
	var thumb_mesh := CapsuleMesh.new()
	thumb_mesh.radius = 0.014
	thumb_mesh.height = 0.072
	thumb_mesh.radial_segments = 6
	thumb_mesh.rings = 2
	thumb.mesh = thumb_mesh
	thumb.position = Vector3(
		0.052 if is_right else -0.052,
		-0.010,
		0.005
	)
	thumb.rotation_degrees = Vector3(
		60.0,
		-25.0 if is_right else 25.0,
		28.0 if is_right else -28.0
	)
	thumb.material_override = skin_material
	thumb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hand_root.add_child(thumb)

	# Small dark cuff immediately behind the hand.
	var cuff := MeshInstance3D.new()
	cuff.name = "%sCuff" % side_name
	var cuff_mesh := BoxMesh.new()
	cuff_mesh.size = Vector3(0.105, 0.070, 0.075)
	cuff.mesh = cuff_mesh
	cuff.position = Vector3(0.0, 0.0, 0.082)
	cuff.material_override = glove_material
	cuff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hand_root.add_child(cuff)

	return hand_root


func _build_short_forearm(
	side_name: String,
	sleeve_material: Material,
	glove_material: Material
) -> MeshInstance3D:
	# SHORT box/taper-style sleeve rather than a long CapsuleMesh.
	# It stays behind the hand and cannot form the giant circular/oval shapes
	# seen in the v9.16 screenshots.
	var sleeve := MeshInstance3D.new()
	sleeve.name = "%sShortSleeve" % side_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.115, 0.090, 0.245)
	sleeve.mesh = mesh
	sleeve.material_override = sleeve_material
	sleeve.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root_armature.add_child(sleeve)
	return sleeve


func _apply_quality_visibility() -> void:
	var quality := _quality_preset()

	# Low/Laptop = hands only. This is both cheaper and guarantees the center
	# view remains unobstructed on machines using the performance preset.
	if right_forearm != null:
		right_forearm.visible = quality >= 1
	if left_forearm != null:
		left_forearm.visible = quality >= 1


func refresh_team_materials() -> void:
	if root_armature == null:
		return

	var sleeve_material := _sleeve_material()
	var glove_material := _glove_material()
	var skin_material := _skin_material()

	for child: Node in root_armature.find_children("*ShortSleeve", "", true):
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = sleeve_material

	for child: Node in root_armature.find_children("*Cuff", "", true):
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = glove_material

	for child: Node in root_armature.find_children("*Palm", "", true):
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = skin_material

	_apply_quality_visibility()


func apply_weapon_slot(slot_index: int) -> void:
	current_slot = clampi(slot_index, 0, 1)
	if right_hand == null or left_hand == null:
		return

	if current_slot == 1:
		# Pistol: both hands close to the grip. Keep them below center screen.
		right_hand.position = Vector3(0.135, -0.235, -0.145)
		right_hand.rotation_degrees = Vector3(-5.0, -7.0, -12.0)

		left_hand.position = Vector3(-0.075, -0.245, -0.175)
		left_hand.rotation_degrees = Vector3(-7.0, 10.0, 10.0)

		if right_forearm != null:
			right_forearm.position = Vector3(0.175, -0.275, -0.015)
			right_forearm.rotation_degrees = Vector3(-6.0, -8.0, -10.0)
		if left_forearm != null:
			left_forearm.position = Vector3(-0.115, -0.290, -0.035)
			left_forearm.rotation_degrees = Vector3(-8.0, 9.0, 9.0)
	else:
		# Primary: dominant hand at grip, support hand under/forward.
		right_hand.position = Vector3(0.155, -0.255, -0.180)
		right_hand.rotation_degrees = Vector3(-7.0, -8.0, -14.0)

		left_hand.position = Vector3(-0.145, -0.265, -0.315)
		left_hand.rotation_degrees = Vector3(-10.0, 10.0, 14.0)

		if right_forearm != null:
			right_forearm.position = Vector3(0.205, -0.300, -0.045)
			right_forearm.rotation_degrees = Vector3(-7.0, -8.0, -12.0)
		if left_forearm != null:
			left_forearm.position = Vector3(-0.190, -0.310, -0.170)
			left_forearm.rotation_degrees = Vector3(-11.0, 10.0, 12.0)


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

	_apply_quality_visibility()

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
		delta * 8.0
	)
	reload_blend = move_toward(
		reload_blend,
		1.0 if reloading else 0.0,
		delta * 10.0
	)

	# Re-establish safe base positions each frame, then add SMALL offsets.
	var right_base := (
		Vector3(0.135, -0.235, -0.145)
		if current_slot == 1
		else Vector3(0.155, -0.255, -0.180)
	)
	var left_base := (
		Vector3(-0.075, -0.245, -0.175)
		if current_slot == 1
		else Vector3(-0.145, -0.265, -0.315)
	)

	var right_target := right_base
	var left_target := left_base

	# ADS: lift only a few centimeters. Never move toward the center/camera.
	right_target += Vector3(-0.010, 0.022, -0.018) * aim_blend
	left_target += Vector3(0.012, 0.025, 0.020) * aim_blend

	# Sprint lowers hands out of the sight line.
	right_target += Vector3(0.010, -0.070, 0.055) * sprint_blend
	left_target += Vector3(0.018, -0.075, 0.060) * sprint_blend

	# Reload support-hand motion stays below center.
	left_target += Vector3(
		0.050,
		-0.035,
		0.055
	) * reload_blend

	if movement_speed > 0.8 and not aiming:
		var motion := clampf(movement_speed / 10.0, 0.0, 1.0)
		var sway := sin(animation_time * 7.2) * 0.004 * motion
		right_target.x += sway
		left_target.x -= sway * 0.7

	if suppressed and not aiming:
		var tremor := sin(animation_time * 19.0) * 0.002
		right_target.x += tremor
		left_target.x -= tremor

	var weight := clampf(delta * 13.0, 0.0, 1.0)
	right_hand.position = right_hand.position.lerp(right_target, weight)
	left_hand.position = left_hand.position.lerp(left_target, weight)

	# HARD POSITION CLAMPS:
	# Fallback hands cannot cross into the upper/center sight picture.
	right_hand.position.x = clampf(right_hand.position.x, 0.075, 0.230)
	right_hand.position.y = clampf(right_hand.position.y, -0.390, -0.175)
	right_hand.position.z = clampf(right_hand.position.z, -0.350, -0.080)

	left_hand.position.x = clampf(left_hand.position.x, -0.240, -0.035)
	left_hand.position.y = clampf(left_hand.position.y, -0.400, -0.180)
	left_hand.position.z = clampf(left_hand.position.z, -0.390, -0.100)


func _sleeve_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var team_id := int(player.get("team"))
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
