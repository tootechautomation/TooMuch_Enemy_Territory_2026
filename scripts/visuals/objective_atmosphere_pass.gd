extends RefCounted
class_name ObjectiveAtmospherePass

# v8.62 visual-only objective atmosphere and depth cues.

static func apply(root: Node) -> void:
	if root == null or root.has_node("ObjectiveAtmospherePass_v862"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "ObjectiveAtmospherePass_v862"
	root.add_child(holder)

	_add_light_pools(holder)
	_add_smoke_columns(holder)
	_add_debris_silhouettes(holder)


static func _add_light_pools(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(13.0, 1.4, 0.0),
		Vector3(0.0, 1.3, 9.0),
		Vector3(0.0, 1.3, -9.0),
		Vector3(-8.0, 1.3, 6.0)
	]

	for i: int in range(positions.size()):
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "ObjectivePool_%d" % i
		light.position = positions[i]
		light.light_color = Color(1.0, 0.60, 0.26)
		light.light_energy = 0.24
		light.omni_range = 4.8
		light.shadow_enabled = true
		parent.add_child(light)


static func _add_smoke_columns(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-12.0, 0.6, -12.0),
		Vector3(16.0, 0.6, 7.0)
	]

	for i: int in range(positions.size()):
		var particles: GPUParticles3D = GPUParticles3D.new()
		particles.name = "AtmosphereSmoke_%d" % i
		particles.position = positions[i]
		particles.amount = 20
		particles.lifetime = 5.0
		particles.randomness = 0.7
		particles.visibility_aabb = AABB(
			Vector3(-4.0, 0.0, -4.0),
			Vector3(8.0, 13.0, 8.0)
		)

		var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
		process.direction = Vector3(0.05, 1.0, 0.02)
		process.spread = 16.0
		process.initial_velocity_min = 0.35
		process.initial_velocity_max = 0.8
		process.gravity = Vector3(0.0, 0.08, 0.0)
		particles.process_material = process

		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(1.15, 1.15)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.10, 0.10, 0.095, 0.18)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = mat
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _add_debris_silhouettes(parent: Node3D) -> void:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.07, 0.065, 0.055)
	mat.roughness = 0.96

	var spots: Array[Vector3] = [
		Vector3(-5.0, 0.25, 4.0),
		Vector3(8.0, 0.25, -6.0),
		Vector3(14.0, 0.25, 4.5)
	]

	for i: int in range(spots.size()):
		var mi: MeshInstance3D = MeshInstance3D.new()
		mi.name = "DebrisSilhouette_%d" % i
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(1.4, 0.5, 0.55)
		mi.mesh = mesh
		mi.position = spots[i]
		mi.rotation.y = deg_to_rad(float(i * 23 - 14))
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		parent.add_child(mi)
