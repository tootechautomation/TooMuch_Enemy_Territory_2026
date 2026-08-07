extends Node3D

var attacker_skins: Array[Resource] = []
var defender_skins: Array[Resource] = []
var uniform_texture: Texture2D

var visual_root: Node3D
var torso_root: Node3D
var head_root: Node3D
var left_arm_root: Node3D
var right_arm_root: Node3D
var left_leg_root: Node3D
var right_leg_root: Node3D
var weapon_root: Node3D

var animation_time := 0.0
var last_team := -1
var last_class := -1

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		set_process(false)
		return

	attacker_skins = _load_skin_resources([
		"res://data/skins/attacker_ranger.tres",
		"res://data/skins/attacker_desert.tres"
	])
	defender_skins = _load_skin_resources([
		"res://data/skins/defender_steel.tres",
		"res://data/skins/defender_winter.tres"
	])

	call_deferred("_rebuild_character")
	set_process(true)

func _process(delta: float) -> void:
	var actor = get_parent()
	if actor == null:
		return

	if (
		int(actor.team) != last_team
		or int(actor.player_class) != last_class
	):
		_rebuild_character()

	if visual_root == null:
		return

	animation_time += delta
	_animate_character(delta)

func _load_skin_resources(paths: Array[String]) -> Array[Resource]:
	var result: Array[Resource] = []
	for resource_path in paths:
		if not ResourceLoader.exists(resource_path):
			continue
		var resource: Resource = load(resource_path)
		if resource != null:
			result.append(resource)
	return result

func _rebuild_character() -> void:
	for child in get_children():
		child.queue_free()

	var actor = get_parent()
	if actor == null:
		return

	last_team = int(actor.team)
	last_class = int(actor.player_class)

	var skins: Array[Resource] = (
		attacker_skins
		if last_team == 0
		else defender_skins
	)
	if skins.is_empty():
		return

	var skin: Resource = skins[
		posmod(int(actor.peer_id), skins.size())
	]

	var uniform_path := (
		"res://assets/textures/uniform_allied_wool_v819.png"
		if last_team == 0
		else "res://assets/textures/uniform_axis_fieldgray_v819.png"
	)
	uniform_texture = (
		load(uniform_path) as Texture2D
		if ResourceLoader.exists(uniform_path)
		else null
	)

	var old_body := actor.get_node_or_null("Body")
	if old_body != null:
		old_body.visible = false

	visual_root = Node3D.new()
	visual_root.name = "ArticulatedSoldier"
	visual_root.position = Vector3(0.0, -0.04, 0.0)
	add_child(visual_root)

	torso_root = Node3D.new()
	torso_root.name = "TorsoJoint"
	torso_root.position = Vector3(0.0, 0.18, 0.0)
	visual_root.add_child(torso_root)

	head_root = Node3D.new()
	head_root.name = "HeadJoint"
	head_root.position = Vector3(0.0, 0.83, 0.0)
	torso_root.add_child(head_root)

	left_arm_root = Node3D.new()
	left_arm_root.name = "LeftShoulderJoint"
	left_arm_root.position = Vector3(-0.38, 0.42, 0.0)
	torso_root.add_child(left_arm_root)

	right_arm_root = Node3D.new()
	right_arm_root.name = "RightShoulderJoint"
	right_arm_root.position = Vector3(0.38, 0.42, 0.0)
	torso_root.add_child(right_arm_root)

	left_leg_root = Node3D.new()
	left_leg_root.name = "LeftHipJoint"
	left_leg_root.position = Vector3(-0.18, -0.38, 0.0)
	visual_root.add_child(left_leg_root)

	right_leg_root = Node3D.new()
	right_leg_root.name = "RightHipJoint"
	right_leg_root.position = Vector3(0.18, -0.38, 0.0)
	visual_root.add_child(right_leg_root)

	_build_torso(skin)
	_build_head(skin)
	_build_arm(left_arm_root, skin, false)
	_build_arm(right_arm_root, skin, true)
	_build_leg(left_leg_root, skin, false)
	_build_leg(right_leg_root, skin, true)
	_build_equipment(skin)
	_build_weapon(skin)
	_build_class_gear(skin)

func _build_torso(skin: Resource) -> void:
	_add_capsule(
		torso_root,
		"TunicTorso",
		Vector3.ZERO,
		0.35,
		0.76,
		skin.primary_color,
		Vector3(1.0, 1.0, 0.78)
	)
	_add_box(
		torso_root,
		"ChestWebbing",
		Vector3(0.0, 0.02, -0.24),
		Vector3(0.54, 0.48, 0.075),
		skin.accent_color.darkened(0.22)
	)
	_add_box(
		torso_root,
		"TunicSkirt",
		Vector3(0.0, -0.39, 0.0),
		Vector3(0.65, 0.32, 0.35),
		skin.primary_color.darkened(0.06)
	)
	_add_box(
		torso_root,
		"Collar",
		Vector3(0.0, 0.39, -0.07),
		Vector3(0.43, 0.13, 0.25),
		skin.primary_color.darkened(0.12)
	)
	_add_box(
		torso_root,
		"Belt",
		Vector3(0.0, -0.30, -0.01),
		Vector3(0.68, 0.12, 0.37),
		skin.accent_color.darkened(0.25)
	)
	for x_value in [-0.25, 0.25]:
		_add_box(
			torso_root,
			"AmmoPouch",
			Vector3(x_value, -0.31, -0.24),
			Vector3(0.19, 0.25, 0.13),
			skin.accent_color.darkened(0.12)
		)

	for x_value in [-0.23, 0.23]:
		_add_box(
			torso_root,
			"CanvasShoulderStrap",
			Vector3(x_value, 0.15, -0.285),
			Vector3(0.075, 0.60, 0.035),
			skin.accent_color.darkened(0.18),
			Vector3(0.0, 0.0, -8.0 if x_value < 0.0 else 8.0)
		)
		_add_box(
			torso_root,
			"TunicBreastPocket",
			Vector3(x_value, 0.15, -0.295),
			Vector3(0.19, 0.17, 0.045),
			skin.primary_color.darkened(0.08)
		)

	for button_index in range(4):
		_add_cylinder(
			torso_root,
			"TunicButton",
			Vector3(0.0, 0.25 - float(button_index) * 0.15, -0.305),
			0.018,
			0.018,
			Color(0.22, 0.20, 0.14),
			Vector3(90.0, 0.0, 0.0)
		)

	_add_box(
		torso_root,
		"BeltBuckle",
		Vector3(0.0, -0.30, -0.215),
		Vector3(0.105, 0.075, 0.025),
		Color(0.34, 0.31, 0.21)
	)

func _build_head(skin: Resource) -> void:
	var skin_color := (
		Color(0.60, 0.43, 0.31)
		if posmod(int(get_parent().peer_id), 3) != 1
		else Color(0.43, 0.29, 0.20)
	)
	_add_sphere(
		head_root,
		"Head",
		Vector3(0.0, 0.08, 0.0),
		Vector3(0.26, 0.31, 0.25),
		skin_color
	)
	_add_box(
		head_root,
		"Nose",
		Vector3(0.0, 0.08, -0.245),
		Vector3(0.065, 0.11, 0.075),
		skin_color.lightened(0.04)
	)
	for x_value in [-0.085, 0.085]:
		_add_sphere(
			head_root,
			"Eye",
			Vector3(x_value, 0.13, -0.235),
			Vector3(0.027, 0.020, 0.015),
			Color(0.10, 0.09, 0.07)
		)
	for x_value in [-0.255, 0.255]:
		_add_sphere(
			head_root,
			"Ear",
			Vector3(x_value, 0.07, 0.0),
			Vector3(0.045, 0.075, 0.030),
			skin_color.darkened(0.03)
		)

	var helmet := _add_sphere(
		head_root,
		"SteelHelmet",
		Vector3(0.0, 0.26, 0.0),
		Vector3(0.36, 0.20, 0.35),
		skin.helmet_color
	)
	helmet.scale.y = 0.72
	_add_cylinder(
		head_root,
		"HelmetRim",
		Vector3(0.0, 0.18, -0.015),
		0.37,
		0.055,
		skin.helmet_color.darkened(0.09),
		Vector3.ZERO
	)
	_add_box(
		head_root,
		"HelmetStrapL",
		Vector3(-0.18, -0.01, -0.03),
		Vector3(0.025, 0.35, 0.025),
		Color(0.13, 0.10, 0.06)
	)
	if last_team == 1:
		_add_box(
			head_root,
			"HelmetNeckSkirt",
			Vector3(0.0, 0.10, 0.13),
			Vector3(0.50, 0.20, 0.22),
			skin.helmet_color.darkened(0.07),
			Vector3(-13.0, 0.0, 0.0)
		)
	_add_box(
		head_root,
		"HelmetStrapR",
		Vector3(0.18, -0.01, -0.03),
		Vector3(0.025, 0.35, 0.025),
		Color(0.13, 0.10, 0.06)
	)

func _build_arm(
	root: Node3D,
	skin: Resource,
	right_side: bool
) -> void:
	var side := 1.0 if right_side else -1.0
	var upper := Node3D.new()
	upper.name = "UpperArm"
	upper.position = Vector3(side * 0.03, -0.27, 0.0)
	root.add_child(upper)
	_add_capsule(
		upper,
		"Sleeve",
		Vector3.ZERO,
		0.125,
		0.52,
		skin.primary_color,
		Vector3(0.90, 1.0, 0.90)
	)

	var elbow := Node3D.new()
	elbow.name = "ElbowJoint"
	elbow.position = Vector3(0.0, -0.45, 0.0)
	root.add_child(elbow)
	_add_capsule(
		elbow,
		"Forearm",
		Vector3(0.0, -0.20, -0.02),
		0.105,
		0.42,
		skin.primary_color.darkened(0.03),
		Vector3(0.88, 1.0, 0.88)
	)
	_add_sphere(
		elbow,
		"Hand",
		Vector3(0.0, -0.43, -0.03),
		Vector3(0.11, 0.14, 0.10),
		Color(0.57, 0.40, 0.29)
	)

func _build_leg(
	root: Node3D,
	skin: Resource,
	right_side: bool
) -> void:
	var thigh := Node3D.new()
	thigh.name = "Thigh"
	thigh.position = Vector3(0.0, -0.30, 0.0)
	root.add_child(thigh)
	_add_capsule(
		thigh,
		"TrousersUpper",
		Vector3.ZERO,
		0.145,
		0.58,
		skin.secondary_color.darkened(0.06),
		Vector3(0.95, 1.0, 0.90)
	)

	var knee := Node3D.new()
	knee.name = "KneeJoint"
	knee.position = Vector3(0.0, -0.60, 0.0)
	root.add_child(knee)
	_add_capsule(
		knee,
		"TrousersLower",
		Vector3(0.0, -0.22, 0.0),
		0.125,
		0.46,
		skin.secondary_color.darkened(0.09),
		Vector3(0.92, 1.0, 0.88)
	)
	_add_capsule(
		knee,
		"LeatherBoot",
		Vector3(0.0, -0.49, -0.09),
		0.13,
		0.38,
		Color(0.055, 0.047, 0.038),
		Vector3(0.90, 1.0, 1.12),
		Vector3(90.0, 0.0, 0.0)
	)

func _build_equipment(skin: Resource) -> void:
	_add_capsule(
		torso_root,
		"Backpack",
		Vector3(0.0, 0.01, 0.31),
		0.27,
		0.62,
		skin.secondary_color.darkened(0.15),
		Vector3(1.0, 1.0, 0.46)
	)
	_add_cylinder(
		torso_root,
		"Canteen",
		Vector3(-0.39, -0.31, 0.19),
		0.10,
		0.27,
		Color(0.22, 0.26, 0.17),
		Vector3.ZERO
	)
	_add_box(
		torso_root,
		"EntrenchingTool",
		Vector3(0.35, -0.03, 0.38),
		Vector3(0.14, 0.52, 0.07),
		Color(0.19, 0.14, 0.075)
	)

func _build_weapon(skin: Resource) -> void:
	weapon_root = Node3D.new()
	weapon_root.name = "FallbackWeapon"
	weapon_root.position = Vector3(0.05, 0.03, -0.42)
	weapon_root.rotation_degrees = Vector3(-4.0, 0.0, -3.0)
	torso_root.add_child(weapon_root)

	var metal := Color(0.095, 0.105, 0.105)
	var wood := Color(0.27, 0.14, 0.065)
	_add_box(
		weapon_root,
		"Receiver",
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.13, 0.14, 0.68),
		metal
	)
	_add_cylinder(
		weapon_root,
		"Barrel",
		Vector3(0.0, 0.0, -0.56),
		0.025,
		0.58,
		metal,
		Vector3(90.0, 0.0, 0.0)
	)
	_add_box(
		weapon_root,
		"WoodStock",
		Vector3(0.0, 0.03, 0.46),
		Vector3(0.18, 0.20, 0.43),
		wood
	)
	_add_capsule(
		weapon_root,
		"WoodHandguard",
		Vector3(0.0, 0.015, -0.30),
		0.075,
		0.46,
		wood.darkened(0.03),
		Vector3(0.82, 1.0, 0.72),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_box(
		weapon_root,
		"Magazine",
		Vector3(0.0, -0.15, -0.05),
		Vector3(0.11, 0.28, 0.18),
		metal.darkened(0.05)
	)
	_add_box(
		weapon_root,
		"FrontSight",
		Vector3(0.0, -0.07, -0.82),
		Vector3(0.025, 0.13, 0.035),
		metal
	)
	_add_cylinder(
		weapon_root,
		"BoltHandle",
		Vector3(0.10, -0.015, 0.02),
		0.018,
		0.15,
		metal.lightened(0.08),
		Vector3(0.0, 0.0, 90.0)
	)
	_add_box(
		weapon_root,
		"TriggerGuard",
		Vector3(0.0, -0.12, 0.11),
		Vector3(0.11, 0.035, 0.16),
		metal.darkened(0.04),
		Vector3(12.0, 0.0, 0.0)
	)
	_add_box(
		weapon_root,
		"CanvasWeaponSling",
		Vector3(-0.10, 0.10, 0.05),
		Vector3(0.025, 0.025, 1.12),
		Color(0.24, 0.19, 0.10),
		Vector3(0.0, -5.0, 0.0)
	)

func _build_class_gear(skin: Resource) -> void:
	var actor = get_parent()
	match int(actor.player_class):
		0:
			_add_box(torso_root, "SoldierBandolier", Vector3(-0.04, 0.08, -0.305), Vector3(0.12, 0.72, 0.055), Color(0.31, 0.24, 0.12), Vector3(0.0, 0.0, -26.0))
			for grenade_x in [-0.25, 0.25]:
				_add_cylinder(torso_root, "SoldierGrenade", Vector3(grenade_x, -0.20, -0.34), 0.065, 0.17, Color(0.17, 0.21, 0.12), Vector3.ZERO)
			_add_box(torso_root, "SoldierBayonetScabbard", Vector3(0.40, -0.23, 0.10), Vector3(0.075, 0.48, 0.07), Color(0.12, 0.10, 0.07), Vector3(0.0, 0.0, -8.0))
		1:
			_add_box(torso_root, "MedicCanvasPack", Vector3(0.0, 0.05, 0.42), Vector3(0.62, 0.56, 0.20), Color(0.39, 0.39, 0.31))
			_add_box(torso_root, "MedicPackFlap", Vector3(0.0, 0.17, 0.535), Vector3(0.54, 0.27, 0.045), Color(0.47, 0.46, 0.36))
			_add_box(torso_root, "MedicArmband", Vector3(-0.405, 0.27, -0.02), Vector3(0.035, 0.19, 0.24), Color(0.80, 0.78, 0.66))
			_add_box(torso_root, "MedicCrossVertical", Vector3(-0.428, 0.27, -0.11), Vector3(0.018, 0.125, 0.038), Color(0.62, 0.08, 0.065))
			_add_box(torso_root, "MedicCrossHorizontal", Vector3(-0.428, 0.27, -0.11), Vector3(0.018, 0.042, 0.125), Color(0.62, 0.08, 0.065))
			for pouch_x in [-0.23, 0.23]:
				_add_box(torso_root, "MedicFieldDressingPouch", Vector3(pouch_x, -0.30, -0.335), Vector3(0.18, 0.18, 0.10), Color(0.42, 0.40, 0.31))
		2:
			_add_box(torso_root, "EngineerToolRoll", Vector3(0.0, -0.10, 0.43), Vector3(0.60, 0.34, 0.20), Color(0.31, 0.21, 0.10))
			_add_box(torso_root, "EngineerToolRollFlap", Vector3(0.0, 0.02, 0.545), Vector3(0.53, 0.16, 0.045), Color(0.38, 0.26, 0.12))
			_add_box(torso_root, "EngineerWrench", Vector3(0.35, -0.02, -0.33), Vector3(0.055, 0.45, 0.035), Color(0.17, 0.18, 0.17), Vector3(0.0, 0.0, 12.0))
			_add_cylinder(torso_root, "EngineerWireSpool", Vector3(-0.34, -0.21, 0.22), 0.12, 0.16, Color(0.18, 0.17, 0.13), Vector3(0.0, 0.0, 90.0))
			for cap_x in [-0.09, 0.09]:
				_add_cylinder(torso_root, "EngineerDynamiteCapTin", Vector3(cap_x, -0.30, -0.34), 0.045, 0.15, Color(0.25, 0.22, 0.14), Vector3.ZERO)
		3:
			_add_box(torso_root, "RadioPack", Vector3(0.0, 0.08, 0.43), Vector3(0.52, 0.62, 0.26), Color(0.16, 0.18, 0.12))
			_add_box(torso_root, "RadioControlPanel", Vector3(0.0, 0.21, 0.575), Vector3(0.36, 0.23, 0.045), Color(0.095, 0.105, 0.085))
			for dial_x in [-0.10, 0.0, 0.10]:
				_add_cylinder(torso_root, "RadioControlDial", Vector3(dial_x, 0.23, 0.605), 0.025, 0.025, Color(0.27, 0.25, 0.18), Vector3(90.0, 0.0, 0.0))
			_add_cylinder(torso_root, "RadioAntenna", Vector3(0.23, 0.60, 0.46), 0.018, 1.00, Color(0.07, 0.07, 0.06), Vector3.ZERO)
			_add_box(torso_root, "RadioHandset", Vector3(-0.39, 0.12, -0.28), Vector3(0.10, 0.29, 0.08), Color(0.075, 0.08, 0.065), Vector3(0.0, 0.0, -8.0))
		4:
			_add_cylinder(weapon_root, "Scope", Vector3(0.0, -0.12, -0.12), 0.05, 0.30, Color(0.07, 0.075, 0.075), Vector3(0.0, 0.0, 90.0))
			for binocular_x in [-0.07, 0.07]:
				_add_cylinder(torso_root, "ScoutBinocularTube", Vector3(binocular_x, -0.04, -0.36), 0.055, 0.18, Color(0.075, 0.08, 0.07), Vector3(90.0, 0.0, 0.0))
			_add_box(torso_root, "ScoutMapCase", Vector3(0.36, -0.17, 0.19), Vector3(0.25, 0.34, 0.11), Color(0.30, 0.20, 0.09), Vector3(0.0, 0.0, -7.0))
			_add_box(head_root, "ScoutHelmetScrim", Vector3(0.0, 0.28, -0.23), Vector3(0.46, 0.045, 0.14), skin.accent_color.darkened(0.18), Vector3(-8.0, 0.0, 0.0))
		_:
			pass

func _animate_character(delta: float) -> void:
	var actor = get_parent()
	var speed := Vector2(actor.velocity.x, actor.velocity.z).length()
	var moving := speed > 0.20
	var running := speed > 5.0
	var crouching := bool(actor.is_crouching)
	var downed := bool(actor.downed)
	var alive := bool(actor.alive)

	if not alive or downed:
		visual_root.rotation_degrees.z = lerpf(
			visual_root.rotation_degrees.z,
			82.0,
			minf(1.0, delta * 5.0)
		)
		return

	visual_root.rotation_degrees.z = lerpf(
		visual_root.rotation_degrees.z,
		0.0,
		minf(1.0, delta * 7.0)
	)

	var gait_speed := 11.0 if running else 7.0
	var gait := sin(animation_time * gait_speed)
	var opposite := sin(animation_time * gait_speed + PI)
	var amplitude := (
		34.0 if running
		else 22.0 if moving
		else 2.0
	)
	var crouch_offset := -0.34 if crouching else 0.0

	visual_root.position.y = lerpf(
		visual_root.position.y,
		-0.04 + crouch_offset,
		minf(1.0, delta * 8.0)
	)
	torso_root.rotation_degrees.x = (
		-10.0 if running
		else -5.0 if moving
		else 0.0
	)
	torso_root.position.y = 0.18 + (
		absf(gait) * 0.028 if moving else 0.0
	)

	left_leg_root.rotation_degrees.x = gait * amplitude
	right_leg_root.rotation_degrees.x = opposite * amplitude

	if weapon_root != null:
		left_arm_root.rotation_degrees.x = -46.0 + gait * 5.0
		right_arm_root.rotation_degrees.x = -50.0 + opposite * 4.0
		left_arm_root.rotation_degrees.z = -18.0
		right_arm_root.rotation_degrees.z = 18.0
		weapon_root.rotation_degrees.x = (
			-10.0 if bool(actor.aim_requested) else -4.0
		)
	else:
		left_arm_root.rotation_degrees.x = opposite * amplitude * 0.75
		right_arm_root.rotation_degrees.x = gait * amplitude * 0.75

	head_root.rotation_degrees.y = (
		sin(animation_time * 0.7) * 2.0
		if not moving
		else 0.0
	)

func _material_for_part(
	node_name: String,
	color: Color
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	var lower_name := node_name.to_lower()
	var is_uniform := (
		"tunic" in lower_name
		or "sleeve" in lower_name
		or "forearm" in lower_name
		or "trousers" in lower_name
		or "collar" in lower_name
	)
	if uniform_texture != null and is_uniform:
		material.albedo_texture = uniform_texture
		material.albedo_color = Color(0.92, 0.92, 0.92, 1.0)
		material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	if (
		"helmet" in lower_name
		or "receiver" in lower_name
		or "barrel" in lower_name
		or "sight" in lower_name
		or "bolt" in lower_name
		or "buckle" in lower_name
		or "trigger" in lower_name
	):
		material.roughness = 0.48
		material.metallic = 0.68
	else:
		material.roughness = 0.94 if is_uniform else 0.88
		material.metallic = 0.02
	return material

func _add_box(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	size: Vector3,
	color: Color,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.material_override = _material_for_part(node_name, color)
	parent.add_child(part)
	return part

func _add_capsule(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	color: Color,
	scale_value: Vector3 = Vector3.ONE,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.scale = scale_value
	part.rotation_degrees = rotation_value
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 20
	mesh.rings = 10
	part.mesh = mesh
	part.material_override = _material_for_part(node_name, color)
	parent.add_child(part)
	return part

func _add_cylinder(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	color: Color,
	rotation_value: Vector3
) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.06
	mesh.height = height
	mesh.radial_segments = 20
	part.mesh = mesh
	part.material_override = _material_for_part(node_name, color)
	parent.add_child(part)
	return part

func _add_sphere(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	scale_value: Vector3,
	color: Color
) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.scale = scale_value
	var mesh := SphereMesh.new()
	mesh.radial_segments = 24
	mesh.rings = 12
	part.mesh = mesh
	part.material_override = _material_for_part(node_name, color)
	parent.add_child(part)
	return part
