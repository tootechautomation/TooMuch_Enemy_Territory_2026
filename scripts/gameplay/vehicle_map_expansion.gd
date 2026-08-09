extends Node
class_name VehicleMapExpansion

var world_root: Node

func initialize(root: Node) -> void:
	world_root = root
	call_deferred("_build")

func _build() -> void:
	_disable_old_boundaries()
	_build_ground()
	_build_airstrip()
	_build_roads()
	_build_boundaries()

func _disable_old_boundaries() -> void:
	for name: String in [
		"BoundaryWest","BoundaryEast","BoundaryNorth","BoundarySouth",
		"OuterBoundaryWest","OuterBoundaryEast","OuterBoundaryNorth","OuterBoundarySouth"
	]:
		var node := world_root.find_child(name, true, false)
		if node == null:
			continue
		for child: Node in node.get_children():
			if child is CollisionShape3D:
				(child as CollisionShape3D).set_deferred("disabled", true)
		if node is GeometryInstance3D:
			(node as GeometryInstance3D).visible = false

func _build_ground() -> void:
	var ground := _mat(Color(0.18,0.20,0.15))
	for data: Array in [
		["VehicleGroundWest",Vector3(-88,-0.62,0),Vector3(42,1.2,150)],
		["VehicleGroundEast",Vector3(88,-0.62,0),Vector3(42,1.2,150)],
		["VehicleGroundNorth",Vector3(0,-0.62,-70),Vector3(176,1.2,30)],
		["VehicleGroundSouth",Vector3(0,-0.62,70),Vector3(176,1.2,30)]
	]:
		_static_box(str(data[0]),Vector3(data[1]),Vector3(data[2]),ground,true)

func _build_airstrip() -> void:
	var runway := _mat(Color(0.20,0.20,0.19))
	var stripe := _mat(Color(0.72,0.69,0.54))
	_static_box("Airstrip",Vector3(0,0.02,70),Vector3(16,0.12,110),runway,true)
	for offset in range(-48,49,8):
		_static_box(
			"RunwayStripe",
			Vector3(0,0.10,70+float(offset)),
			Vector3(0.38,0.04,3.2),
			stripe,
			true
		)

func _build_roads() -> void:
	var road := _mat(Color(0.22,0.22,0.20))
	_static_box("VehicleRoadWest",Vector3(-82,0.01,0),Vector3(12,0.10,120),road,true)
	_static_box("VehicleRoadEast",Vector3(82,0.01,0),Vector3(12,0.10,120),road,true)
	_static_box("VehicleRoadCross",Vector3(0,0.01,48),Vector3(170,0.10,10),road,true)

func _build_boundaries() -> void:
	var invisible := _mat(Color(0,0,0,0))
	for data: Array in [
		["VehicleBoundaryWest",Vector3(-112,4,0),Vector3(1,8,180)],
		["VehicleBoundaryEast",Vector3(112,4,0),Vector3(1,8,180)],
		["VehicleBoundaryNorth",Vector3(0,4,-90),Vector3(224,8,1)],
		["VehicleBoundarySouth",Vector3(0,4,90),Vector3(224,8,1)]
	]:
		_static_box(str(data[0]),Vector3(data[1]),Vector3(data[2]),invisible,false)

func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.97
	if color.a < 0.01:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _static_box(
	node_name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	visible_mesh: bool
) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	world_root.add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	if visible_mesh:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = size
		mi.mesh = mesh
		mi.material_override = material
		body.add_child(mi)
