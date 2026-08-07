extends Node3D
class_name UrbanRealismPass

func build() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_build_townhouse_details()
	_build_roofline_details()
	_build_masonry_damage()
	_build_street_edges()

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
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_y: float = 0.0
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_value
	mesh_instance.position = position_value
	mesh_instance.rotation.y = rotation_y
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance

func _build_townhouse_details() -> void:
	var stone := _material(Color(0.47,0.43,0.35),0.98)
	var dark_wood := _material(Color(0.13,0.07,0.03),0.88)
	var glass := _material(Color(0.08,0.13,0.16,0.72),0.20)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for data in [
		[Vector3(-51.0,0.0,-27.0),deg_to_rad(8.0),8.0],
		[Vector3(-52.0,0.0,-8.0),deg_to_rad(-4.0),8.4],
		[Vector3(-50.0,0.0,13.0),deg_to_rad(7.0),8.0],
		[Vector3(-49.0,0.0,34.0),deg_to_rad(-9.0),8.3]
	]:
		var root := Node3D.new()
		root.name = "TownhouseArchitecturalDetails"
		root.position = Vector3(data[0])
		root.rotation.y = float(data[1])
		add_child(root)

		_box(root,"StoneFoundation",Vector3(0.0,0.42,-3.04),
			Vector3(float(data[2]),0.84,0.22),stone)
		for floor_index in range(2):
			for column_index in range(3):
				var x := (float(column_index)-1.0)*2.05
				var y := 2.05+float(floor_index)*2.25
				_box(root,"WindowGlass",Vector3(x,y,-3.17),
					Vector3(0.92,1.22,0.05),glass)
				_box(root,"WindowLintel",Vector3(x,y+0.69,-3.20),
					Vector3(1.18,0.16,0.16),stone)
				_box(root,"WindowSill",Vector3(x,y-0.69,-3.20),
					Vector3(1.12,0.14,0.18),stone)
				_box(root,"ShutterL",Vector3(x-0.58,y,-3.22),
					Vector3(0.18,1.34,0.10),dark_wood)
				_box(root,"ShutterR",Vector3(x+0.58,y,-3.22),
					Vector3(0.18,1.34,0.10),dark_wood)

func _build_roofline_details() -> void:
	var roof := _material(Color(0.075,0.085,0.09),0.92)
	var metal := _material(Color(0.10,0.11,0.11),0.54,0.58)
	for data in [
		[Vector3(-51.0,7.55,-27.0),deg_to_rad(8.0),8.4],
		[Vector3(-52.0,7.65,-8.0),deg_to_rad(-4.0),8.7],
		[Vector3(-50.0,7.55,13.0),deg_to_rad(7.0),8.4],
		[Vector3(-49.0,7.65,34.0),deg_to_rad(-9.0),8.7]
	]:
		var root := Node3D.new()
		root.position = Vector3(data[0])
		root.rotation.y = float(data[1])
		add_child(root)
		_box(root,"RoofCornice",Vector3(0.0,0.0,-3.10),
			Vector3(float(data[2]),0.24,0.34),roof)
		_box(root,"RainGutter",Vector3(0.0,-0.20,-3.30),
			Vector3(float(data[2]),0.10,0.10),metal)

func _build_masonry_damage() -> void:
	var exposed_brick := _material(Color(0.42,0.13,0.075),0.97)
	var soot := _material(Color(0.035,0.03,0.025,0.72),1.0)
	soot.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for data in [
		[Vector3(-53.0,3.6,-30.2),0.15],
		[Vector3(-49.6,4.2,-11.3),-0.12],
		[Vector3(-51.2,2.8,9.8),0.10],
		[Vector3(-47.2,4.7,30.7),-0.14]
	]:
		var patch := Node3D.new()
		patch.position = Vector3(data[0])
		patch.rotation.z = float(data[1])
		add_child(patch)
		_box(patch,"ExposedBrickPatch",Vector3.ZERO,
			Vector3(1.35,1.65,0.055),exposed_brick)
		_box(patch,"SootEdge",Vector3(0.0,0.12,-0.035),
			Vector3(1.65,1.90,0.025),soot)

func _build_street_edges() -> void:
	var curb := _material(Color(0.40,0.39,0.35),0.98)
	for z_value in [-39.0,-18.0,3.0,24.0,45.0]:
		_box(self,"StoneCurb",Vector3(-41.5,0.16,z_value),
			Vector3(0.34,0.32,16.0),curb)
