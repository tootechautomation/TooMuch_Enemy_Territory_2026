extends RefCounted
class_name RuinedCityMap


static func build(root: Node) -> void:
	if root == null:
		return

	_configure_spawn_data(root)
	_build_environment(root)
	_build_playable_geometry(root)
	_build_objective_nodes(root)
	_build_visual_setpieces(root)


static func _configure_spawn_data(root: Node) -> void:
	root.set("spawn_points", {
		0: [
			Vector3(-58.0, 1.2, -18.0),
			Vector3(-58.0, 1.2, -10.0),
			Vector3(-58.0, 1.2, 0.0),
			Vector3(-54.0, 1.2, 12.0),
			Vector3(-50.0, 1.2, 20.0)
		],
		1: [
			Vector3(58.0, 1.2, 18.0),
			Vector3(58.0, 1.2, 10.0),
			Vector3(58.0, 1.2, 0.0),
			Vector3(54.0, 1.2, -12.0),
			Vector3(50.0, 1.2, -20.0)
		]
	})

	root.set("forward_spawn_points", {
		0: [
			Vector3(-8.0, 1.1, -18.0),
			Vector3(-6.0, 1.1, -12.0),
			Vector3(-5.0, 1.1, -6.0)
		],
		1: [
			Vector3(8.0, 1.1, 18.0),
			Vector3(6.0, 1.1, 12.0),
			Vector3(5.0, 1.1, 6.0)
		]
	})

	var sectors := {
		"West Ruins": Vector3(-30.0, 0.0, -17.0),
		"Central Square": Vector3(0.0, 0.0, 0.0),
		"Pillbox Ridge": Vector3(30.0, 0.0, 18.0)
	}
	root.set("sector_positions", sectors)

	var controls: Dictionary = {}
	var progress: Dictionary = {}
	var contested: Dictionary = {}
	for sector_name_value: Variant in sectors.keys():
		var sector_name: String = str(sector_name_value)
		controls[sector_name] = -1
		progress[sector_name] = 0.0
		contested[sector_name] = false
	root.set("sector_control", controls)
	root.set("sector_progress", progress)
	root.set("sector_contested", contested)


static func _build_environment(root: Node) -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "RuinedCityWorldEnvironment"

	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.11, 0.14, 0.18)
	sky_material.sky_horizon_color = Color(0.48, 0.46, 0.43)
	sky_material.ground_bottom_color = Color(0.08, 0.075, 0.07)
	sky_material.ground_horizon_color = Color(0.29, 0.27, 0.24)
	sky.sky_material = sky_material

	environment.sky = sky
	environment.background_energy_multiplier = 0.82
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.63, 0.65)
	environment.ambient_light_energy = 0.80
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_density = 0.0045
	environment.fog_light_color = Color(0.46, 0.47, 0.48)
	environment.fog_light_energy = 0.48
	environment.volumetric_fog_enabled = false
	environment.glow_enabled = false

	world_environment.environment = environment
	root.add_child(world_environment)
	root.set("battlefield_environment", environment)

	var sun := DirectionalLight3D.new()
	sun.name = "RuinedCitySun"
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.08
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.shadow_normal_bias = 1.2
	sun.directional_shadow_max_distance = 72.0
	root.add_child(sun)
	root.set("battlefield_sun", sun)


static func _static_box(
	root: Node,
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	color_value: Color
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh_instance.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color_value
	material.roughness = 0.94
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision.shape = shape
	body.add_child(collision)

	root.add_child(body)
	return body


static func _build_playable_geometry(root: Node) -> void:
	# The imported city GLBs are visual setpieces. Gameplay collision is authored
	# separately using simple boxes so the map remains stable and performant.
	_static_box(
		root, "RuinedCityGround",
		Vector3(0.0, -0.55, 0.0),
		Vector3(132.0, 1.0, 92.0),
		Color(0.24, 0.23, 0.21)
	)

	# Outer perimeter.
	_static_box(root, "RC_NorthBoundary", Vector3(0, 2.0, -46), Vector3(132, 4, 1), Color(0.24,0.23,0.22))
	_static_box(root, "RC_SouthBoundary", Vector3(0, 2.0, 46), Vector3(132, 4, 1), Color(0.24,0.23,0.22))
	_static_box(root, "RC_WestBoundary", Vector3(-66, 2.0, 0), Vector3(1, 4, 92), Color(0.24,0.23,0.22))
	_static_box(root, "RC_EastBoundary", Vector3(66, 2.0, 0), Vector3(1, 4, 92), Color(0.24,0.23,0.22))

	# Three route structure: north street, central square, south alley.
	var cover_data: Array[Dictionary] = [
		{"n":"RC_WestRuinA","p":Vector3(-37,2.4,-18),"s":Vector3(12,4.8,8)},
		{"n":"RC_WestRuinB","p":Vector3(-31,1.8,15),"s":Vector3(9,3.6,12)},
		{"n":"RC_CenterRuinA","p":Vector3(-10,2.0,-20),"s":Vector3(10,4,8)},
		{"n":"RC_CenterRuinB","p":Vector3(10,2.0,20),"s":Vector3(10,4,8)},
		{"n":"RC_EastRuinA","p":Vector3(32,2.4,16),"s":Vector3(12,4.8,8)},
		{"n":"RC_EastRuinB","p":Vector3(38,1.8,-15),"s":Vector3(9,3.6,12)},
		{"n":"RC_SquareCoverA","p":Vector3(-7,0.9,4),"s":Vector3(5,1.8,2)},
		{"n":"RC_SquareCoverB","p":Vector3(7,0.9,-4),"s":Vector3(5,1.8,2)},
		{"n":"RC_AlleyWallA","p":Vector3(-20,1.3,30),"s":Vector3(14,2.6,1)},
		{"n":"RC_AlleyWallB","p":Vector3(20,1.3,-30),"s":Vector3(14,2.6,1)}
	]

	for entry: Dictionary in cover_data:
		_static_box(
			root,
			str(entry["n"]),
			Vector3(entry["p"]),
			Vector3(entry["s"]),
			Color(0.31, 0.29, 0.26)
		)


static func _objective_label(
	parent: Node3D,
	text_value: String,
	y: float
) -> Label3D:
	var label := Label3D.new()
	label.text = text_value
	label.position = Vector3(0.0, y, 0.0)
	label.font_size = 28
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
	return label


static func _build_objective_nodes(root: Node) -> void:
	# Stage 1 reuses the proven bridge-construction gameplay under a different
	# presentation: engineers establish a crossing through the central square.
	var build_site := Node3D.new()
	build_site.name = "BridgeBuildSite"
	build_site.position = Vector3(-4.0, 0.2, 0.0)
	root.add_child(build_site)

	var build_light := OmniLight3D.new()
	build_light.position = Vector3(0.0, 2.2, 0.0)
	build_light.omni_range = 7.0
	build_light.light_color = Color(1.0, 0.72, 0.12)
	build_light.light_energy = 1.2
	build_site.add_child(build_light)
	root.set("bridge_beacon", build_light)

	var bridge := _static_box(
		root,
		"ConstructedBridge",
		Vector3(0.0, 0.08, 0.0),
		Vector3(9.0, 0.32, 5.0),
		Color(0.34, 0.31, 0.25)
	)
	bridge.visible = false
	bridge.process_mode = Node.PROCESS_MODE_DISABLED

	# Stage 2 bunker objective.
	var objective := _static_box(
		root,
		"Objective",
		Vector3(38.0, 1.8, 8.0),
		Vector3(7.0, 3.6, 9.0),
		Color(0.34, 0.31, 0.27)
	)

	var objective_marker := _objective_label(
		objective,
		"DESTROY THE PILLBOX",
		3.3
	)
	root.set("objective_marker", objective_marker)

	var progress_label := _objective_label(
		objective,
		"",
		2.75
	)
	progress_label.font_size = 20
	root.set("objective_progress_label", progress_label)

	var bunker_light := OmniLight3D.new()
	bunker_light.position = Vector3(0.0, 2.5, 0.0)
	bunker_light.omni_range = 7.0
	bunker_light.light_color = Color(0.90, 0.22, 0.14)
	bunker_light.light_energy = 1.1
	objective.add_child(bunker_light)
	root.set("bunker_beacon", bunker_light)

	var dynamite := MeshInstance3D.new()
	dynamite.name = "DynamiteVisual"
	var dynamite_mesh := BoxMesh.new()
	dynamite_mesh.size = Vector3(0.32, 0.18, 0.52)
	dynamite.mesh = dynamite_mesh
	dynamite.position = Vector3(-3.3, 0.3, 0.0)
	dynamite.visible = false
	objective.add_child(dynamite)
	root.set("dynamite_model", dynamite)

	var dynamite_light := OmniLight3D.new()
	dynamite_light.position = dynamite.position + Vector3.UP * 0.25
	dynamite_light.omni_range = 4.0
	dynamite_light.light_color = Color(1.0, 0.12, 0.05)
	dynamite_light.visible = false
	objective.add_child(dynamite_light)
	root.set("dynamite_light", dynamite_light)

	# Command post and supply depot retain existing gameplay hooks.
	var command_post := Node3D.new()
	command_post.name = "CommandPost"
	command_post.position = Vector3(8.0, 0.2, -18.0)
	root.add_child(command_post)

	var cp_marker := _objective_label(command_post, "COMMAND POST", 2.8)
	root.set("command_post_marker", cp_marker)
	var cp_progress := _objective_label(command_post, "", 2.35)
	cp_progress.font_size = 18
	root.set("command_post_progress_label", cp_progress)

	var cp_light := OmniLight3D.new()
	cp_light.position = Vector3(0,2,0)
	cp_light.omni_range = 6.0
	cp_light.light_energy = 0.9
	command_post.add_child(cp_light)
	root.set("command_post_beacon", cp_light)

	var supply := Node3D.new()
	supply.name = "SupplyDepot"
	supply.position = Vector3(-15.0, 0.0, 19.0)
	root.add_child(supply)

	var supply_marker := _objective_label(supply, "SUPPLY DEPOT", 2.6)
	root.set("supply_depot_marker", supply_marker)
	var supply_progress := _objective_label(supply, "", 2.15)
	supply_progress.font_size = 18
	root.set("supply_depot_progress_label", supply_progress)

	var supply_light := OmniLight3D.new()
	supply_light.position = Vector3(0,2,0)
	supply_light.omni_range = 6.0
	supply_light.light_energy = 0.85
	supply.add_child(supply_light)
	root.set("supply_depot_light", supply_light)


static func _instantiate_visual(
	root: Node,
	path: String,
	name_value: String,
	position_value: Vector3,
	rotation_y: float,
	target_height: float,
	max_range: float
) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not ResourceLoader.exists(path):
		return

	var resource: Resource = load(path)
	if not resource is PackedScene:
		return

	var node: Node = (resource as PackedScene).instantiate()
	if not node is Node3D:
		node.queue_free()
		return

	var model := node as Node3D
	model.name = name_value
	root.add_child(model)

	# Determine approximate bounds from imported meshes and normalize once.
	var has_bounds := false
	var bounds := AABB()
	for child: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var local_aabb := mesh_instance.get_aabb()
		var transformed := mesh_instance.transform * local_aabb
		if not has_bounds:
			bounds = transformed
			has_bounds = true
		else:
			bounds = bounds.merge(transformed)

	if has_bounds and bounds.size.y > 0.01:
		var scale_factor := clampf(
			target_height / bounds.size.y,
			0.005,
			8.0
		)
		model.scale = Vector3.ONE * scale_factor

	model.position = position_value
	model.rotation.y = rotation_y

	for child: Node in model.find_children("*", "GeometryInstance3D", true, false):
		var geometry := child as GeometryInstance3D
		geometry.visibility_range_end = max_range
		geometry.visibility_range_end_margin = 10.0
		geometry.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)


static func _build_visual_setpieces(root: Node) -> void:
	# These assets belong ONLY to this map.
	_instantiate_visual(
		root,
		"res://assets/maps/ruined_city/city_ruins_environment.glb",
		"RuinedCity_WestRuins",
		Vector3(-35.0, 0.0, -5.0),
		deg_to_rad(12.0),
		11.0,
		95.0
	)

	_instantiate_visual(
		root,
		"res://assets/maps/ruined_city/ww2_low_poly_city_scene.glb",
		"RuinedCity_Backdrop",
		Vector3(22.0, 0.0, -4.0),
		deg_to_rad(-8.0),
		16.0,
		125.0
	)

	_instantiate_visual(
		root,
		"res://assets/maps/ruined_city/mothecombe_pillbox.glb",
		"RuinedCity_PillboxVisual",
		Vector3(38.0, 0.0, 8.0),
		deg_to_rad(180.0),
		5.2,
		90.0
	)
