extends Node3D

var attacker_skins: Array[Resource] = []
var defender_skins: Array[Resource] = []

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
	call_deferred("_build_character")

func _load_skin_resources(paths: Array[String]) -> Array[Resource]:
	var result: Array[Resource] = []
	for path in paths:
		if not ResourceLoader.exists(path):
			continue
		var resource: Resource = load(path)
		if resource != null:
			result.append(resource)
	return result

func _build_character() -> void:
	var player = get_parent()
	var skins: Array[Resource] = (
		attacker_skins if player.team == 0 else defender_skins
	)
	if skins.is_empty():
		return

	var skin: Resource = skins[posmod(player.peer_id, skins.size())]
	var old_body := player.get_node_or_null("Body")
	if old_body:
		old_body.visible = false

	# Rounded torso and pelvis.
	_add_capsule(
		"Torso",
		Vector3(0.0, 0.24, 0.0),
		0.38,
		0.92,
		skin.primary_color
	)
	_add_capsule(
		"Vest",
		Vector3(0.0, 0.28, -0.19),
		0.40,
		0.62,
		skin.secondary_color
	)
	_add_capsule(
		"Pelvis",
		Vector3(0.0, -0.31, 0.0),
		0.34,
		0.34,
		skin.secondary_color.darkened(0.05)
	)

	# Arms and legs use cylinders with rounded joints.
	_add_limb(
		"ArmL",
		Vector3(-0.49, 0.20, 0.0),
		Vector3(0.0, 0.0, 5.0),
		0.13,
		0.80,
		skin.primary_color
	)
	_add_limb(
		"ArmR",
		Vector3(0.49, 0.20, 0.0),
		Vector3(0.0, 0.0, -5.0),
		0.13,
		0.80,
		skin.primary_color
	)
	_add_limb(
		"LegL",
		Vector3(-0.19, -0.76, 0.0),
		Vector3.ZERO,
		0.15,
		0.82,
		skin.secondary_color.darkened(0.08)
	)
	_add_limb(
		"LegR",
		Vector3(0.19, -0.76, 0.0),
		Vector3.ZERO,
		0.15,
		0.82,
		skin.secondary_color.darkened(0.08)
	)

	_add_sphere(
		"Head",
		Vector3(0.0, 0.94, 0.0),
		Vector3(0.28, 0.31, 0.27),
		Color(0.60, 0.43, 0.31)
	)
	_add_helmet(
		Vector3(0.0, 1.08, 0.0),
		skin.helmet_color
	)

	# Boots, gloves, belt, pouches, and backpack add silhouette detail.
	_add_capsule(
		"BootL",
		Vector3(-0.19, -1.18, -0.05),
		0.17,
		0.28,
		Color(0.08, 0.08, 0.07)
	)
	_add_capsule(
		"BootR",
		Vector3(0.19, -1.18, -0.05),
		0.17,
		0.28,
		Color(0.08, 0.08, 0.07)
	)
	_add_sphere(
		"GloveL",
		Vector3(-0.50, -0.22, 0.0),
		Vector3(0.15, 0.15, 0.15),
		Color(0.10, 0.10, 0.09)
	)
	_add_sphere(
		"GloveR",
		Vector3(0.50, -0.22, 0.0),
		Vector3(0.15, 0.15, 0.15),
		Color(0.10, 0.10, 0.09)
	)
	_add_rounded_box(
		"Belt",
		Vector3(0.0, -0.27, 0.0),
		Vector3(0.74, 0.15, 0.38),
		skin.accent_color
	)
	_add_rounded_box(
		"Pack",
		Vector3(0.0, 0.20, 0.31),
		Vector3(0.54, 0.64, 0.20),
		skin.secondary_color.darkened(0.12)
	)
	_add_rounded_box(
		"PouchL",
		Vector3(-0.27, -0.31, -0.22),
		Vector3(0.20, 0.25, 0.12),
		skin.accent_color.darkened(0.10)
	)
	_add_rounded_box(
		"PouchR",
		Vector3(0.27, -0.31, -0.22),
		Vector3(0.20, 0.25, 0.12),
		skin.accent_color.darkened(0.10)
	)

	# Class-specific gear.
	match int(player.player_class):
		1:
			_add_rounded_box(
				"MedicBag",
				Vector3(0.0, 0.15, 0.38),
				Vector3(0.62, 0.55, 0.18),
				Color(0.70, 0.72, 0.66)
			)
		2:
			_add_rounded_box(
				"EngineerToolbox",
				Vector3(0.0, -0.12, 0.38),
				Vector3(0.58, 0.32, 0.22),
				Color(0.42, 0.30, 0.14)
			)
		3:
			_add_cylinder(
				"RadioAntenna",
				Vector3(0.24, 0.73, 0.34),
				0.025,
				0.92,
				Color(0.09, 0.09, 0.08)
			)
		4:
			_add_cylinder(
				"ScoutScope",
				Vector3(0.34, 0.22, -0.34),
				0.065,
				0.38,
				Color(0.08, 0.09, 0.09),
				Vector3(90.0, 0.0, 0.0)
			)
		_:
			pass

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.76
	material.metallic = 0.03
	return material

func _add_rounded_box(
	node_name: String,
	position_value: Vector3,
	size: Vector3,
	color: Color
) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.material_override = _material(color)
	add_child(part)

func _add_capsule(
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	color: Color
) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = maxf(height, radius * 2.0)
	mesh.radial_segments = 16
	mesh.rings = 8
	part.mesh = mesh
	part.material_override = _material(color)
	add_child(part)

func _add_cylinder(
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	color: Color,
	rotation_degrees_value: Vector3 = Vector3.ZERO
) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.rotation_degrees = rotation_degrees_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.06
	mesh.height = height
	mesh.radial_segments = 16
	part.mesh = mesh
	part.material_override = _material(color)
	add_child(part)

func _add_limb(
	node_name: String,
	position_value: Vector3,
	rotation_degrees_value: Vector3,
	radius: float,
	height: float,
	color: Color
) -> void:
	_add_cylinder(
		node_name,
		position_value,
		radius,
		height,
		color,
		rotation_degrees_value
	)

func _add_helmet(
	position_value: Vector3,
	color: Color
) -> void:
	var helmet := MeshInstance3D.new()
	helmet.name = "Helmet"
	helmet.position = position_value
	helmet.scale = Vector3(1.0, 0.62, 1.0)
	var mesh := SphereMesh.new()
	mesh.radius = 0.35
	mesh.height = 0.70
	mesh.radial_segments = 20
	mesh.rings = 10
	helmet.mesh = mesh
	helmet.material_override = _material(color)
	add_child(helmet)

	var rim := MeshInstance3D.new()
	rim.name = "HelmetRim"
	rim.position = position_value + Vector3(0.0, -0.08, -0.03)
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = 0.39
	rim_mesh.bottom_radius = 0.39
	rim_mesh.height = 0.06
	rim_mesh.radial_segments = 20
	rim.mesh = rim_mesh
	rim.material_override = _material(color.darkened(0.08))
	add_child(rim)

func _add_sphere(
	node_name: String,
	position_value: Vector3,
	scale_value: Vector3,
	color: Color
) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = position_value
	part.scale = scale_value
	var mesh := SphereMesh.new()
	mesh.radial_segments = 20
	mesh.rings = 10
	part.mesh = mesh
	part.material_override = _material(color)
	add_child(part)
