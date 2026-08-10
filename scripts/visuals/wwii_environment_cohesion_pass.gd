extends Node
class_name WWIIEnvironmentCohesionPass

var world_root: Node
var holder: Node3D
var detail_nodes: Array[GeometryInstance3D] = []
var update_accumulator := 0.0

var brick_material: StandardMaterial3D
var stone_material: StandardMaterial3D
var concrete_material: StandardMaterial3D
var wood_material: StandardMaterial3D
var metal_material: StandardMaterial3D
var curb_material: StandardMaterial3D


static func apply(root: Node) -> void:
	if root == null or DisplayServer.get_name() == "headless":
		return
	if root.has_node("WWIIEnvironmentCohesionPass_v918"):
		return

	var pass := WWIIEnvironmentCohesionPass.new()
	pass.name = "WWIIEnvironmentCohesionPass_v918"
	root.add_child(pass)
	pass._initialize(root)


func _initialize(root: Node) -> void:
	world_root = root

	holder = Node3D.new()
	holder.name = "EnvironmentCohesionDetail"
	add_child(holder)

	brick_material = _material(
		Color(0.30, 0.125, 0.075),
		0.95,
		0.0
	)
	stone_material = _material(
		Color(0.39, 0.38, 0.34),
		0.98,
		0.0
	)
	concrete_material = _material(
		Color(0.30, 0.31, 0.30),
		0.94,
		0.0
	)
	wood_material = _material(
		Color(0.20, 0.145, 0.085),
		0.92,
		0.0
	)
	metal_material = _material(
		Color(0.16, 0.17, 0.16),
		0.72,
		0.58
	)
	curb_material = _material(
		Color(0.34, 0.34, 0.31),
		0.98,
		0.0
	)

	_retune_existing_world_materials()
	_build_street_definition()
	_build_wall_caps_and_posts()
	_build_facade_depth_cues()
	_apply_quality()


func _process(delta: float) -> void:
	update_accumulator += delta
	if update_accumulator < 0.65:
		return
	update_accumulator = 0.0
	_apply_quality()


func _quality_preset() -> int:
	if world_root == null:
		return 1

	var manager_value: Variant = world_root.get(
		"visual_quality_manager"
	)
	if manager_value == null:
		return 1

	var manager := manager_value as Node
	if manager == null:
		return 1

	var preset_value: Variant = manager.get("current_preset")
	if preset_value == null:
		return 1

	return clampi(int(preset_value), 0, 2)


func _material(
	color: Color,
	roughness: float,
	metallic: float
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


func _retune_existing_world_materials() -> void:
	# Only alter already-existing StandardMaterial3D overrides. This preserves
	# imported PBR texture sets and avoids touching players/weapons/vehicles.
	for node: Node in world_root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null:
			continue

		var key := mesh_instance.name.to_lower()
		if _skip_runtime_mesh(key):
			continue

		var existing := mesh_instance.material_override
		if not existing is StandardMaterial3D:
			continue

		var original := existing as StandardMaterial3D
		var tuned := original.duplicate() as StandardMaterial3D
		if tuned == null:
			continue

		var tint := Color.WHITE
		var minimum_roughness := 0.78

		if (
			"brick" in key
			or "townhouse" in key
			or "ruin" in key
		):
			tint = Color(0.78, 0.65, 0.58)
			minimum_roughness = 0.92
		elif (
			"concrete" in key
			or "bunker" in key
			or "fort" in key
		):
			tint = Color(0.72, 0.74, 0.72)
			minimum_roughness = 0.90
		elif (
			"road" in key
			or "ground" in key
			or "street" in key
			or "cobble" in key
		):
			tint = Color(0.70, 0.70, 0.66)
			minimum_roughness = 0.96
		elif (
			"roof" in key
			or "slate" in key
		):
			tint = Color(0.54, 0.56, 0.56)
			minimum_roughness = 0.94
		elif (
			"wood" in key
			or "crate" in key
			or "timber" in key
		):
			tint = Color(0.72, 0.62, 0.50)
			minimum_roughness = 0.90
		else:
			continue

		tuned.albedo_color = Color(
			tuned.albedo_color.r * tint.r,
			tuned.albedo_color.g * tint.g,
			tuned.albedo_color.b * tint.b,
			tuned.albedo_color.a
		)
		tuned.roughness = maxf(
			tuned.roughness,
			minimum_roughness
		)
		mesh_instance.material_override = tuned


func _skip_runtime_mesh(key: String) -> bool:
	var blocked: Array[String] = [
		"player",
		"weapon",
		"arm",
		"hand",
		"vehicle",
		"jeep",
		"sherman",
		"spitfire",
		"bf109",
		"marker",
		"tracer",
		"pickup",
		"grenade",
		"muzzle",
		"shell",
		"hud",
		"radar"
	]
	for token: String in blocked:
		if token in key:
			return true
	return false


func _box(
	node_name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	yaw_degrees: float = 0.0,
	range_end: float = 55.0
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name

	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees.y = yaw_degrees
	instance.material_override = material
	instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	instance.visibility_range_end = range_end
	instance.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	)

	holder.add_child(instance)
	detail_nodes.append(instance)
	return instance


func _cylinder(
	node_name: String,
	position: Vector3,
	radius: float,
	height: float,
	material: Material,
	range_end: float = 48.0
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.08
	mesh.height = height
	mesh.radial_segments = 8
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	instance.visibility_range_end = range_end

	holder.add_child(instance)
	detail_nodes.append(instance)
	return instance


func _build_street_definition() -> void:
	# Thin curb/edge strips help the large flat roads read as streets without
	# adding collision or high-poly terrain.
	var curb_segments: Array[Dictionary] = [
		{
			"p": Vector3(-22.0, 0.075, -11.7),
			"s": Vector3(42.0, 0.15, 0.28)
		},
		{
			"p": Vector3(-22.0, 0.075, 11.7),
			"s": Vector3(42.0, 0.15, 0.28)
		},
		{
			"p": Vector3(22.0, 0.075, -11.7),
			"s": Vector3(42.0, 0.15, 0.28)
		},
		{
			"p": Vector3(22.0, 0.075, 11.7),
			"s": Vector3(42.0, 0.15, 0.28)
		},
		{
			"p": Vector3(-8.8, 0.075, 0.0),
			"s": Vector3(0.28, 0.15, 22.0)
		},
		{
			"p": Vector3(8.8, 0.075, 0.0),
			"s": Vector3(0.28, 0.15, 22.0)
		}
	]

	for index: int in range(curb_segments.size()):
		var entry: Dictionary = curb_segments[index]
		_box(
			"StreetCurb_%02d" % index,
			Vector3(entry["p"]),
			Vector3(entry["s"]),
			curb_material,
			0.0,
			64.0
		)


func _build_wall_caps_and_posts() -> void:
	# Repeated short masonry details break up long featureless silhouettes.
	var cap_positions: Array[Vector3] = [
		Vector3(-31.0, 1.85, -15.0),
		Vector3(-25.0, 1.85, -15.0),
		Vector3(-19.0, 1.85, -15.0),
		Vector3(19.0, 1.85, 15.0),
		Vector3(25.0, 1.85, 15.0),
		Vector3(31.0, 1.85, 15.0)
	]

	for index: int in range(cap_positions.size()):
		_cylinder(
			"MasonryPost_%02d" % index,
			cap_positions[index],
			0.12,
			1.65,
			stone_material,
			48.0
		)

	var timber_positions: Array[Vector3] = [
		Vector3(-13.5, 1.05, -18.5),
		Vector3(-10.5, 1.05, -18.5),
		Vector3(10.5, 1.05, 18.5),
		Vector3(13.5, 1.05, 18.5)
	]

	for index: int in range(timber_positions.size()):
		_box(
			"TimberBrace_%02d" % index,
			timber_positions[index],
			Vector3(0.18, 2.05, 0.18),
			wood_material,
			12.0 if index % 2 == 0 else -12.0,
			44.0
		)


func _build_facade_depth_cues() -> void:
	# Dark inset panels and lintels are deliberately shallow/non-colliding.
	# They visually read as windows/door recesses on otherwise flat facades.
	var facade_entries: Array[Dictionary] = [
		{"p": Vector3(-37.4, 2.55, -8.2), "yaw": 90.0},
		{"p": Vector3(-37.4, 2.55, -2.8), "yaw": 90.0},
		{"p": Vector3(-37.4, 2.55, 3.0), "yaw": 90.0},
		{"p": Vector3(37.4, 2.55, -3.0), "yaw": 90.0},
		{"p": Vector3(37.4, 2.55, 2.8), "yaw": 90.0},
		{"p": Vector3(37.4, 2.55, 8.2), "yaw": 90.0}
	]

	for index: int in range(facade_entries.size()):
		var entry: Dictionary = facade_entries[index]
		_box(
			"FacadeRecess_%02d" % index,
			Vector3(entry["p"]),
			Vector3(1.35, 1.55, 0.09),
			metal_material,
			float(entry["yaw"]),
			46.0
		)

		_box(
			"FacadeLintel_%02d" % index,
			Vector3(entry["p"]) + Vector3(0.0, 0.92, 0.0),
			Vector3(1.65, 0.14, 0.16),
			stone_material,
			float(entry["yaw"]),
			46.0
		)


func _apply_quality() -> void:
	var quality := _quality_preset()

	for geometry: GeometryInstance3D in detail_nodes:
		if geometry == null or not is_instance_valid(geometry):
			continue

		var key := geometry.name
		var is_facade := "Facade" in key
		var is_minor := (
			"TimberBrace" in key
			or "MasonryPost" in key
		)

		if quality == 0:
			# Low keeps street definition but drops small architectural clutter.
			geometry.visible = not is_facade and not is_minor
			geometry.visibility_range_end = minf(
				geometry.visibility_range_end,
				34.0
			)
		elif quality == 1:
			geometry.visible = true
			if is_facade:
				geometry.visibility_range_end = 42.0
			elif is_minor:
				geometry.visibility_range_end = 45.0
		else:
			geometry.visible = true
			if is_facade:
				geometry.visibility_range_end = 60.0
			elif is_minor:
				geometry.visibility_range_end = 58.0
