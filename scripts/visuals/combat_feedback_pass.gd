extends Node
class_name CombatFeedbackPass

# v8.50.0 — local presentation only.
# Does not change authoritative combat logic, hit validation, damage, ammo,
# networking, or objective systems.

var root: Node
var camera: Camera3D
var elapsed: float = 0.0
var last_fire_down: bool = false
var fire_serial: int = 0
var casing_root: Node3D
var transient_root: Node3D
var camera_kick: Vector2 = Vector2.ZERO
var camera_kick_velocity: Vector2 = Vector2.ZERO
var base_camera_rotation: Vector3 = Vector3.ZERO
var base_rotation_ready: bool = false

func initialize(game_root: Node) -> void:
	root = game_root
	set_process(true)
	call_deferred("_setup")


func _setup() -> void:
	camera = _find_active_camera(root)
	if camera == null:
		return

	base_camera_rotation = camera.rotation
	base_rotation_ready = true

	casing_root = Node3D.new()
	casing_root.name = "LocalCasings_v850"
	root.add_child(casing_root)

	transient_root = Node3D.new()
	transient_root.name = "CombatTransients_v850"
	root.add_child(transient_root)


func _process(delta: float) -> void:
	elapsed += delta

	if camera == null or not is_instance_valid(camera):
		camera = _find_active_camera(root)
		if camera != null:
			base_camera_rotation = camera.rotation
			base_rotation_ready = true
		return

	_update_camera_kick(delta)

	var fire_down: bool = (
		Input.is_action_pressed("fire")
		if InputMap.has_action("fire")
		else false
	)

	if fire_down and not last_fire_down:
		_on_local_trigger()
	last_fire_down = fire_down


func _on_local_trigger() -> void:
	if camera == null:
		return

	fire_serial += 1
	var pistol: bool = _looks_like_pistol()
	_spawn_muzzle_flash(pistol)
	_spawn_muzzle_smoke(pistol)
	_spawn_casing(pistol)
	_apply_camera_kick(pistol)


func _looks_like_pistol() -> bool:
	var current_weapon_text: String = ""
	var player: Node = _find_local_player(root)
	if player != null:
		if "weapon" in player:
			current_weapon_text = str(player.get("weapon")).to_lower()
		if "current_weapon_index" in player:
			var weapon_index_value: Variant = player.get("current_weapon_index")
			if weapon_index_value is int and int(weapon_index_value) == 1:
				return true

	return (
		"pistol" in current_weapon_text
		or "tt" in current_weapon_text
		or "p38" in current_weapon_text
	)


func _spawn_muzzle_flash(pistol: bool) -> void:
	var flash_root: Node3D = Node3D.new()
	flash_root.name = "MuzzleFlash_%d" % fire_serial
	camera.add_child(flash_root)
	flash_root.position = (
		Vector3(0.25, -0.22, -1.05)
		if pistol
		else Vector3(0.31, -0.20, -1.42)
	)

	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.66, 0.18, 0.95)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.42, 0.07)
	flash_mat.emission_energy_multiplier = 4.5
	flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	# Crossed quads read like a volumetric flash from several viewing angles.
	for angle: float in [0.0, 45.0, 90.0, 135.0]:
		var quad_instance: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(
			0.18 if pistol else 0.27,
			0.18 if pistol else 0.27
		)
		quad.material = flash_mat
		quad_instance.mesh = quad
		quad_instance.rotation.z = deg_to_rad(angle)
		flash_root.add_child(quad_instance)

	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.58, 0.20)
	light.light_energy = 2.0 if pistol else 2.8
	light.omni_range = 3.0 if pistol else 4.2
	light.shadow_enabled = false
	flash_root.add_child(light)

	var timer: SceneTreeTimer = get_tree().create_timer(0.055)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(flash_root):
			flash_root.queue_free()
	)


func _spawn_muzzle_smoke(pistol: bool) -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "MuzzleSmoke_%d" % fire_serial
	camera.add_child(particles)
	particles.position = (
		Vector3(0.25, -0.22, -1.02)
		if pistol
		else Vector3(0.31, -0.20, -1.39)
	)
	particles.amount = 5 if pistol else 8
	particles.one_shot = true
	particles.lifetime = 0.65
	particles.explosiveness = 0.95
	particles.randomness = 0.55

	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.direction = Vector3(0.0, 0.12, -1.0)
	process.spread = 12.0
	process.initial_velocity_min = 0.20
	process.initial_velocity_max = 0.48
	process.gravity = Vector3(0.0, 0.28, 0.0)
	process.scale_min = 0.55
	process.scale_max = 1.0
	particles.process_material = process

	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var smoke_material: StandardMaterial3D = StandardMaterial3D.new()
	smoke_material.albedo_color = Color(0.32, 0.32, 0.30, 0.28)
	smoke_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad.material = smoke_material
	particles.draw_pass_1 = quad

	var timer: SceneTreeTimer = get_tree().create_timer(1.2)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


func _spawn_casing(pistol: bool) -> void:
	if casing_root == null or camera == null:
		return

	var casing: MeshInstance3D = MeshInstance3D.new()
	casing.name = "Casing_%d" % fire_serial
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.018 if pistol else 0.021
	mesh.bottom_radius = 0.018 if pistol else 0.021
	mesh.height = 0.055 if pistol else 0.068
	mesh.radial_segments = 10
	casing.mesh = mesh

	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.60, 0.44, 0.15)
	brass.metallic = 0.82
	brass.roughness = 0.34
	casing.material_override = brass

	var eject_local: Vector3 = (
		Vector3(0.20, -0.18, -0.66)
		if pistol
		else Vector3(0.27, -0.18, -0.88)
	)
	casing.global_position = camera.to_global(eject_local)
	casing.global_rotation = camera.global_rotation + Vector3(
		deg_to_rad(90.0),
		deg_to_rad(float((fire_serial * 23) % 60)),
		0.0
	)
	casing_root.add_child(casing)

	var local_right: Vector3 = camera.global_transform.basis.x.normalized()
	var local_up: Vector3 = camera.global_transform.basis.y.normalized()
	var local_back: Vector3 = camera.global_transform.basis.z.normalized()

	var velocity: Vector3 = (
		local_right * (1.35 if pistol else 1.7)
		+ local_up * (0.75 if pistol else 0.95)
		+ local_back * 0.25
	)

	var lifetime: float = 1.05
	var tween: Tween = casing.create_tween()
	tween.set_parallel(true)
	tween.tween_method(
		func(progress: float) -> void:
			if not is_instance_valid(casing):
				return
			var t: float = progress * lifetime
			var gravity: Vector3 = Vector3.DOWN * 4.9 * t * t
			casing.global_position += velocity * (lifetime / 30.0) + gravity * 0.0022
			casing.rotate_x(0.22)
			casing.rotate_z(0.34),
		0.0,
		1.0,
		lifetime
	)
	tween.tween_property(casing, "scale", Vector3(0.75, 0.75, 0.75), lifetime)
	tween.finished.connect(func() -> void:
		if is_instance_valid(casing):
			casing.queue_free()
	)


func _apply_camera_kick(pistol: bool) -> void:
	var vertical: float = 0.70 if pistol else 0.46
	var horizontal_sign: float = -1.0 if fire_serial % 2 == 0 else 1.0
	var horizontal: float = horizontal_sign * (0.12 if pistol else 0.08)

	camera_kick_velocity += Vector2(horizontal, vertical)


func _update_camera_kick(delta: float) -> void:
	if not base_rotation_ready or camera == null:
		return

	camera_kick_velocity += (-camera_kick * 46.0 - camera_kick_velocity * 12.5) * delta
	camera_kick += camera_kick_velocity * delta
	camera_kick.x = clampf(camera_kick.x, -1.4, 1.4)
	camera_kick.y = clampf(camera_kick.y, -2.0, 2.0)

	# Only a tiny local presentation offset. Player authoritative look direction
	# remains owned by the existing player script.
	camera.rotation.x = base_camera_rotation.x - deg_to_rad(camera_kick.y)
	camera.rotation.z = base_camera_rotation.z + deg_to_rad(camera_kick.x * 0.45)


func _find_local_player(node: Node) -> Node:
	for candidate: Node in node.find_children("*", "", true):
		if candidate.has_method("_is_local_player"):
			var value: Variant = candidate.call("_is_local_player")
			if value is bool and bool(value):
				return candidate
	return null


func _find_active_camera(node: Node) -> Camera3D:
	if node is Camera3D:
		var candidate: Camera3D = node as Camera3D
		if candidate.current:
			return candidate
	for child: Node in node.get_children():
		var found: Camera3D = _find_active_camera(child)
		if found != null:
			return found
	return null
