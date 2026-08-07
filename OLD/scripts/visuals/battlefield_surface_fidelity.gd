extends Node3D
class_name BattlefieldSurfaceFidelity

var material_cache: Dictionary = {}

func build() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_build_railway_infrastructure()
	_build_road_surface_wear()
	_build_village_facade_depth()
	_build_fortification_hardware()
	_build_period_wayfinding()
	_build_battlefield_clutter()

func _material(
	key: String,
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	if material_cache.has(key):
		return material_cache[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material_cache[key] = material
	return material

func _box(
	parent: Node3D,
	item_name: String,
	position_value: Vector3,
	size_value: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = item_name
	item.position = position_value
	item.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	item.mesh = mesh
	item.material_override = material
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	item.visibility_range_end = 115.0
	item.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(item)
	return item

func _cylinder(
	parent: Node3D,
	item_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO,
	segments: int = 16
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = item_name
	item.position = position_value
	item.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	item.mesh = mesh
	item.material_override = material
	item.visibility_range_end = 105.0
	item.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(item)
	return item

func _rounded_stone(
	parent: Node3D,
	position_value: Vector3,
	scale_value: Vector3,
	rotation_value: Vector3,
	material: Material
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = "RoundedBattleRubble"
	item.position = position_value
	item.scale = scale_value
	item.rotation_degrees = rotation_value
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 10
	mesh.rings = 5
	item.mesh = mesh
	item.material_override = material
	item.visibility_range_end = 75.0
	item.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	parent.add_child(item)
	return item

func _build_railway_infrastructure() -> void:
	var root := Node3D.new()
	root.name = "DetailedRailInfrastructure"
	add_child(root)
	var timber := _material("sleeper", Color(0.145, 0.078, 0.035), 0.94)
	var steel := _material("rail_steel", Color(0.095, 0.105, 0.105), 0.38, 0.82)
	var rust := _material("rail_rust", Color(0.25, 0.075, 0.025), 0.74, 0.48)
	var ballast := _material("ballast", Color(0.29, 0.28, 0.25), 0.99)
	for track_z in [-22.45, -18.95, -15.45]:
		_box(root, "GradedBallastBed", Vector3(25.0, 0.09, track_z), Vector3(38.0, 0.12, 2.25), ballast)
		for sleeper_index in range(28):
			var sleeper_x := 7.0 + float(sleeper_index) * 1.34
			_box(root, "CreosoteRailSleeper", Vector3(sleeper_x, 0.18, track_z), Vector3(0.28, 0.16, 2.15), timber)
			for spike_z in [-0.56, 0.56]:
				_cylinder(root, "RailSpike", Vector3(sleeper_x, 0.31, track_z + spike_z), 0.035, 0.12, rust, Vector3.ZERO, 8)
		for rail_offset in [-0.55, 0.55]:
			_box(root, "RolledSteelRail", Vector3(25.0, 0.35, track_z + rail_offset), Vector3(38.0, 0.13, 0.11), steel)
			_box(root, "RustRailWeb", Vector3(25.0, 0.27, track_z + rail_offset), Vector3(38.0, 0.10, 0.055), rust)

func _build_road_surface_wear() -> void:
	var root := Node3D.new()
	root.name = "RoadSurfaceWear"
	add_child(root)
	var damp := _material("damp_rut", Color(0.09, 0.075, 0.055, 0.72), 0.32)
	damp.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var repair := _material("road_repair", Color(0.115, 0.105, 0.09), 0.97)
	for x_value in [-0.95, 0.95]:
		_box(root, "VehicleWheelRut", Vector3(x_value, 0.115, -31.0), Vector3(0.22, 0.022, 47.0), damp, Vector3(0.0, -1.5, 0.0))
		_box(root, "VehicleWheelRut", Vector3(x_value, 0.115, 35.0), Vector3(0.24, 0.022, 48.0), damp, Vector3(0.0, 2.0, 0.0))
	for patch_data in [
		[Vector3(-12.0, 0.13, -29.5), Vector3(5.5, 0.035, 1.0), -7.0],
		[Vector3(9.0, 0.13, -32.0), Vector3(4.2, 0.035, 0.8), 5.0],
		[Vector3(-18.0, 0.13, 34.0), Vector3(6.0, 0.035, 0.9), -4.0],
		[Vector3(15.0, 0.13, 36.0), Vector3(5.0, 0.035, 0.75), 8.0]
	]:
		_box(root, "PeriodRoadRepair", Vector3(patch_data[0]), Vector3(patch_data[1]), repair, Vector3(0.0, float(patch_data[2]), 0.0))

func _build_village_facade_depth() -> void:
	var root := Node3D.new()
	root.name = "VillageFacadeDepth"
	add_child(root)
	var wood := _material("painted_frame", Color(0.105, 0.055, 0.025), 0.88)
	var glass := _material("aged_glass", Color(0.075, 0.14, 0.17, 0.58), 0.16, 0.08)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var brass := _material("brass", Color(0.30, 0.20, 0.07), 0.42, 0.72)
	for facade_data in [
		[Vector3(-51.0, 0.0, -27.0), 8.0],
		[Vector3(-52.0, 0.0, -8.0), -4.0],
		[Vector3(-50.0, 0.0, 13.0), 7.0],
		[Vector3(-49.0, 0.0, 34.0), -9.0]
	]:
		var facade := Node3D.new()
		facade.name = "DimensionalWindowFittings"
		facade.position = Vector3(facade_data[0])
		facade.rotation_degrees.y = float(facade_data[1])
		root.add_child(facade)
		for floor_index in range(2):
			for column_index in range(3):
				var window_x := (float(column_index) - 1.0) * 2.05
				var window_y := 2.05 + float(floor_index) * 2.25
				_box(facade, "RecessedWindowPane", Vector3(window_x, window_y, -3.205), Vector3(0.86, 1.15, 0.025), glass)
				_box(facade, "WindowCenterMullion", Vector3(window_x, window_y, -3.235), Vector3(0.055, 1.18, 0.07), wood)
				_box(facade, "WindowCrossMullion", Vector3(window_x, window_y, -3.235), Vector3(0.88, 0.055, 0.07), wood)
		_cylinder(facade, "PeriodDoorKnob", Vector3(0.30, 1.05, -3.31), 0.055, 0.07, brass, Vector3(90.0, 0.0, 0.0), 12)

func _build_fortification_hardware() -> void:
	var root := Node3D.new()
	root.name = "FortificationHardware"
	add_child(root)
	var steel := _material("fort_steel", Color(0.105, 0.115, 0.11), 0.52, 0.70)
	var concrete := _material("fort_concrete", Color(0.31, 0.31, 0.285), 0.98)
	for bunker_data in [
		[Vector3(33.0, 1.55, 24.35), 0.0],
		[Vector3(42.0, 1.55, 46.25), 180.0]
	]:
		var bunker := Node3D.new()
		bunker.name = "BunkerEmbrasureAssembly"
		bunker.position = Vector3(bunker_data[0])
		bunker.rotation_degrees.y = float(bunker_data[1])
		root.add_child(bunker)
		_box(bunker, "EmbrasureUpperLip", Vector3(0.0, 0.62, 0.0), Vector3(3.4, 0.28, 0.38), concrete)
		_box(bunker, "EmbrasureLowerLip", Vector3(0.0, -0.62, 0.0), Vector3(3.4, 0.28, 0.38), concrete)
		_box(bunker, "ArmoredShutterLeft", Vector3(-1.26, 0.0, -0.08), Vector3(0.13, 1.05, 0.16), steel)
		_box(bunker, "ArmoredShutterRight", Vector3(1.26, 0.0, -0.08), Vector3(0.13, 1.05, 0.16), steel)
		for bolt_x in [-1.28, 1.28]:
			for bolt_y in [-0.40, 0.40]:
				_cylinder(bunker, "ArmoredShutterBolt", Vector3(bolt_x, bolt_y, -0.19), 0.045, 0.05, steel, Vector3(90.0, 0.0, 0.0), 10)

func _build_period_wayfinding() -> void:
	var root := Node3D.new()
	root.name = "PeriodWayfinding"
	add_child(root)
	var board := _material("sign_board", Color(0.22, 0.13, 0.055), 0.92)
	var paint := Color(0.84, 0.78, 0.61)
	for sign_data in [
		["VILLAGE", Vector3(-22.0, 2.1, -27.8), 0.0],
		["RAIL DEPOT", Vector3(14.0, 2.1, -27.5), 0.0],
		["FORT", Vector3(27.0, 2.1, 16.3), 22.0]
	]:
		var sign_root := Node3D.new()
		sign_root.name = "DimensionalDirectionSign"
		sign_root.position = Vector3(sign_data[1])
		sign_root.rotation_degrees.y = float(sign_data[2])
		root.add_child(sign_root)
		_box(sign_root, "TimberSignBoard", Vector3.ZERO, Vector3(2.55, 0.62, 0.12), board)
		_box(sign_root, "TimberSignPost", Vector3(0.0, -1.0, 0.08), Vector3(0.14, 1.75, 0.14), board)
		var label := Label3D.new()
		label.name = "PaintedSignLettering"
		label.text = str(sign_data[0])
		label.position = Vector3(0.0, 0.0, -0.075)
		label.font_size = 34
		label.outline_size = 4
		label.modulate = paint
		label.outline_modulate = Color(0.06, 0.035, 0.015)
		label.visibility_range_end = 70.0
		sign_root.add_child(label)

func _build_battlefield_clutter() -> void:
	var root := Node3D.new()
	root.name = "RoundedBattlefieldClutter"
	add_child(root)
	var stone := _material("rubble_stone", Color(0.37, 0.345, 0.295), 0.99)
	var brick := _material("broken_brick", Color(0.39, 0.115, 0.055), 0.98)
	var positions: Array[Vector3] = [
		Vector3(-38.0, 0.18, -22.0), Vector3(-39.2, 0.15, -21.6),
		Vector3(-34.0, 0.16, 18.0), Vector3(-32.8, 0.14, 18.5),
		Vector3(18.0, 0.15, -10.0), Vector3(19.1, 0.17, -9.6),
		Vector3(38.0, 0.16, 31.0), Vector3(39.0, 0.13, 31.4)
	]
	for index in range(positions.size()):
		var scale_value := Vector3(0.62 + float(index % 3) * 0.13, 0.30, 0.48 + float(index % 2) * 0.12)
		_rounded_stone(root, positions[index], scale_value, Vector3(12.0 * float(index % 4), 31.0 * float(index), 8.0), stone if index % 2 == 0 else brick)
