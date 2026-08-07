extends Node3D
class_name WetSurfaceResponse

const UPDATE_INTERVAL := 0.10

var world_root: Node
var weather_system: Node
var wet_surfaces: Array[Dictionary] = []
var puddles: Array[MeshInstance3D] = []
var puddle_material: StandardMaterial3D
var splash_particles: GPUParticles3D
var current_wetness := 0.0
var update_accumulator := 0.0

func build(root: Node, weather: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	world_root = root
	weather_system = weather
	_build_puddles()
	_build_rain_splashes()
	call_deferred("_collect_world_surfaces")

func _process(delta: float) -> void:
	if world_root == null:
		return
	update_accumulator += delta
	if update_accumulator < UPDATE_INTERVAL:
		return
	var step := update_accumulator
	update_accumulator = 0.0

	var weather_intensity := 0.0
	if weather_system != null:
		weather_intensity = clampf(
			float(weather_system.get("current_intensity")),
			0.0,
			1.0
		)
	var target_wetness := smoothstep(
		0.20,
		0.78,
		weather_intensity
	)
	current_wetness = move_toward(
		current_wetness,
		target_wetness,
		step * (0.32 if target_wetness > current_wetness else 0.09)
	)
	_apply_wetness(current_wetness)
	_update_ground_water(current_wetness)

func _build_puddles() -> void:
	puddle_material = StandardMaterial3D.new()
	puddle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puddle_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	puddle_material.albedo_color = Color(0.20, 0.27, 0.30, 0.0)
	puddle_material.metallic = 0.0
	puddle_material.roughness = 0.10

	var placements: Array[Dictionary] = [
		{"position": Vector3(-13.2, 0.025, -7.6), "size": Vector2(2.8, 1.1), "rotation": 0.18},
		{"position": Vector3(-8.4, 0.026, -2.9), "size": Vector2(1.9, 0.8), "rotation": -0.34},
		{"position": Vector3(-14.0, 0.025, 5.8), "size": Vector2(2.4, 1.0), "rotation": 0.42},
		{"position": Vector3(-5.8, 0.027, 8.7), "size": Vector2(1.6, 0.7), "rotation": -0.12},
		{"position": Vector3(-3.8, 0.026, -8.9), "size": Vector2(1.5, 0.6), "rotation": 0.26},
		{"position": Vector3(4.6, 0.026, -8.1), "size": Vector2(1.8, 0.7), "rotation": -0.20},
		{"position": Vector3(8.8, 0.025, -3.6), "size": Vector2(2.1, 0.9), "rotation": 0.36},
		{"position": Vector3(13.5, 0.026, 6.9), "size": Vector2(2.7, 1.1), "rotation": -0.28},
		{"position": Vector3(6.2, 0.027, 8.8), "size": Vector2(1.7, 0.7), "rotation": 0.14},
		{"position": Vector3(14.2, 0.025, -7.3), "size": Vector2(2.3, 0.9), "rotation": 0.31}
	]
	for index in range(placements.size()):
		var placement: Dictionary = placements[index]
		var puddle := MeshInstance3D.new()
		puddle.name = "WeatherPuddle_%02d" % index
		puddle.position = placement.get("position", Vector3.ZERO)
		puddle.rotation.y = float(placement.get("rotation", 0.0))
		var plane := PlaneMesh.new()
		plane.size = placement.get("size", Vector2.ONE)
		plane.material = puddle_material
		puddle.mesh = plane
		puddle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		puddle.visible = false
		add_child(puddle)
		puddles.append(puddle)

func _build_rain_splashes() -> void:
	splash_particles = GPUParticles3D.new()
	splash_particles.name = "RainImpactSplashes"
	splash_particles.position = Vector3(0.0, 0.08, 0.0)
	splash_particles.amount = 180
	splash_particles.lifetime = 0.42
	splash_particles.randomness = 0.72
	splash_particles.fixed_fps = 24
	splash_particles.visibility_aabb = AABB(
		Vector3(-22.0, -0.5, -15.0),
		Vector3(44.0, 4.0, 30.0)
	)
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(18.0, 0.03, 11.0)
	process.direction = Vector3.UP
	process.spread = 38.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 0.95
	process.gravity = Vector3(0.0, -4.8, 0.0)
	process.scale_min = 0.45
	process.scale_max = 1.0
	process.color = Color(0.68, 0.76, 0.80, 0.38)
	splash_particles.process_material = process
	var droplet := QuadMesh.new()
	droplet.size = Vector2(0.028, 0.13)
	var droplet_material := StandardMaterial3D.new()
	droplet_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	droplet_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	droplet_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	droplet_material.albedo_color = Color(0.72, 0.80, 0.84, 0.34)
	droplet.material = droplet_material
	splash_particles.draw_pass_1 = droplet
	splash_particles.emitting = false
	add_child(splash_particles)

func _collect_world_surfaces() -> void:
	if world_root == null:
		return
	wet_surfaces.clear()
	for node_value in world_root.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var identity := _hierarchy_identity(mesh_instance)
		if not _is_weather_exposed(identity):
			continue
		if mesh_instance.material_override is StandardMaterial3D:
			var override_source := (
				mesh_instance.material_override as StandardMaterial3D
			)
			var override_material := (
				override_source.duplicate() as StandardMaterial3D
			)
			if _register_material(override_material):
				mesh_instance.material_override = override_material
			continue

		for surface_index in range(
			mesh_instance.mesh.get_surface_count()
		):
			var source := mesh_instance.get_active_material(
				surface_index
			)
			if not source is StandardMaterial3D:
				continue
			var material := (
				(source as StandardMaterial3D).duplicate()
				as StandardMaterial3D
			)
			if _register_material(material):
				mesh_instance.set_surface_override_material(
					surface_index,
					material
				)
	print(
		"Wet surface response registered %d materials"
		% wet_surfaces.size()
	)

func _register_material(material: StandardMaterial3D) -> bool:
	if material == null:
		return false
	if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return false
	if material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		return false
	wet_surfaces.append({
		"material": material,
		"base_color": material.albedo_color,
		"base_roughness": material.roughness
	})
	return true

func _apply_wetness(wetness: float) -> void:
	for surface in wet_surfaces:
		var material := surface.get("material") as StandardMaterial3D
		if material == null:
			continue
		var base_color: Color = surface.get(
			"base_color",
			Color.WHITE
		)
		var base_roughness := float(
			surface.get("base_roughness", 0.8)
		)
		var wet_color := base_color.darkened(0.18)
		material.albedo_color = base_color.lerp(
			wet_color,
			wetness
		)
		var wet_roughness := clampf(
			base_roughness * 0.38,
			0.16,
			0.46
		)
		material.roughness = lerpf(
			base_roughness,
			wet_roughness,
			wetness
		)

func _update_ground_water(wetness: float) -> void:
	var puddle_weight := smoothstep(0.28, 0.88, wetness)
	if puddle_material != null:
		puddle_material.albedo_color = Color(
			0.18,
			0.24,
			0.27,
			lerpf(0.0, 0.28, puddle_weight)
		)
		puddle_material.roughness = lerpf(0.24, 0.08, puddle_weight)
	for puddle in puddles:
		if puddle != null:
			puddle.visible = puddle_weight > 0.025
	if splash_particles != null:
		splash_particles.emitting = wetness > 0.20
		splash_particles.amount_ratio = smoothstep(0.18, 0.92, wetness)

func _hierarchy_identity(node: Node) -> String:
	var names: Array[String] = []
	var current := node
	var depth := 0
	while current != null and depth < 7:
		names.append(str(current.name).to_lower())
		current = current.get_parent()
		depth += 1
	return " ".join(names)

func _is_weather_exposed(identity: String) -> bool:
	for excluded in [
		"player",
		"character",
		"weapon",
		"marker",
		"beacon",
		"spawnzone",
		"particle",
		"cloud",
		"mist",
		"rain",
		"river",
		"water"
	]:
		if excluded in identity:
			return false
	for exposed in [
		"ground",
		"road",
		"lane",
		"street",
		"cobble",
		"gravel",
		"mud",
		"rubble",
		"brick",
		"wall",
		"building",
		"house",
		"warehouse",
		"church",
		"bunker",
		"fort",
		"roof",
		"plaster",
		"concrete",
		"rail",
		"track",
		"train",
		"crate",
		"barrel",
		"cover",
		"fence",
		"tower",
		"trench",
		"platform",
		"sandbag",
		"halftrack",
		"artillery"
	]:
		if exposed in identity:
			return true
	return false
