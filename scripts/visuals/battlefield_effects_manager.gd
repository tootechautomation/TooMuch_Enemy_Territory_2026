extends Node3D
class_name BattlefieldEffectsManager

var world_root: Node
var quality_manager: Node
var active_effects: Array[Node3D] = []

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager


func spawn_explosion(
	position: Vector3,
	scale_factor: float = 1.0
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var preset := _preset()
	var effect := Node3D.new()
	effect.name = "ExplosionFX"
	effect.global_position = position
	add_child(effect)
	active_effects.append(effect)

	var flash := OmniLight3D.new()
	flash.name = "ExplosionFlash"
	flash.omni_range = 5.0 * scale_factor
	flash.light_energy = (
		0.0 if preset == 0
		else 2.0 if preset == 1
		else 3.5
	)
	flash.light_color = Color(1.0, 0.45, 0.12)
	flash.shadow_enabled = false
	effect.add_child(flash)

	var smoke := GPUParticles3D.new()
	smoke.name = "ExplosionSmoke"
	smoke.amount = 8 if preset == 0 else 16 if preset == 1 else 28
	smoke.lifetime = 1.2 if preset == 0 else 1.8 if preset == 1 else 2.4
	smoke.one_shot = true
	smoke.explosiveness = 0.9

	var process := ParticleProcessMaterial.new()
	process.direction = Vector3.UP
	process.spread = 55.0
	process.initial_velocity_min = 2.5 * scale_factor
	process.initial_velocity_max = 6.0 * scale_factor
	process.gravity = Vector3(0.0, -1.5, 0.0)
	process.scale_min = 0.35 * scale_factor
	process.scale_max = 0.85 * scale_factor
	process.color = Color(0.16, 0.14, 0.12, 0.88)
	smoke.process_material = process

	var draw_mesh := SphereMesh.new()
	draw_mesh.radius = 0.22
	draw_mesh.height = 0.44
	smoke.draw_pass_1 = draw_mesh
	effect.add_child(smoke)
	smoke.emitting = true

	var timer := get_tree().create_timer(
		1.7 if preset == 0 else 2.8
	)
	timer.timeout.connect(
		func() -> void:
			if is_instance_valid(effect):
				active_effects.erase(effect)
				effect.queue_free()
	)


func spawn_fire(
	position: Vector3,
	lifetime: float = 8.0
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var preset := _preset()
	if preset == 0:
		lifetime = minf(lifetime, 4.0)

	var fire := Node3D.new()
	fire.name = "BattlefieldFire"
	fire.global_position = position
	add_child(fire)
	active_effects.append(fire)

	var particles := GPUParticles3D.new()
	particles.name = "FireParticles"
	particles.amount = 5 if preset == 0 else 10 if preset == 1 else 18
	particles.lifetime = 0.8
	particles.emitting = true

	var process := ParticleProcessMaterial.new()
	process.direction = Vector3.UP
	process.spread = 20.0
	process.initial_velocity_min = 0.8
	process.initial_velocity_max = 2.0
	process.gravity = Vector3(0.0, 0.6, 0.0)
	process.scale_min = 0.16
	process.scale_max = 0.34
	process.color = Color(1.0, 0.28, 0.045, 0.92)
	particles.process_material = process

	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	particles.draw_pass_1 = mesh
	fire.add_child(particles)

	if preset > 0:
		var light := OmniLight3D.new()
		light.omni_range = 3.4
		light.light_energy = 0.75 if preset == 1 else 1.2
		light.light_color = Color(1.0, 0.32, 0.08)
		light.shadow_enabled = false
		fire.add_child(light)

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(
		func() -> void:
			if is_instance_valid(fire):
				active_effects.erase(fire)
				fire.queue_free()
	)


func _preset() -> int:
	if quality_manager == null:
		return 1
	return clampi(int(quality_manager.get("current_preset")), 0, 2)


func spawn_vehicle_damage_smoke(
	parent_vehicle: Node3D,
	severity: float
) -> Node3D:
	if DisplayServer.get_name() == "headless":
		return null
	if parent_vehicle == null:
		return null

	var holder := Node3D.new()
	holder.name = "VehicleDamageSmoke"
	parent_vehicle.add_child(holder)
	holder.position = Vector3(0.0, 1.45, 0.35)

	var particles := GPUParticles3D.new()
	particles.amount = (
		4
		if _preset() == 0
		else 8
		if _preset() == 1
		else 14
	)
	particles.lifetime = 1.5
	particles.emitting = true

	var process := ParticleProcessMaterial.new()
	process.direction = Vector3.UP
	process.spread = 28.0
	process.initial_velocity_min = 0.5
	process.initial_velocity_max = 1.4
	process.gravity = Vector3(0.0, 0.3, 0.0)
	process.scale_min = 0.16 + severity * 0.12
	process.scale_max = 0.34 + severity * 0.26
	process.color = Color(0.11, 0.105, 0.10, 0.68)
	particles.process_material = process

	var mesh := SphereMesh.new()
	mesh.radius = 0.10
	mesh.height = 0.20
	particles.draw_pass_1 = mesh
	holder.add_child(particles)

	return holder


func spawn_vehicle_muzzle_flash(
	position: Vector3,
	scale_factor: float = 1.0
) -> void:
	if DisplayServer.get_name() == "headless":
		return

	var flash := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.10 * scale_factor
	mesh.height = 0.20 * scale_factor
	flash.mesh = mesh
	flash.global_position = position

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.62, 0.12)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.25, 0.03)
	flash.material_override = material
	add_child(flash)

	get_tree().create_timer(0.055).timeout.connect(
		func() -> void:
			if is_instance_valid(flash):
				flash.queue_free()
	)
