extends Node3D
class_name WWIIDetailPass

var material_cache: Dictionary = {}

func build() -> void:
	if DisplayServer.get_name() == "headless":
		return

	_build_sandbag_positions()
	_build_crate_and_barrel_clusters()
	_build_rubble_fields()
	_build_window_and_shutter_details()
	_build_street_furniture()

func _material(
	cache_key: String,
	color: Color,
	roughness: float = 0.9,
	metallic: float = 0.0
) -> StandardMaterial3D:
	if material_cache.has(cache_key):
		return material_cache[cache_key]

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material_cache[cache_key] = material
	return material

func _mesh_box(
	parent: Node3D,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = position_value
	item.rotation_degrees = rotation_value
	item.material_override = material
	parent.add_child(item)
	return item

func _mesh_cylinder(
	parent: Node3D,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.03
	mesh.height = height
	mesh.radial_segments = 20
	item.mesh = mesh
	item.position = position_value
	item.rotation_degrees = rotation_value
	item.material_override = material
	parent.add_child(item)
	return item

func _mesh_sandbag(
	parent: Node3D,
	position_value: Vector3,
	material: Material,
	tilt_degrees: float
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = "RoundedSandbag"
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.17
	mesh.height = 0.56
	mesh.radial_segments = 16
	mesh.rings = 8
	item.mesh = mesh
	item.position = position_value
	item.rotation_degrees = Vector3(0.0, tilt_degrees, 90.0)
	item.scale = Vector3(1.0, 1.0, 0.72)
	item.material_override = material
	parent.add_child(item)
	return item

func _mesh_rubble(
	parent: Node3D,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = "IrregularRubbleStone"
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4
	item.mesh = mesh
	item.position = position_value
	item.scale = size
	item.rotation_degrees = rotation_value
	item.material_override = material
	parent.add_child(item)
	return item

func _build_sandbag_positions() -> void:
	for position_data in [
		[Vector3(-18.0, 0.0, -9.0), 0.0, 8],
		[Vector3(11.0, 0.0, 7.0), 22.0, 7],
		[Vector3(35.0, 0.0, 17.0), -35.0, 9],
		[Vector3(-39.0, 0.0, 22.0), 12.0, 6]
	]:
		_create_sandbag_wall(
			Vector3(position_data[0]),
			float(position_data[1]),
			int(position_data[2])
		)

func _create_sandbag_wall(
	position_value: Vector3,
	yaw_degrees: float,
	bag_count: int
) -> void:
	var root := Node3D.new()
	root.name = "SandbagPosition"
	root.position = position_value
	root.rotation_degrees.y = yaw_degrees
	add_child(root)

	var sand := _material(
		"sandbag",
		Color(0.43, 0.37, 0.25),
		1.0
	)
	for row in range(2):
		var count := bag_count - row
		for index in range(count):
			var offset := (
				float(index) - float(count - 1) * 0.5
			) * 0.52
			var bag := _mesh_sandbag(
				root,
				Vector3(
					offset + (0.26 if row == 1 else 0.0),
					0.18 + float(row) * 0.25,
					0.0
				),
				sand,
				randf_range(-4.0, 4.0)
			)
			bag.scale.x = randf_range(0.92, 1.08)

func _build_crate_and_barrel_clusters() -> void:
	for cluster_position in [
		Vector3(-29.0, 0.0, -12.0),
		Vector3(21.0, 0.0, -20.0),
		Vector3(46.0, 0.0, -7.0),
		Vector3(17.0, 0.0, 32.0)
	]:
		var root := Node3D.new()
		root.name = "SupplyDetailCluster"
		root.position = cluster_position
		add_child(root)

		var wood := _material(
			"crate_wood",
			Color(0.28, 0.17, 0.085),
			0.93
		)
		var metal := _material(
			"barrel_metal",
			Color(0.18, 0.20, 0.19),
			0.55,
			0.55
		)

		for crate_index in range(3):
			var crate_position := Vector3(
				float(crate_index % 2) * 0.82,
				0.36 + float(crate_index / 2) * 0.72,
				float(crate_index % 2) * 0.25
			)
			_mesh_box(
				root,
				crate_position,
				Vector3(0.72, 0.68, 0.72),
				wood,
				Vector3(0.0, randf_range(-12.0, 12.0), 0.0)
			)
			_mesh_box(
				root,
				crate_position + Vector3(0.0, 0.0, -0.37),
				Vector3(0.08, 0.68, 0.03),
				_material(
					"crate_trim",
					Color(0.36, 0.22, 0.11),
					0.92
				)
			)

		for barrel_index in range(2):
			_mesh_cylinder(
				root,
				Vector3(
					-0.65 - float(barrel_index) * 0.52,
					0.48,
					0.12
				),
				0.24,
				0.95,
				metal
			)

func _build_rubble_fields() -> void:
	var masonry := _material(
		"rubble",
		Color(0.38, 0.34, 0.29),
		1.0
	)
	for center in [
		Vector3(-42.0, 0.05, -25.0),
		Vector3(-12.0, 0.05, 28.0),
		Vector3(42.0, 0.05, -28.0),
		Vector3(31.0, 0.05, 31.0)
	]:
		var root := Node3D.new()
		root.name = "RubbleField"
		root.position = center
		add_child(root)
		for rubble_index in range(22):
			_mesh_rubble(
				root,
				Vector3(
					randf_range(-2.2, 2.2),
					randf_range(0.04, 0.28),
					randf_range(-1.5, 1.5)
				),
				Vector3(
					randf_range(0.12, 0.55),
					randf_range(0.08, 0.32),
					randf_range(0.10, 0.45)
				),
				masonry,
				Vector3(
					randf_range(-35.0, 35.0),
					randf_range(0.0, 180.0),
					randf_range(-35.0, 35.0)
				)
			)

func _build_window_and_shutter_details() -> void:
	var frame := _material(
		"window_frame",
		Color(0.15, 0.11, 0.075),
		0.86
	)
	var glass := _material(
		"window_glass",
		Color(0.12, 0.18, 0.20, 0.72),
		0.18,
		0.12
	)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for facade_data in [
		[Vector3(-50.7, 2.3, -32.7), 8.0],
		[Vector3(-51.6, 2.4, -13.8), -4.0],
		[Vector3(-49.5, 2.2, 7.3), 7.0],
		[Vector3(46.7, 2.7, -24.0), -2.0]
	]:
		var root := Node3D.new()
		root.name = "FacadeWindowDetails"
		root.position = Vector3(facade_data[0])
		root.rotation_degrees.y = float(facade_data[1])
		add_child(root)

		for floor_index in range(2):
			for column_index in range(3):
				var window_position := Vector3(
					(float(column_index) - 1.0) * 2.1,
					float(floor_index) * 2.15,
					0.0
				)
				_mesh_box(
					root,
					window_position,
					Vector3(1.0, 1.35, 0.055),
					glass
				)
				_mesh_box(
					root,
					window_position + Vector3(-0.57, 0.0, 0.03),
					Vector3(0.12, 1.55, 0.10),
					frame,
					Vector3(0.0, 0.0, -4.0)
				)
				_mesh_box(
					root,
					window_position + Vector3(0.57, 0.0, 0.03),
					Vector3(0.12, 1.55, 0.10),
					frame,
					Vector3(0.0, 0.0, 4.0)
				)

func _build_street_furniture() -> void:
	var iron := _material(
		"street_iron",
		Color(0.08, 0.09, 0.085),
		0.50,
		0.65
	)
	var warm_glass := _material(
		"lamp_glass",
		Color(0.92, 0.68, 0.30),
		0.24
	)
	warm_glass.emission_enabled = true
	warm_glass.emission = Color(0.75, 0.38, 0.08)
	warm_glass.emission_energy_multiplier = 1.5

	for lamp_position in [
		Vector3(-28.0, 0.0, -2.0),
		Vector3(-4.0, 0.0, 18.0),
		Vector3(25.0, 0.0, -10.0),
		Vector3(42.0, 0.0, 12.0)
	]:
		var root := Node3D.new()
		root.name = "BlackoutStreetLamp"
		root.position = lamp_position
		add_child(root)
		_mesh_cylinder(
			root,
			Vector3(0.0, 2.4, 0.0),
			0.075,
			4.8,
			iron
		)
		_mesh_box(
			root,
			Vector3(0.0, 4.75, 0.0),
			Vector3(0.42, 0.52, 0.42),
			iron
		)
		_mesh_box(
			root,
			Vector3(0.0, 4.75, -0.215),
			Vector3(0.26, 0.32, 0.035),
			warm_glass
		)
