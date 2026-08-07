extends Node3D
class_name CinematicEnvironmentPass

const BUILD_SEED := 8602026

var _materials: Dictionary = {}
var _rng := RandomNumberGenerator.new()

func build() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_rng.seed = BUILD_SEED
	_build_facade_depth()
	_build_balconies()
	_build_street_lamps()
	_build_roof_silhouettes()
	_build_rubble_clusters()
	_build_road_wear()

func _material(
	key: String,
	color: Color,
	roughness: float = 0.9,
	metallic: float = 0.0,
	transparency: bool = false
) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if transparency:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[key] = material
	return material

func _box(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_degrees_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = position_value
	instance.rotation_degrees = rotation_degrees_value
	var box := BoxMesh.new()
	box.size = size
	instance.mesh = box
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance

func _cylinder(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_degrees_value: Vector3 = Vector3.ZERO,
	radial_segments: int = 12
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = position_value
	instance.rotation_degrees = rotation_degrees_value
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = radial_segments
	instance.mesh = cylinder
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _build_facade_depth() -> void:
	var stone := _material("facade_stone", Color(0.38, 0.36, 0.31), 0.98)
	var plaster := _material("facade_plaster", Color(0.54, 0.50, 0.42), 0.96)
	var dark_glass := _material(
		"window_glass",
		Color(0.055, 0.075, 0.083, 0.88),
		0.18,
		0.12,
		true
	)
	var door := _material("painted_door", Color(0.12, 0.09, 0.055), 0.84)

	for data in [
		[Vector3(46.0, 0.0, -27.0), -8.0],
		[Vector3(47.0, 0.0, -7.0), 5.0],
		[Vector3(46.0, 0.0, 14.0), -6.0],
		[Vector3(45.0, 0.0, 34.0), 8.0]
	]:
		var facade := Node3D.new()
		facade.name = "LayeredTownFacade"
		facade.position = Vector3(data[0])
		facade.rotation_degrees.y = float(data[1])
		add_child(facade)
		_box(facade, "PlasterFacadeInset", Vector3(0.0, 3.25, 0.0), Vector3(7.6, 6.5, 0.18), plaster)
		_box(facade, "StoneFacadeBase", Vector3(0.0, 0.48, -0.15), Vector3(8.1, 0.96, 0.38), stone)
		_box(facade, "RecessedDoor", Vector3(0.0, 1.25, -0.16), Vector3(1.35, 2.5, 0.16), door)
		_box(facade, "DoorLintel", Vector3(0.0, 2.62, -0.28), Vector3(1.8, 0.22, 0.38), stone)
		for floor_index in range(2):
			for side in [-1.0, 1.0]:
				var window_position := Vector3(side * 2.25, 2.15 + floor_index * 2.35, -0.18)
				_box(facade, "RecessedWindow", window_position, Vector3(1.05, 1.35, 0.12), dark_glass)
				_box(facade, "WindowSill", window_position + Vector3(0.0, -0.78, -0.15), Vector3(1.38, 0.16, 0.40), stone)
				_box(facade, "WindowLintel", window_position + Vector3(0.0, 0.78, -0.15), Vector3(1.42, 0.18, 0.36), stone)

func _build_balconies() -> void:
	var stone := _material("balcony_stone", Color(0.34, 0.33, 0.30), 0.98)
	var iron := _material("black_iron", Color(0.045, 0.05, 0.048), 0.43, 0.72)
	for position_value in [
		Vector3(45.55, 4.05, -26.5),
		Vector3(46.45, 4.05, 13.5),
		Vector3(-47.25, 4.1, -8.5),
		Vector3(-44.9, 4.1, 33.5)
	]:
		var balcony := Node3D.new()
		balcony.name = "PeriodIronBalcony"
		balcony.position = position_value
		add_child(balcony)
		_box(balcony, "BalconySlab", Vector3.ZERO, Vector3(2.5, 0.18, 1.0), stone)
		_box(balcony, "BalconyRailTop", Vector3(0.0, 0.92, -0.43), Vector3(2.45, 0.07, 0.07), iron)
		for index in range(7):
			var x := -1.12 + float(index) * 0.37
			_box(balcony, "BalconyIronPicket", Vector3(x, 0.48, -0.43), Vector3(0.045, 0.90, 0.045), iron)

func _build_street_lamps() -> void:
	var iron := _material("lamp_iron", Color(0.055, 0.06, 0.058), 0.40, 0.75)
	var glass := _material("lamp_glass", Color(0.91, 0.72, 0.42, 0.82), 0.16, 0.0, true)
	for position_value in [
		Vector3(-34.5, 0.0, -30.0),
		Vector3(-34.5, 0.0, 0.0),
		Vector3(-34.5, 0.0, 30.0),
		Vector3(34.5, 0.0, -30.0),
		Vector3(34.5, 0.0, 0.0),
		Vector3(34.5, 0.0, 30.0)
	]:
		var lamp_root := Node3D.new()
		lamp_root.name = "PeriodStreetLamp"
		lamp_root.position = position_value
		add_child(lamp_root)
		_cylinder(lamp_root, "LampPost", Vector3(0.0, 2.3, 0.0), 0.065, 4.6, iron)
		_cylinder(lamp_root, "LampFoot", Vector3(0.0, 0.14, 0.0), 0.20, 0.28, iron)
		_box(lamp_root, "LampArm", Vector3(0.34, 4.35, 0.0), Vector3(0.72, 0.07, 0.07), iron, Vector3(0.0, 0.0, -10.0))
		_box(lamp_root, "LampGlass", Vector3(0.66, 4.08, 0.0), Vector3(0.32, 0.52, 0.32), glass)
		var light := OmniLight3D.new()
		light.name = "WarmLampLight"
		light.position = Vector3(0.66, 4.05, 0.0)
		light.light_color = Color(1.0, 0.67, 0.33)
		light.light_energy = 0.72
		light.omni_range = 6.5
		light.shadow_enabled = false
		lamp_root.add_child(light)

func _build_roof_silhouettes() -> void:
	var brick := _material("chimney_brick", Color(0.31, 0.105, 0.055), 0.98)
	var metal := _material("roof_metal", Color(0.075, 0.08, 0.08), 0.55, 0.58)
	for position_value in [
		Vector3(-50.5, 8.3, -27.0), Vector3(-51.0, 8.4, 13.0),
		Vector3(46.0, 7.4, -27.0), Vector3(46.0, 7.4, 14.0)
	]:
		_box(self, "BrickChimney", position_value, Vector3(0.72, 2.0, 0.72), brick)
		_box(self, "ChimneyCap", position_value + Vector3(0.0, 1.08, 0.0), Vector3(0.94, 0.18, 0.94), metal)

func _build_rubble_clusters() -> void:
	var stone := _material("rubble_stone", Color(0.31, 0.29, 0.25), 0.99)
	var brick := _material("rubble_brick", Color(0.34, 0.105, 0.055), 0.98)
	for center in [
		Vector3(-38.0, 0.0, -20.0), Vector3(-39.0, 0.0, 21.0),
		Vector3(38.0, 0.0, -18.0), Vector3(39.0, 0.0, 23.0),
		Vector3(-13.0, 0.0, -34.0), Vector3(15.0, 0.0, 35.0)
	]:
		var cluster := Node3D.new()
		cluster.name = "BattleDamageRubbleCluster"
		cluster.position = center
		add_child(cluster)
		for index in range(11):
			var size := Vector3(
				_rng.randf_range(0.18, 0.68),
				_rng.randf_range(0.10, 0.40),
				_rng.randf_range(0.18, 0.62)
			)
			_box(
				cluster,
				"BrokenBrick" if index % 3 else "BrokenStone",
				Vector3(_rng.randf_range(-1.25, 1.25), size.y * 0.5, _rng.randf_range(-0.75, 0.75)),
				size,
				brick if index % 3 else stone,
				Vector3(_rng.randf_range(-20.0, 20.0), _rng.randf_range(0.0, 180.0), _rng.randf_range(-20.0, 20.0))
			)

func _build_road_wear() -> void:
	var puddle := _material("road_puddle", Color(0.035, 0.055, 0.06, 0.72), 0.12, 0.0, true)
	var tar := _material("road_repair", Color(0.075, 0.068, 0.058), 0.96)
	for data in [
		[Vector3(-18.0, 0.035, -8.0), Vector3(3.4, 0.025, 1.3), -12.0],
		[Vector3(17.0, 0.035, 7.5), Vector3(2.8, 0.025, 1.1), 9.0],
		[Vector3(-8.0, 0.035, 30.0), Vector3(2.1, 0.025, 0.85), 18.0]
	]:
		_box(self, "RainPuddle", Vector3(data[0]), Vector3(data[1]), puddle, Vector3(0.0, float(data[2]), 0.0))
	for data in [
		[Vector3(-23.0, 0.03, 13.0), Vector3(0.28, 0.035, 7.0), -18.0],
		[Vector3(22.0, 0.03, -12.0), Vector3(0.25, 0.035, 6.5), 14.0]
	]:
		_box(self, "RoadRepairSeam", Vector3(data[0]), Vector3(data[1]), tar, Vector3(0.0, float(data[2]), 0.0))
