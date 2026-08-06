extends Node3D
class_name CombatEffectsManager

const MAX_ACTIVE_EFFECT_ROOTS := 72
const MAX_ACTIVE_DECALS := 64

var active_effect_roots: Array[Node] = []
var active_decals: Array[Decal] = []
var impact_texture_cache: Dictionary = {}

func spawn_surface_impact(
	world_root: Node,
	position_value: Vector3,
	normal: Vector3,
	hit_player: bool
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var category := (
		"flesh"
		if hit_player
		else _surface_category(
			world_root,
			position_value,
			normal
		)
	)

	var root := Node3D.new()
	root.name = "SurfaceImpact_%s" % category
	root.position = position_value
	add_child(root)
	_track_effect_root(root)

	if not hit_player:
		_spawn_impact_decal(position_value, normal, category)

	var debris_direction := normal.normalized()
	if debris_direction.length_squared() <= 0.001:
		debris_direction = Vector3.UP
	debris_direction = (debris_direction + Vector3.UP * 0.32).normalized()

	match category:
		"metal":
			_spawn_particles(
				root,
				Color(1.0, 0.52, 0.10, 0.95),
				22,
				4.8,
				Vector3(0.0, -7.0, 0.0),
				0.035,
				0.075,
				debris_direction
			)
			_spawn_ricochet_streaks(root, debris_direction)
			_spawn_flash_light(root, Color(1.0, 0.40, 0.07), 1.8, 1.8)
		"wood":
			_spawn_particles(
				root,
				Color(0.42, 0.21, 0.07, 0.92),
				18,
				3.2,
				Vector3(0.0, -5.8, 0.0),
				0.045,
				0.11,
				debris_direction
			)
			_spawn_fragment_meshes(root, category, 7, 1.6)
		"brick":
			_spawn_particles(
				root,
				Color(0.52, 0.19, 0.10, 0.88),
				24,
				3.5,
				Vector3(0.0, -6.2, 0.0),
				0.045,
				0.12,
				debris_direction
			)
			_spawn_dust_puff(root, Color(0.48, 0.25, 0.15, 0.50), 0.55)
			_spawn_fragment_meshes(root, category, 8, 1.5)
		"concrete", "stone":
			_spawn_particles(
				root,
				Color(0.62, 0.60, 0.54, 0.86),
				22,
				3.3,
				Vector3(0.0, -6.2, 0.0),
				0.045,
				0.11,
				debris_direction
			)
			_spawn_dust_puff(root, Color(0.55, 0.53, 0.47, 0.48), 0.62)
			_spawn_fragment_meshes(root, category, 6, 1.4)
		"ground":
			_spawn_particles(
				root,
				Color(0.38, 0.27, 0.14, 0.82),
				20,
				2.8,
				Vector3(0.0, -5.0, 0.0),
				0.055,
				0.13,
				debris_direction
			)
			_spawn_dust_puff(root, Color(0.44, 0.34, 0.22, 0.52), 0.68)
		"flesh":
			_spawn_particles(
				root,
				Color(0.58, 0.025, 0.018, 0.84),
				13,
				2.4,
				Vector3(0.0, -5.5, 0.0),
				0.04,
				0.085,
				debris_direction
			)
		_:
			_spawn_particles(
				root,
				Color(0.72, 0.62, 0.43, 0.84),
				18,
				3.0,
				Vector3(0.0, -5.5, 0.0),
				0.04,
				0.10,
				debris_direction
			)

	_cleanup_after(root, 1.45)

func spawn_explosion_polish(
	position_value: Vector3,
	material_hint: String = "ground"
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var root := Node3D.new()
	root.name = "ExplosionPolish"
	root.position = position_value
	add_child(root)
	_track_effect_root(root)

	_spawn_flash_light(
		root,
		Color(1.0, 0.30, 0.035),
		8.5,
		8.0
	)
	_spawn_explosion_fireball(root)
	_spawn_explosion_smoke(root)
	_spawn_particles(
		root,
		Color(0.44, 0.32, 0.18, 0.88),
		54,
		8.0,
		Vector3(0.0, -8.5, 0.0),
		0.07,
		0.18,
		Vector3.UP
	)
	_spawn_fragment_meshes(
		root,
		material_hint,
		20,
		4.8
	)
	_spawn_ground_scorch(root)
	_cleanup_after(root, 4.2)

func _surface_category(
	world_root: Node,
	position_value: Vector3,
	normal: Vector3
) -> String:
	if world_root == null:
		return "generic"

	var world_node := world_root as Node3D
	if world_node == null:
		for child in world_root.find_children(
			"*",
			"Node3D",
			true
		):
			world_node = child as Node3D
			if (
				world_node != null
				and world_node.get_world_3d() != null
			):
				break

	if world_node == null or world_node.get_world_3d() == null:
		return "generic"

	var direction := normal.normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector3.UP

	var query := PhysicsRayQueryParameters3D.create(
		position_value + direction * 0.20,
		position_value - direction * 0.45
	)
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var hit: Dictionary = (
		world_node.get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)
	if hit.is_empty():
		return "ground" if absf(normal.y) > 0.65 else "generic"

	var collider: Object = hit.get("collider")
	var name_text := ""
	if collider is Node:
		var collider_node := collider as Node
		name_text = (
			collider_node.name
			+ " "
			+ str(collider_node.get_path())
		).to_lower()

	if (
		"metal" in name_text
		or "barrel" in name_text
		or "rail" in name_text
		or "fence" in name_text
		or "lamp" in name_text
	):
		return "metal"
	if (
		"wood" in name_text
		or "crate" in name_text
		or "door" in name_text
		or "shutter" in name_text
	):
		return "wood"
	if (
		"brick" in name_text
		or "townhouse" in name_text
		or "warehouse" in name_text
	):
		return "brick"
	if (
		"concrete" in name_text
		or "bunker" in name_text
		or "plaster" in name_text
	):
		return "concrete"
	if (
		"stone" in name_text
		or "church" in name_text
		or "rubble" in name_text
	):
		return "stone"
	if (
		"ground" in name_text
		or "road" in name_text
		or "terrain" in name_text
		or "mud" in name_text
	):
		return "ground"
	return "ground" if absf(normal.y) > 0.65 else "generic"

func _spawn_impact_decal(
	world_position: Vector3,
	normal: Vector3,
	category: String
) -> void:
	var decal := Decal.new()
	decal.name = "PersistentImpactDecal_%s" % category
	var decal_scale := randf_range(0.16, 0.23)
	decal.size = Vector3(decal_scale, decal_scale, 0.11)

	var texture := _procedural_impact_texture(category)
	decal.texture_albedo = texture
	decal.modulate = Color(1.0, 1.0, 1.0, 0.86)
	add_child(decal)
	decal.global_position = world_position + normal.normalized() * 0.018
	decal.rotation = _rotation_from_normal(normal)
	decal.rotation.z += randf_range(-PI, PI)
	active_decals.append(decal)

	while active_decals.size() > MAX_ACTIVE_DECALS:
		var oldest: Decal = (
			active_decals.pop_front() as Decal
		)
		if oldest != null and is_instance_valid(oldest):
			oldest.queue_free()

	var tween := decal.create_tween()
	tween.tween_interval(12.0)
	tween.tween_property(decal, "modulate:a", 0.0, 2.5)
	tween.tween_callback(
		func() -> void:
			active_decals.erase(decal)
			if is_instance_valid(decal):
				decal.queue_free()
	)

func _procedural_impact_texture(category: String) -> Texture2D:
	if impact_texture_cache.has(category):
		return impact_texture_cache[category] as Texture2D

	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center := Vector2(31.5, 31.5)
	var base_color := Color(0.035, 0.030, 0.025, 0.92)
	if category == "metal":
		base_color = Color(0.09, 0.075, 0.055, 0.86)
	elif category == "wood":
		base_color = Color(0.11, 0.055, 0.022, 0.88)
	elif category == "brick":
		base_color = Color(0.12, 0.045, 0.025, 0.88)

	for y_value in range(64):
		for x_value in range(64):
			var delta := Vector2(x_value, y_value) - center
			var distance := delta.length()
			var irregular := (
				sin(float(x_value) * 1.73)
				+ cos(float(y_value) * 1.29)
			) * 1.8
			var alpha := clampf(
				1.0 - (distance + irregular) / 26.0,
				0.0,
				1.0
			)
			alpha = pow(alpha, 1.8)
			var angle := atan2(delta.y, delta.x)
			var crack_wave := absf(sin(angle * 7.0 + distance * 0.22))
			var crack_mask := smoothstep(0.94, 0.995, crack_wave)
			var crack_falloff := clampf(1.0 - distance / 31.0, 0.0, 1.0)
			alpha = maxf(alpha, crack_mask * crack_falloff * 0.62)
			image.set_pixel(
				x_value,
				y_value,
				Color(
					base_color.r,
					base_color.g,
					base_color.b,
					base_color.a * alpha
				)
			)

	var texture := ImageTexture.create_from_image(image)
	impact_texture_cache[category] = texture
	return texture

func _rotation_from_normal(normal: Vector3) -> Vector3:
	var n := normal.normalized()
	if n.length_squared() <= 0.001:
		return Vector3.ZERO
	var basis := Basis.looking_at(-n, Vector3.UP)
	return basis.get_euler()

func _spawn_particles(
	root: Node3D,
	color: Color,
	amount_value: int,
	velocity_max: float,
	gravity_value: Vector3,
	scale_minimum: float,
	scale_maximum: float,
	direction_value: Vector3 = Vector3.UP
) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "ImpactParticles"
	particles.amount = amount_value
	particles.lifetime = 0.72
	particles.one_shot = true
	particles.explosiveness = 0.94

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.06
	process.direction = direction_value.normalized()
	process.spread = 72.0
	process.initial_velocity_min = velocity_max * 0.42
	process.initial_velocity_max = velocity_max
	process.gravity = gravity_value
	process.scale_min = scale_minimum
	process.scale_max = scale_maximum
	process.color = color
	particles.process_material = process

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.09, 0.09)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material = material
	particles.draw_pass_1 = mesh
	root.add_child(particles)
	particles.emitting = true

func _spawn_ricochet_streaks(
	root: Node3D,
	direction_value: Vector3
) -> void:
	for _streak_index in range(5):
		var streak := MeshInstance3D.new()
		streak.name = "RicochetStreak"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.008, 0.008, randf_range(0.14, 0.30))
		streak.mesh = mesh
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(1.0, 0.58, 0.12, 0.92)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.28, 0.025)
		material.emission_energy_multiplier = 2.2
		streak.material_override = material
		root.add_child(streak)

		var travel := (
			direction_value
			+ Vector3(
				randf_range(-0.55, 0.55),
				randf_range(-0.18, 0.65),
				randf_range(-0.55, 0.55)
			)
		).normalized()
		streak.look_at(streak.global_position + travel, Vector3.UP)
		var tween := streak.create_tween()
		tween.set_parallel(true)
		tween.tween_property(streak, "position", travel * randf_range(0.8, 1.8), 0.16)
		tween.tween_property(material, "albedo_color:a", 0.0, 0.18)

func _spawn_dust_puff(
	root: Node3D,
	color: Color,
	size_value: float
) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "ImpactDust"
	particles.amount = 9
	particles.lifetime = 1.15
	particles.one_shot = true
	particles.explosiveness = 0.72

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.10
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 115.0
	process.initial_velocity_min = 0.28
	process.initial_velocity_max = 0.85
	process.gravity = Vector3(0.0, 0.12, 0.0)
	process.scale_min = size_value * 0.35
	process.scale_max = size_value
	process.color = color
	particles.process_material = process

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.52, 0.52)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material = material
	particles.draw_pass_1 = mesh
	root.add_child(particles)
	particles.emitting = true

func _spawn_fragment_meshes(
	root: Node3D,
	category: String,
	count: int,
	spread: float
) -> void:
	var color := Color(0.36, 0.30, 0.22)
	if category == "brick":
		color = Color(0.46, 0.16, 0.08)
	elif category == "wood":
		color = Color(0.29, 0.13, 0.045)
	elif category == "metal":
		color = Color(0.13, 0.14, 0.13)
	elif category == "concrete" or category == "stone":
		color = Color(0.48, 0.47, 0.43)

	for fragment_index in range(count):
		var fragment := MeshInstance3D.new()
		fragment.name = "ImpactFragment"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(
			randf_range(0.025, 0.085),
			randf_range(0.018, 0.070),
			randf_range(0.025, 0.080)
		)
		fragment.mesh = mesh

		var material := StandardMaterial3D.new()
		material.albedo_color = color.lightened(randf_range(-0.08, 0.08))
		material.roughness = 0.94
		material.metallic = 0.55 if category == "metal" else 0.0
		fragment.material_override = material
		root.add_child(fragment)

		var target := Vector3(
			randf_range(-spread, spread),
			randf_range(0.25, spread),
			randf_range(-spread, spread)
		)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(fragment, "position", target, 0.48)
		tween.tween_property(
			fragment,
			"rotation_degrees",
			Vector3(
				randf_range(180.0, 620.0),
				randf_range(180.0, 620.0),
				randf_range(180.0, 620.0)
			),
			0.48
		)

func _spawn_flash_light(
	root: Node3D,
	color: Color,
	energy: float,
	range_value: float
) -> void:
	var light := OmniLight3D.new()
	light.name = "ImpactFlashLight"
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	light.shadow_enabled = false
	root.add_child(light)

	var tween := create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.09)
	tween.tween_callback(light.queue_free)

func _spawn_explosion_fireball(root: Node3D) -> void:
	var sphere := MeshInstance3D.new()
	sphere.name = "ExplosionFireball"
	var mesh := SphereMesh.new()
	mesh.radius = 0.42
	mesh.height = 0.84
	sphere.mesh = mesh

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.30, 0.025, 0.94)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.18, 0.015)
	material.emission_energy_multiplier = 4.2
	sphere.material_override = material
	root.add_child(sphere)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sphere, "scale", Vector3.ONE * 5.2, 0.28)
	tween.tween_property(
		material,
		"albedo_color:a",
		0.0,
		0.34
	)
	tween.chain().tween_callback(sphere.queue_free)

func _spawn_explosion_smoke(root: Node3D) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "ExplosionSmoke"
	particles.amount = 42
	particles.lifetime = 3.4
	particles.one_shot = true
	particles.explosiveness = 0.72

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.35
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 92.0
	process.initial_velocity_min = 1.4
	process.initial_velocity_max = 4.0
	process.gravity = Vector3(0.0, 0.35, 0.0)
	process.scale_min = 0.55
	process.scale_max = 1.55
	process.color = Color(0.12, 0.105, 0.09, 0.72)
	particles.process_material = process

	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.15, 1.15)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.12, 0.105, 0.09, 0.62)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material = material
	particles.draw_pass_1 = mesh
	root.add_child(particles)
	particles.emitting = true

func _spawn_ground_scorch(root: Node3D) -> void:
	var decal := Decal.new()
	decal.name = "ExplosionScorch"
	decal.size = Vector3(2.6, 2.6, 0.35)
	decal.position = Vector3(0.0, 0.02, 0.0)
	decal.rotation_degrees.x = -90.0
	decal.texture_albedo = _procedural_impact_texture("brick")
	decal.modulate = Color(0.22, 0.18, 0.14, 0.72)
	root.add_child(decal)

func _track_effect_root(root: Node) -> void:
	active_effect_roots.append(root)
	while active_effect_roots.size() > MAX_ACTIVE_EFFECT_ROOTS:
		var oldest: Node = (
			active_effect_roots.pop_front() as Node
		)
		if oldest != null and is_instance_valid(oldest):
			oldest.queue_free()

func _cleanup_after(root: Node, seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = seconds
	timer.timeout.connect(
		func() -> void:
			active_effect_roots.erase(root)
			if root != null and is_instance_valid(root):
				root.queue_free()
	)
	root.add_child(timer)
	timer.start()
