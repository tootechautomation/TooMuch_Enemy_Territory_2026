extends Node

var world_root: Node = null
var route_holder: Node3D = null
var route_nodes: Array[Node] = []
var update_accumulator: float = 0.0


static func apply(root: Node) -> void:
	if root == null:
		return
	if DisplayServer.get_name() == "headless":
		return
	if root.has_node("VisibilityRouteReadabilityPass_v919"):
		return

	var script_resource: Script = load(
		"res://scripts/visuals/visibility_route_readability_pass.gd"
	)
	if script_resource == null:
		return

	var pass_node: Node = script_resource.new()
	pass_node.name = "VisibilityRouteReadabilityPass_v919"
	root.add_child(pass_node)
	pass_node.call("_initialize", root)


func _initialize(root: Node) -> void:
	world_root = root
	route_holder = Node3D.new()
	route_holder.name = "RouteReadabilityDetail"
	add_child(route_holder)

	_build_route_edges()
	_apply_visibility_profile()


func _process(delta: float) -> void:
	update_accumulator += delta
	if update_accumulator < 0.75:
		return

	update_accumulator = 0.0
	_apply_visibility_profile()


func _quality_preset() -> int:
	if world_root == null:
		return 1

	var manager_value: Variant = world_root.get(
		"visual_quality_manager"
	)
	if manager_value == null:
		return 1

	var manager: Node = manager_value as Node
	if manager == null:
		return 1

	var preset_value: Variant = manager.get("current_preset")
	if preset_value == null:
		return 1

	return clampi(int(preset_value), 0, 2)


func _apply_visibility_profile() -> void:
	if world_root == null:
		return

	var quality: int = _quality_preset()

	var environment_value: Variant = world_root.get(
		"battlefield_environment"
	)
	if environment_value != null:
		var environment: Environment = environment_value as Environment
		if environment != null:
			environment.adjustment_enabled = true

			if quality == 0:
				# Laptop: prioritize clear silhouettes and remove costly
				# volumetric haze entirely.
				environment.adjustment_contrast = 1.10
				environment.adjustment_saturation = 0.88
				environment.adjustment_brightness = 0.98
				environment.fog_enabled = true
				environment.fog_density = 0.0035
				environment.fog_light_energy = 0.48
				environment.volumetric_fog_enabled = false
				environment.glow_enabled = false
				environment.ambient_light_energy = 0.78

			elif quality == 1:
				# Balanced: light atmospheric depth without washing the map.
				environment.adjustment_contrast = 1.12
				environment.adjustment_saturation = 0.86
				environment.adjustment_brightness = 0.97
				environment.fog_enabled = true
				environment.fog_density = 0.0048
				environment.fog_light_energy = 0.50
				environment.volumetric_fog_enabled = true
				environment.volumetric_fog_density = 0.0065
				environment.volumetric_fog_length = 58.0
				environment.glow_enabled = true
				environment.glow_intensity = 0.30
				environment.ambient_light_energy = 0.82

			else:
				# High: richer atmosphere, still substantially clearer than the
				# older 0.018 volumetric density.
				environment.adjustment_contrast = 1.13
				environment.adjustment_saturation = 0.88
				environment.adjustment_brightness = 0.98
				environment.fog_enabled = true
				environment.fog_density = 0.0055
				environment.fog_light_energy = 0.54
				environment.volumetric_fog_enabled = true
				environment.volumetric_fog_density = 0.0085
				environment.volumetric_fog_length = 66.0
				environment.glow_enabled = true
				environment.glow_intensity = 0.38
				environment.ambient_light_energy = 0.86

	var sun_value: Variant = world_root.get("battlefield_sun")
	if sun_value != null:
		var sun: DirectionalLight3D = sun_value as DirectionalLight3D
		if sun != null:
			if quality == 0:
				sun.light_energy = 1.08
				sun.shadow_enabled = false
				sun.directional_shadow_max_distance = 54.0
			elif quality == 1:
				sun.light_energy = 1.14
				sun.shadow_enabled = true
				sun.directional_shadow_max_distance = 68.0
			else:
				sun.light_energy = 1.20
				sun.shadow_enabled = true
				sun.directional_shadow_max_distance = 82.0

	for route_node: Node in route_nodes:
		if route_node == null:
			continue
		if not is_instance_valid(route_node):
			continue

		var geometry: GeometryInstance3D = (
			route_node as GeometryInstance3D
		)
		if geometry == null:
			continue

		if quality == 0:
			geometry.visibility_range_end = 30.0
		elif quality == 1:
			geometry.visibility_range_end = 45.0
		else:
			geometry.visibility_range_end = 58.0


func _route_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.30, 0.29, 0.25)
	material.roughness = 0.98
	return material


func _marker_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.22, 0.20, 0.16)
	material.roughness = 0.94
	return material


func _add_box(
	node_name: String,
	position_value: Vector3,
	size_value: Vector3,
	material: Material
) -> void:
	if route_holder == null:
		return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name

	var box: BoxMesh = BoxMesh.new()
	box.size = size_value

	mesh_instance.mesh = box
	mesh_instance.position = position_value
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	mesh_instance.visibility_range_end = 45.0

	route_holder.add_child(mesh_instance)
	route_nodes.append(mesh_instance)


func _build_route_edges() -> void:
	var stone_material: StandardMaterial3D = _route_material()
	var marker_material: StandardMaterial3D = _marker_material()

	# Low, thin stone strips help players distinguish the central fighting route
	# from surrounding grass/placeholder surfaces. These do not collide.
	var z_values: Array[float] = [
		-18.0,
		-12.0,
		-6.0,
		0.0,
		6.0,
		12.0,
		18.0
	]

	for index: int in range(z_values.size()):
		var z_value: float = z_values[index]

		_add_box(
			"RouteEdge_Left_%02d" % index,
			Vector3(-8.6, 0.055, z_value),
			Vector3(0.18, 0.11, 4.3),
			stone_material
		)

		_add_box(
			"RouteEdge_Right_%02d" % index,
			Vector3(8.6, 0.055, z_value),
			Vector3(0.18, 0.11, 4.3),
			stone_material
		)

	# Four muted roadside markers frame the bridge approach without using neon
	# objective colors.
	var marker_positions: Array[Vector3] = [
		Vector3(-10.2, 0.55, -10.0),
		Vector3(10.2, 0.55, -10.0),
		Vector3(-10.2, 0.55, 10.0),
		Vector3(10.2, 0.55, 10.0)
	]

	for index: int in range(marker_positions.size()):
		_add_box(
			"RouteStone_%02d" % index,
			marker_positions[index],
			Vector3(0.34, 1.10, 0.34),
			marker_material
		)
