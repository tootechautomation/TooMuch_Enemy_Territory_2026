extends Node3D
class_name FirstPersonArmsFallback

var player: Node
var weapon_view: Node3D
var root_armature: Node3D

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

	# If another proper first-person arm rig is already present, leave it alone.
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
	root_armature.name = "FirstPersonArmsFallback_v894"
	weapon_view.add_child(root_armature)

	var sleeve_material := _sleeve_material()
	var skin_material := _skin_material()
	var glove_material := _glove_material()

	# Right arm: dominant hand around pistol grip / trigger area.
	_build_arm(
		"Right",
		Vector3(0.235, -0.245, -0.315),
		Vector3(-11.0, -5.0, -17.0),
		0.52,
		true,
		sleeve_material,
		skin_material,
		glove_material
	)

	# Left arm: support hand farther forward along the weapon.
	_build_arm(
		"Left",
		Vector3(-0.215, -0.255, -0.455),
		Vector3(-16.0, 8.0, 19.0),
		0.57,
		false,
		sleeve_material,
		skin_material,
		glove_material
	)

	# Small pose variation by weapon slot.
	apply_weapon_slot(int(player.get("current_weapon_index")))


func apply_weapon_slot(slot_index: int) -> void:
	if root_armature == null:
		return

	var right := root_armature.get_node_or_null("RightArm") as Node3D
	var left := root_armature.get_node_or_null("LeftArm") as Node3D

	if slot_index == 1:
		# Pistol: both hands closer together and slightly higher.
		if right != null:
			right.position = Vector3(0.19, -0.23, -0.28)
			right.rotation_degrees = Vector3(-8.0, -3.0, -12.0)
		if left != null:
			left.position = Vector3(-0.12, -0.245, -0.32)
			left.rotation_degrees = Vector3(-10.0, 10.0, 12.0)
	else:
		if right != null:
			right.position = Vector3(0.235, -0.245, -0.315)
			right.rotation_degrees = Vector3(-11.0, -5.0, -17.0)
		if left != null:
			left.position = Vector3(-0.215, -0.255, -0.455)
			left.rotation_degrees = Vector3(-16.0, 8.0, 19.0)


func _build_arm(
	side_name: String,
	position: Vector3,
	rotation_degrees_value: Vector3,
	length: float,
	is_right: bool,
	sleeve_material: Material,
	skin_material: Material,
	glove_material: Material
) -> void:
	var arm_root := Node3D.new()
	arm_root.name = "%sArm" % side_name
	arm_root.position = position
	arm_root.rotation_degrees = rotation_degrees_value
	root_armature.add_child(arm_root)

	# Tapered-looking sleeve via capsule + cuff.
	var sleeve := MeshInstance3D.new()
	sleeve.name = "%sSleeve" % side_name
	var sleeve_mesh := CapsuleMesh.new()
	sleeve_mesh.radius = 0.070
	sleeve_mesh.height = length
	sleeve_mesh.radial_segments = 14
	sleeve_mesh.rings = 6
	sleeve.mesh = sleeve_mesh
	sleeve.position = Vector3(0.0, 0.0, length * 0.34)
	sleeve.rotation_degrees.x = 90.0
	sleeve.scale = Vector3(1.0, 0.92, 0.88)
	sleeve.material_override = sleeve_material
	sleeve.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(sleeve)

	var cuff := MeshInstance3D.new()
	cuff.name = "%sCuff" % side_name
	var cuff_mesh := CylinderMesh.new()
	cuff_mesh.top_radius = 0.074
	cuff_mesh.bottom_radius = 0.080
	cuff_mesh.height = 0.075
	cuff_mesh.radial_segments = 14
	cuff.mesh = cuff_mesh
	cuff.position = Vector3(0.0, 0.0, length * 0.68)
	cuff.rotation_degrees.x = 90.0
	cuff.material_override = glove_material
	cuff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(cuff)

	# Hand and palm around weapon.
	var hand := MeshInstance3D.new()
	hand.name = "%sHand" % side_name
	var hand_mesh := SphereMesh.new()
	hand_mesh.radius = 0.075
	hand_mesh.height = 0.135
	hand_mesh.radial_segments = 14
	hand_mesh.rings = 7
	hand.mesh = hand_mesh
	hand.position = Vector3(
		0.0,
		-0.002,
		length * 0.77
	)
	hand.scale = Vector3(0.86, 0.68, 1.22)
	hand.rotation_degrees = Vector3(
		7.0 if is_right else -5.0,
		0.0,
		-8.0 if is_right else 8.0
	)
	hand.material_override = skin_material
	hand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(hand)

	# Four small finger segments wrapping the weapon instead of one blob.
	for index: int in range(4):
		var finger := MeshInstance3D.new()
		finger.name = "%sFinger_%d" % [side_name, index]
		var finger_mesh := CapsuleMesh.new()
		finger_mesh.radius = 0.017
		finger_mesh.height = 0.095
		finger_mesh.radial_segments = 10
		finger_mesh.rings = 4
		finger.mesh = finger_mesh
		finger.position = Vector3(
			(-0.038 + float(index) * 0.025)
			* (1.0 if is_right else -1.0),
			-0.035,
			length * 0.84
		)
		finger.rotation_degrees = Vector3(
			74.0,
			4.0 * float(index - 1),
			12.0 if is_right else -12.0
		)
		finger.material_override = skin_material
		finger.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		arm_root.add_child(finger)

	# Thumb.
	var thumb := MeshInstance3D.new()
	thumb.name = "%sThumb" % side_name
	var thumb_mesh := CapsuleMesh.new()
	thumb_mesh.radius = 0.019
	thumb_mesh.height = 0.105
	thumb_mesh.radial_segments = 10
	thumb_mesh.rings = 4
	thumb.mesh = thumb_mesh
	thumb.position = Vector3(
		0.055 if is_right else -0.055,
		-0.012,
		length * 0.80
	)
	thumb.rotation_degrees = Vector3(
		62.0,
		-24.0 if is_right else 24.0,
		35.0 if is_right else -35.0
	)
	thumb.material_override = skin_material
	thumb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arm_root.add_child(thumb)


func _sleeve_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var team_id := int(player.get("team"))
	mat.albedo_color = (
		Color(0.23, 0.25, 0.18)
		if team_id == 0
		else Color(0.18, 0.18, 0.16)
	)
	mat.roughness = 0.93
	return mat


func _skin_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.46, 0.31, 0.22)
	mat.roughness = 0.82
	return mat


func _glove_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.105, 0.075)
	mat.roughness = 0.91
	return mat
