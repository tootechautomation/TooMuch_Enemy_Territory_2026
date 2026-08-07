extends RefCounted
class_name FirstPersonWeaponFidelity

static func decorate(
	root: Node3D,
	is_pistol: bool,
	weapon_profile: int,
	metal: Material,
	wood: Material
) -> void:
	if root == null:
		return
	var dark_metal := _material(Color(0.045, 0.05, 0.052), 0.28, 0.82)
	var blued_metal := _material(Color(0.075, 0.085, 0.09), 0.32, 0.78)
	var brass := _material(Color(0.58, 0.38, 0.12), 0.34, 0.72)
	if is_pistol:
		_decorate_pistol(root, metal, wood, dark_metal, blued_metal, brass)
	else:
		_decorate_long_gun(root, weapon_profile, metal, wood, dark_metal, blued_metal, brass)

static func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

static func _box(
	root: Node3D,
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	root.add_child(instance)
	return instance

static func _cylinder(
	root: Node3D,
	name_value: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO,
	radial_segments: int = 14
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = radial_segments
	instance.mesh = mesh
	instance.material_override = material
	root.add_child(instance)
	return instance

static func _ring(
	root: Node3D,
	name_value: String,
	position_value: Vector3,
	inner_radius: float,
	outer_radius: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 12
	mesh.ring_segments = 8
	instance.mesh = mesh
	instance.material_override = material
	root.add_child(instance)
	return instance

static func _decorate_pistol(
	root: Node3D,
	metal: Material,
	wood: Material,
	dark_metal: Material,
	blued_metal: Material,
	brass: Material
) -> void:
	_box(root, "PistolSlide", Vector3(0.0, -0.055, -0.035), Vector3(0.145, 0.105, 0.37), blued_metal)
	_box(root, "EjectionPort", Vector3(0.074, -0.082, -0.055), Vector3(0.008, 0.055, 0.105), dark_metal)
	_box(root, "PistolMagazine", Vector3(0.0, 0.245, 0.115), Vector3(0.085, 0.27, 0.095), metal, Vector3(-12.0, 0.0, 0.0))
	_box(root, "MagazineBase", Vector3(0.0, 0.37, 0.145), Vector3(0.11, 0.025, 0.115), dark_metal, Vector3(-12.0, 0.0, 0.0))
	_ring(root, "PistolTriggerGuard", Vector3(0.0, 0.105, -0.035), 0.043, 0.055, metal, Vector3(90.0, 0.0, 0.0))
	_box(root, "PistolTrigger", Vector3(0.0, 0.105, -0.045), Vector3(0.018, 0.075, 0.018), dark_metal, Vector3(0.0, 0.0, -12.0))
	_box(root, "SlideRelease", Vector3(-0.078, -0.015, 0.025), Vector3(0.012, 0.035, 0.08), dark_metal)
	_box(root, "FrontBladeSight", Vector3(0.0, -0.13, -0.19), Vector3(0.018, 0.045, 0.028), dark_metal)
	_box(root, "RearNotchSight", Vector3(0.0, -0.13, 0.12), Vector3(0.075, 0.035, 0.03), dark_metal)
	_cylinder(root, "ChamberBrass", Vector3(0.077, -0.07, -0.05), 0.015, 0.045, brass, Vector3(0.0, 0.0, 90.0), 12)
	_box(root, "GripPanelLeft", Vector3(-0.061, 0.205, 0.12), Vector3(0.012, 0.20, 0.085), wood, Vector3(-12.0, 0.0, 0.0))
	_box(root, "GripPanelRight", Vector3(0.061, 0.205, 0.12), Vector3(0.012, 0.20, 0.085), wood, Vector3(-12.0, 0.0, 0.0))

static func _decorate_long_gun(
	root: Node3D,
	weapon_profile: int,
	metal: Material,
	wood: Material,
	dark_metal: Material,
	blued_metal: Material,
	brass: Material
) -> void:
	_box(root, "ReceiverTopCover", Vector3(0.0, -0.105, -0.02), Vector3(0.145, 0.055, 0.46), blued_metal)
	_box(root, "EjectionPort", Vector3(0.096, -0.055, -0.09), Vector3(0.012, 0.075, 0.19), dark_metal)
	_box(root, "BoltCarrier", Vector3(0.101, -0.04, -0.055), Vector3(0.02, 0.032, 0.16), metal)
	_cylinder(root, "ChargingHandle", Vector3(0.16, -0.035, 0.02), 0.018, 0.12, dark_metal, Vector3(0.0, 0.0, 90.0), 10)
	_ring(root, "TriggerGuard", Vector3(0.0, 0.125, 0.12), 0.05, 0.065, metal, Vector3(90.0, 0.0, 0.0))
	_box(root, "Trigger", Vector3(0.0, 0.12, 0.11), Vector3(0.018, 0.095, 0.018), dark_metal, Vector3(0.0, 0.0, -14.0))
	_box(root, "SafetyLever", Vector3(-0.101, 0.005, 0.08), Vector3(0.018, 0.028, 0.11), dark_metal, Vector3(18.0, 0.0, 0.0))
	_cylinder(root, "BarrelBand", Vector3(0.0, 0.005, -0.66), 0.075, 0.055, metal, Vector3(90.0, 0.0, 0.0), 16)
	_cylinder(root, "MuzzleCollar", Vector3(0.0, 0.0, -1.05), 0.038, 0.11, dark_metal, Vector3(90.0, 0.0, 0.0), 14)
	_ring(root, "FrontSlingSwivel", Vector3(-0.095, 0.05, -0.57), 0.025, 0.034, metal, Vector3(0.0, 90.0, 0.0))
	_ring(root, "RearSlingSwivel", Vector3(-0.12, 0.07, 0.47), 0.028, 0.038, metal, Vector3(0.0, 90.0, 0.0))
	_cylinder(root, "VisibleCartridge", Vector3(0.10, -0.03, -0.10), 0.013, 0.06, brass, Vector3(0.0, 0.0, 90.0), 10)

	match weapon_profile:
		0:
			_cylinder(root, "LMGDrumMagazine", Vector3(-0.105, 0.105, -0.02), 0.135, 0.095, dark_metal, Vector3(0.0, 0.0, 90.0), 28)
			_cylinder(root, "LMGBarrelJacket", Vector3(0.0, 0.005, -0.66), 0.052, 0.62, blued_metal, Vector3(90.0, 0.0, 0.0), 24)
			_box(root, "LMGRearSight", Vector3(0.0, -0.17, 0.05), Vector3(0.105, 0.055, 0.06), dark_metal)
			_box(root, "LMGCarryHandle", Vector3(-0.12, -0.12, -0.33), Vector3(0.025, 0.15, 0.24), dark_metal, Vector3(0.0, 0.0, -18.0))
			_box(root, "BipodLeft", Vector3(-0.07, 0.08, -0.82), Vector3(0.018, 0.25, 0.018), metal, Vector3(0.0, 0.0, -12.0))
			_box(root, "BipodRight", Vector3(0.07, 0.08, -0.82), Vector3(0.018, 0.25, 0.018), metal, Vector3(0.0, 0.0, 12.0))
		1:
			_box(root, "SMGMagazine", Vector3(0.0, 0.18, -0.14), Vector3(0.10, 0.31, 0.105), dark_metal, Vector3(-5.0, 0.0, 0.0))
			_box(root, "SMGMagazineBase", Vector3(0.0, 0.34, -0.125), Vector3(0.125, 0.022, 0.12), metal, Vector3(-5.0, 0.0, 0.0))
			_cylinder(root, "SMGBarrelShroud", Vector3(0.0, 0.0, -0.52), 0.046, 0.42, blued_metal, Vector3(90.0, 0.0, 0.0), 22)
		2:
			_box(root, "CarbineMagazine", Vector3(0.0, 0.16, -0.15), Vector3(0.105, 0.25, 0.13), dark_metal, Vector3(-12.0, 0.0, 0.0))
			_box(root, "CarbineMagazineBase", Vector3(0.0, 0.29, -0.12), Vector3(0.125, 0.022, 0.145), metal, Vector3(-12.0, 0.0, 0.0))
			_box(root, "CarbineForeEnd", Vector3(0.0, 0.015, -0.43), Vector3(0.145, 0.14, 0.38), wood)
		3:
			_box(root, "Magazine", Vector3(0.0, 0.16, -0.08), Vector3(0.105, 0.25, 0.145), dark_metal, Vector3(-8.0, 0.0, 0.0))
			_box(root, "MagazineFloorPlate", Vector3(0.0, 0.29, -0.05), Vector3(0.125, 0.022, 0.16), metal, Vector3(-8.0, 0.0, 0.0))
			_box(root, "RifleGrenadeSight", Vector3(-0.10, -0.08, -0.47), Vector3(0.025, 0.16, 0.035), metal, Vector3(0.0, 0.0, -18.0))
		4:
			_box(root, "Magazine", Vector3(0.0, 0.14, -0.04), Vector3(0.10, 0.20, 0.13), dark_metal, Vector3(-5.0, 0.0, 0.0))
			_box(root, "MagazineFloorPlate", Vector3(0.0, 0.245, -0.025), Vector3(0.12, 0.022, 0.145), metal, Vector3(-5.0, 0.0, 0.0))
			_box(root, "ScopeAdjustmentBlock", Vector3(0.0, -0.19, -0.08), Vector3(0.09, 0.07, 0.09), dark_metal)
			_cylinder(root, "ScopeAdjustmentDial", Vector3(0.075, -0.19, -0.08), 0.035, 0.045, metal, Vector3(0.0, 0.0, 90.0), 12)
