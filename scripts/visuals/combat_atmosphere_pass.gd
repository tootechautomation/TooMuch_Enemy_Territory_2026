extends RefCounted
class_name CombatAtmospherePass

# v8.71 — visual-only combat atmosphere and distance-composition pass.
# Adds battlefield haze, smoke columns, drifting dust/embers and localized
# light contrast without changing collision, weapons, objectives or networking.

static func apply(root: Node) -> void:
	if root == null or root.has_node("CombatAtmospherePass_v871"):
		return

	var holder := Node3D.new()
	holder.name = "CombatAtmospherePass_v871"
	root.add_child(holder)

	_build_smoke_columns(holder)
	_build_ground_haze(holder)
	_build_dust_motes(holder)
	_build_ember_zones(holder)
	_build_cool_fill_lights(holder)
	_build_warm_combat_glows(holder)


static func _build_smoke_columns(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-18.0,0.6,-13.0),
		Vector3(17.0,0.6,13.5),
		Vector3(21.0,0.6,-6.0),
		Vector3(-13.0,0.6,15.0)
	]

	for i: int in range(positions.size()):
		var particles := GPUParticles3D.new()
		particles.name = "BattleSmokeColumn_%d" % i
		particles.position = positions[i]
		particles.amount = 24
		particles.lifetime = 7.5
		particles.randomness = 0.85
		particles.visibility_aabb = AABB(Vector3(-5,0,-5),Vector3(10,15,10))

		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.10,1.0,0.04)
		process.spread = 22.0
		process.initial_velocity_min = 0.28
		process.initial_velocity_max = 0.72
		process.gravity = Vector3(0.035,0.02,0.015)
		process.scale_min = 0.8
		process.scale_max = 2.2
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(2.2,2.2)
		var smoke := StandardMaterial3D.new()
		smoke.albedo_color = Color(0.075,0.070,0.064,0.16)
		smoke.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smoke.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		smoke.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = smoke
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_ground_haze(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-7.0,0.35,0.0),
		Vector3(7.0,0.35,0.0),
		Vector3(0.0,0.35,8.0),
		Vector3(0.0,0.35,-8.0)
	]

	for i: int in range(positions.size()):
		var particles := GPUParticles3D.new()
		particles.name = "LowGroundHaze_%d" % i
		particles.position = positions[i]
		particles.amount = 18
		particles.lifetime = 6.0
		particles.randomness = 1.0
		particles.visibility_aabb = AABB(Vector3(-6,-1,-6),Vector3(12,4,12))

		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(1.0,0.05,0.15)
		process.spread = 45.0
		process.initial_velocity_min = 0.08
		process.initial_velocity_max = 0.25
		process.gravity = Vector3.ZERO
		process.scale_min = 0.8
		process.scale_max = 1.8
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(2.8,1.0)
		var haze := StandardMaterial3D.new()
		haze.albedo_color = Color(0.18,0.18,0.16,0.055)
		haze.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		haze.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		haze.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = haze
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_dust_motes(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(13.0,1.0,0.0),
		Vector3(0.0,1.0,9.0),
		Vector3(0.0,1.0,-9.0)
	]

	for i: int in range(positions.size()):
		var particles := GPUParticles3D.new()
		particles.name = "InteriorDust_%d" % i
		particles.position = positions[i]
		particles.amount = 28
		particles.lifetime = 5.5
		particles.randomness = 1.0
		particles.visibility_aabb = AABB(Vector3(-4,-1,-4),Vector3(8,6,8))

		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.15,0.12,0.08)
		process.spread = 180.0
		process.initial_velocity_min = 0.015
		process.initial_velocity_max = 0.075
		process.gravity = Vector3(0,-0.004,0)
		process.scale_min = 0.025
		process.scale_max = 0.07
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(0.055,0.055)
		var dust := StandardMaterial3D.new()
		dust.albedo_color = Color(0.75,0.66,0.46,0.30)
		dust.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		dust.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dust.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = dust
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_ember_zones(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-11.0,0.9,-5.5),
		Vector3(16.0,0.9,8.0)
	]

	for i: int in range(positions.size()):
		var particles := GPUParticles3D.new()
		particles.name = "BattleEmbers_%d" % i
		particles.position = positions[i]
		particles.amount = 16
		particles.lifetime = 2.8
		particles.randomness = 0.9
		particles.visibility_aabb = AABB(Vector3(-2,-1,-2),Vector3(4,6,4))

		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.08,1.0,0.04)
		process.spread = 28.0
		process.initial_velocity_min = 0.35
		process.initial_velocity_max = 0.95
		process.gravity = Vector3(0,0.08,0)
		process.scale_min = 0.025
		process.scale_max = 0.065
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(0.06,0.06)
		var ember := StandardMaterial3D.new()
		ember.albedo_color = Color(1.0,0.30,0.035,0.88)
		ember.emission_enabled = true
		ember.emission = Color(1.0,0.18,0.015)
		ember.emission_energy_multiplier = 2.0
		ember.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ember.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ember.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = ember
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_cool_fill_lights(parent: Node3D) -> void:
	var points: Array[Vector3] = [
		Vector3(-10.0,3.2,2.0),
		Vector3(10.0,3.2,-2.0)
	]
	for i: int in range(points.size()):
		var light := OmniLight3D.new()
		light.name = "CoolBattleFill_%d" % i
		light.position = points[i]
		light.light_color = Color(0.38,0.48,0.58)
		light.light_energy = 0.12
		light.omni_range = 8.0
		light.shadow_enabled = false
		parent.add_child(light)


static func _build_warm_combat_glows(parent: Node3D) -> void:
	var points: Array[Vector3] = [
		Vector3(-18.0,1.0,-13.0),
		Vector3(17.0,1.0,13.5)
	]
	for i: int in range(points.size()):
		var light := OmniLight3D.new()
		light.name = "DistantFireGlow_%d" % i
		light.position = points[i]
		light.light_color = Color(1.0,0.27,0.055)
		light.light_energy = 0.25
		light.omni_range = 5.0
		light.shadow_enabled = false
		parent.add_child(light)
