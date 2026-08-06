extends Node3D
class_name BattlefieldAtmosphere

func build(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_configure_environment(root)
	_configure_lights(root)
	_build_airborne_dust()
	_build_facade_grime()
	_build_scorch_marks()
	_build_road_debris()

func _configure_environment(root: Node) -> void:
	for node_value in root.find_children("*", "WorldEnvironment", true):
		var world_environment := node_value as WorldEnvironment
		if (
			world_environment == null
			or world_environment.environment == null
		):
			continue

		var environment := world_environment.environment
		environment.ambient_light_energy = 0.72
		environment.ambient_light_sky_contribution = 0.82
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		environment.tonemap_exposure = 1.05
		environment.tonemap_white = 1.65
		environment.ssao_enabled = true
		environment.ssao_radius = 2.6
		environment.ssao_intensity = 2.0
		environment.ssil_enabled = true
		environment.ssil_radius = 3.0
		environment.ssil_intensity = 0.85
		environment.glow_enabled = true
		environment.glow_intensity = 0.38
		environment.ssr_enabled = true
		environment.ssr_max_steps = 48
		environment.adjustment_enabled = true
		environment.adjustment_brightness = 1.02
		environment.adjustment_contrast = 1.11
		environment.adjustment_saturation = 0.88
		environment.fog_enabled = true
		environment.fog_light_color = Color(0.47, 0.50, 0.49)
		environment.fog_light_energy = 0.75
		environment.fog_density = 0.0085
		environment.fog_height = 2.0
		environment.fog_height_density = 0.055

func _configure_lights(root: Node) -> void:
	var found_directional := false
	for node_value in root.find_children("*", "DirectionalLight3D", true):
		var light := node_value as DirectionalLight3D
		if light == null:
			continue
		found_directional = true
		light.light_color = Color(1.0, 0.86, 0.70)
		light.light_energy = 1.25
		light.shadow_enabled = true
		light.directional_shadow_max_distance = 120.0
		light.directional_shadow_fade_start = 0.80
		light.shadow_bias = 0.08
		light.shadow_normal_bias = 1.2

	if found_directional:
		return

	var sun := DirectionalLight3D.new()
	sun.name = "BattlefieldSun"
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_color = Color(1.0, 0.86, 0.70)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)

func _build_airborne_dust() -> void:
	var particles := GPUParticles3D.new()
	particles.name = "AirborneDust"
	particles.position = Vector3(0.0, 5.0, 0.0)
	particles.amount = 180
	particles.lifetime = 9.0
	particles.preprocess = 9.0
	particles.visibility_aabb = AABB(
		Vector3(-80.0, -10.0, -80.0),
		Vector3(160.0, 30.0, 160.0)
	)

	var process := ParticleProcessMaterial.new()
	process.emission_shape = (
		ParticleProcessMaterial.EMISSION_SHAPE_BOX
	)
	process.emission_box_extents = Vector3(65.0, 5.0, 65.0)
	process.direction = Vector3(0.30, 0.08, 0.12)
	process.spread = 35.0
	process.initial_velocity_min = 0.12
	process.initial_velocity_max = 0.42
	process.gravity = Vector3(0.0, -0.025, 0.0)
	process.scale_min = 0.018
	process.scale_max = 0.065
	process.color = Color(0.64, 0.57, 0.45, 0.30)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(0.055, 0.055)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.72, 0.65, 0.52, 0.28)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)

func _build_facade_grime() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.085, 0.072, 0.052, 0.58)
	material.roughness = 1.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for data in [
		[Vector3(-50.5, 0.64, -30.40), Vector3(11.5, 1.15, 0.055)],
		[Vector3(-51.3, 0.62, -11.45), Vector3(10.5, 1.10, 0.055)],
		[Vector3(-49.0, 0.60, 30.05), Vector3(12.0, 1.05, 0.055)],
		[Vector3(44.95, 0.68, -21.90), Vector3(13.0, 1.20, 0.055)]
	]:
		_add_box(
			"FacadeGrime",
			Vector3(data[0]),
			Vector3(data[1]),
			material
		)

func _build_scorch_marks() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.025, 0.020, 0.016, 0.68)
	material.roughness = 1.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for data in [
		[Vector3(-48.2, 3.2, -30.34), Vector3(1.6, 2.4, 0.04), 12.0],
		[Vector3(-53.1, 2.7, -11.39), Vector3(1.2, 1.8, 0.04), -8.0],
		[Vector3(43.2, 3.5, -21.84), Vector3(1.8, 2.7, 0.04), 6.0]
	]:
		var mark := _add_box(
			"ScorchMark",
			Vector3(data[0]),
			Vector3(data[1]),
			material
		)
		mark.rotation_degrees.z = float(data[2])

func _build_road_debris() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.19, 0.16, 0.12)
	material.roughness = 0.98

	var rng := RandomNumberGenerator.new()
	rng.seed = 7802026
	for index in range(72):
		var debris := _add_box(
			"StreetDebris",
			Vector3(
				rng.randf_range(-52.0, 52.0),
				rng.randf_range(0.025, 0.10),
				rng.randf_range(-38.0, 38.0)
			),
			Vector3(
				rng.randf_range(0.05, 0.22),
				rng.randf_range(0.025, 0.11),
				rng.randf_range(0.05, 0.20)
			),
			material
		)
		debris.rotation_degrees = Vector3(
			rng.randf_range(-25.0, 25.0),
			rng.randf_range(0.0, 180.0),
			rng.randf_range(-25.0, 25.0)
		)

func _add_box(
	node_name: String,
	position_value: Vector3,
	size: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position_value
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance
