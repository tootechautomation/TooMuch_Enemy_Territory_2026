extends Node3D
class_name AlleyDetailPass

func build() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_build_drainpipes()
	_build_overhead_cables()
	_build_period_posters()
	_build_wall_caps()
	_build_alley_clutter()

func _material(
	color: Color,
	roughness: float = 0.9,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _box(
	node_name: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position_value
	mesh_instance.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance

func _cylinder(
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position_value
	mesh_instance.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance

func _build_drainpipes() -> void:
	var metal := _material(
		Color(0.105, 0.11, 0.105),
		0.54,
		0.62
	)
	for data in [
		[Vector3(-47.15, 3.45, -28.4), 8.0],
		[Vector3(-47.70, 3.45, -9.5), -4.0],
		[Vector3(-46.15, 3.45, 11.5), 7.0],
		[Vector3(-45.10, 3.45, 32.4), -9.0]
	]:
		_cylinder(
			"FacadeDrainpipe",
			Vector3(data[0]),
			0.055,
			6.9,
			metal,
			Vector3(0.0, 0.0, float(data[1]))
		)

func _build_overhead_cables() -> void:
	var cable := _material(
		Color(0.025, 0.025, 0.022),
		0.68,
		0.30
	)
	for data in [
		[Vector3(-45.0, 5.8, -18.0), Vector3(0.04, 0.04, 20.0), 2.0],
		[Vector3(-43.5, 6.4, 2.5), Vector3(0.04, 0.04, 20.0), -3.0],
		[Vector3(-42.0, 5.6, 23.5), Vector3(0.04, 0.04, 20.0), 3.0]
	]:
		_box(
			"OverheadUtilityCable",
			Vector3(data[0]),
			Vector3(data[1]),
			cable,
			Vector3(float(data[2]), 0.0, 0.0)
		)

func _build_period_posters() -> void:
	var paper := _material(
		Color(0.64, 0.56, 0.39, 0.88),
		0.98
	)
	paper.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var dark_paper := _material(
		Color(0.27, 0.18, 0.10, 0.90),
		0.98
	)
	dark_paper.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for data in [
		[Vector3(-47.48, 2.0, -22.5), paper, 4.0],
		[Vector3(-48.25, 1.7, -3.5), dark_paper, -5.0],
		[Vector3(-45.95, 2.2, 17.0), paper, 3.0],
		[Vector3(-45.30, 1.8, 37.0), dark_paper, -4.0]
	]:
		_box(
			"AgedWallPoster",
			Vector3(data[0]),
			Vector3(0.72, 1.02, 0.025),
			data[1] as Material,
			Vector3(0.0, float(data[2]), 0.0)
		)

func _build_wall_caps() -> void:
	var stone := _material(
		Color(0.45, 0.42, 0.35),
		0.98
	)
	for data in [
		[Vector3(-44.6, 4.75, -25.0), Vector3(0.52, 0.18, 8.0), 2.0],
		[Vector3(-43.4, 4.75, -5.5), Vector3(0.52, 0.18, 8.5), -2.0],
		[Vector3(-42.7, 4.75, 15.5), Vector3(0.52, 0.18, 8.0), 2.0],
		[Vector3(-41.8, 4.75, 36.0), Vector3(0.52, 0.18, 8.5), -3.0]
	]:
		_box(
			"MasonryWallCap",
			Vector3(data[0]),
			Vector3(data[1]),
			stone,
			Vector3(0.0, float(data[2]), 0.0)
		)

func _build_alley_clutter() -> void:
	var wood := _material(
		Color(0.24, 0.12, 0.05),
		0.92
	)
	var steel := _material(
		Color(0.12, 0.13, 0.12),
		0.58,
		0.55
	)
	for position_value in [
		Vector3(-43.0, 0.35, -15.0),
		Vector3(-42.5, 0.35, 6.5),
		Vector3(-41.8, 0.35, 28.0)
	]:
		_box(
			"AlleyWoodCrate",
			position_value,
			Vector3(0.72, 0.70, 0.72),
			wood,
			Vector3(0.0, randf_range(-12.0, 12.0), 0.0)
		)
		_cylinder(
			"AlleyMetalBin",
			position_value + Vector3(0.8, 0.30, 0.15),
			0.24,
			0.60,
			steel
		)
