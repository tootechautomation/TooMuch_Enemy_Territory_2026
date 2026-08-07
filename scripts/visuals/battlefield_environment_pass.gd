extends RefCounted
class_name BattlefieldEnvironmentPass

# v8.48.0 — battlefield composition/environmental storytelling.
# Visual-only: does not alter authoritative collision or objectives.

static func apply(root: Node) -> void:
	if root == null or root.has_node("BattlefieldEnvironmentPass_v848"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "BattlefieldEnvironmentPass_v848"
	root.add_child(holder)

	var wood: StandardMaterial3D = _mat(root, "wood", Color(0.17, 0.10, 0.05), 0.95)
	var rust: StandardMaterial3D = _mat(root, "rust", Color(0.15, 0.13, 0.105), 0.82, 0.28)
	var dark: StandardMaterial3D = _mat(root, "", Color(0.055, 0.055, 0.05), 0.90)
	var canvas: StandardMaterial3D = _mat(root, "", Color(0.19, 0.20, 0.135), 0.98)
	var foliage: StandardMaterial3D = _mat(root, "", Color(0.10, 0.15, 0.075), 0.99)
	var concrete: StandardMaterial3D = _mat(root, "concrete", Color(0.22, 0.22, 0.205), 0.96)

	_build_utility_lines(holder, wood, dark)
	_build_fence_lines(holder, wood, rust)
	_build_destroyed_equipment(holder, rust, dark)
	_build_supply_clutter(holder, wood, canvas, rust)
	_build_vegetation_breakup(holder, foliage, wood)
	_build_signage(holder, wood, dark)
	_build_drainage(holder, concrete, rust)
	_build_smoke_and_fog(holder)
	_build_objective_lighting(holder)


static func _mat(root: Node, kind: String, color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	var albedo_name: String = ""
	match kind:
		"wood": albedo_name = "pbr_wood_albedo"
		"rust": albedo_name = "pbr_rust_albedo"
		"concrete": albedo_name = "pbr_concrete_albedo"
	if albedo_name != "":
		var value: Variant = root.get(albedo_name)
		if value is Texture2D:
			m.albedo_texture = value as Texture2D
			m.uv1_triplanar = true
			m.uv1_world_triplanar = true
			m.uv1_scale = Vector3(0.7, 0.7, 0.7)
	return m


static func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, mat: Material, yaw: float = 0.0) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation.y = deg_to_rad(yaw)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _cyl(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, mat: Material) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _build_utility_lines(parent: Node3D, wood: Material, wire: Material) -> void:
	var poles: Array[Vector3] = [
		Vector3(-15.0, 0.0, -5.8), Vector3(-7.5, 0.0, -5.6),
		Vector3(0.0, 0.0, -5.4), Vector3(7.5, 0.0, -5.1),
		Vector3(15.0, 0.0, -4.8)
	]
	for i: int in range(poles.size()):
		var p: Vector3 = poles[i]
		_cyl(parent, "UtilityPole", p + Vector3.UP * 2.8, 0.10, 5.6, wood)
		_box(parent, "CrossArm", p + Vector3.UP * 5.1, Vector3(1.35, 0.10, 0.12), wood)
		for xoff: float in [-0.48, 0.0, 0.48]:
			_cyl(parent, "Insulator", p + Vector3(xoff, 5.24, 0.0), 0.045, 0.20, wire)

	# Thin visual wire spans.
	for i: int in range(poles.size() - 1):
		var a: Vector3 = poles[i] + Vector3(0.0, 5.27, 0.0)
		var b: Vector3 = poles[i + 1] + Vector3(0.0, 5.27, 0.0)
		for xoff: float in [-0.48, 0.0, 0.48]:
			_beam_between(parent, "PowerWire", a + Vector3(xoff,0,0), b + Vector3(xoff,0,0), 0.018, wire)


static func _build_fence_lines(parent: Node3D, wood: Material, rust: Material) -> void:
	var origins: Array[Vector3] = [Vector3(-17,0,6.8), Vector3(5,0,14.5)]
	var yaws: Array[float] = [0.0, 90.0]
	for f: int in range(origins.size()):
		var fence: Node3D = Node3D.new()
		fence.position = origins[f]
		fence.rotation.y = deg_to_rad(yaws[f])
		parent.add_child(fence)
		for i: int in range(9):
			var x: float = float(i) * 1.35
			_box(fence, "FencePost", Vector3(x,0.75,0), Vector3(0.11,1.5,0.11), wood)
			if i < 8:
				_box(fence, "FenceRail", Vector3(x+0.675,0.95,0), Vector3(1.25,0.07,0.08), rust)
				_box(fence, "FenceRail", Vector3(x+0.675,0.45,0), Vector3(1.25,0.07,0.08), rust)


static func _build_destroyed_equipment(parent: Node3D, rust: Material, dark: Material) -> void:
	var spots: Array[Vector3] = [Vector3(-8,0,5.5), Vector3(17,0,8), Vector3(-13,0,-13)]
	for n: int in range(spots.size()):
		var wreck: Node3D = Node3D.new()
		wreck.position = spots[n]
		wreck.rotation.y = deg_to_rad(float(n * 37 - 18))
		parent.add_child(wreck)
		var body: MeshInstance3D = _box(wreck,"WreckBody",Vector3(0,0.65,0),Vector3(3.0,0.8,1.55),rust)
		body.rotation.z = deg_to_rad(float(n-1)*5.0)
		_box(wreck,"WreckCab",Vector3(-0.75,1.25,0),Vector3(1.2,0.75,1.35),dark)
		for x: float in [-1.0,1.0]:
			for z: float in [-0.78,0.78]:
				var wheel: MeshInstance3D = _cyl(wreck,"Wheel",Vector3(x,0.42,z),0.38,0.20,dark)
				wheel.rotation.x = deg_to_rad(90.0)


static func _build_supply_clutter(parent: Node3D, wood: Material, canvas: Material, rust: Material) -> void:
	var clusters: Array[Vector3] = [Vector3(6,0,-11),Vector3(-9,0,11),Vector3(19,0,18)]
	for c: int in range(clusters.size()):
		var base: Vector3 = clusters[c]
		for i: int in range(5):
			_box(parent,"FieldCrate",base+Vector3(float(i%3)*0.75,0.35+float(i/3)*0.65,float(i%2)*0.55),
				Vector3(0.68,0.62,0.62),wood,float(i*9))
		for i: int in range(2):
			_cyl(parent,"FuelCanCluster",base+Vector3(-0.65+float(i)*0.42,0.42,0.8),0.25,0.84,rust)
		_box(parent,"CanvasBundle",base+Vector3(1.7,0.25,0.4),Vector3(1.2,0.45,0.75),canvas,12.0)


static func _build_vegetation_breakup(parent: Node3D, foliage: Material, wood: Material) -> void:
	var spots: Array[Vector3] = [
		Vector3(-18,0,-10),Vector3(-16,0,13),Vector3(-5,0,16),
		Vector3(4,0,-15),Vector3(16,0,-12),Vector3(21,0,4),
		Vector3(9,0,16),Vector3(-11,0,3)
	]
	for s: int in range(spots.size()):
		var p: Vector3 = spots[s]
		_cyl(parent,"ShrubStem",p+Vector3.UP*0.45,0.055,0.9,wood)
		for i: int in range(4):
			var leaf: MeshInstance3D = _box(parent,"Foliage",p+Vector3(
				-0.35+float(i%2)*0.7,0.75+float(i/2)*0.38,-0.2+float((i+1)%2)*0.4),
				Vector3(0.75,0.55,0.55),foliage,float(i*27))
			leaf.rotation.z = deg_to_rad(float(i-2)*8.0)


static func _build_signage(parent: Node3D, wood: Material, dark: Material) -> void:
	var signs: Array[Vector3] = [Vector3(-3,0,-6.5),Vector3(12,0,6.5),Vector3(20,0,25)]
	for i: int in range(signs.size()):
		var p: Vector3 = signs[i]
		_box(parent,"SignPost",p+Vector3.UP*0.85,Vector3(0.12,1.7,0.12),wood)
		_box(parent,"DirectionBoard",p+Vector3(0.45,1.45,0),Vector3(1.45,0.42,0.10),dark,float(i*8-8))


static func _build_drainage(parent: Node3D, concrete: Material, rust: Material) -> void:
	for p: Vector3 in [Vector3(-5.5,0,-3.5),Vector3(9,0,3.6)]:
		var pipe: MeshInstance3D = _cyl(parent,"DrainPipe",p+Vector3.UP*0.22,0.42,1.2,concrete)
		pipe.rotation.z = deg_to_rad(90.0)
		_box(parent,"DrainGrate",p+Vector3(0.62,0.22,0),Vector3(0.05,0.75,0.75),rust)


static func _build_smoke_and_fog(parent: Node3D) -> void:
	# GPU particles are intentionally lightweight and purely atmospheric.
	var positions: Array[Vector3] = [Vector3(-13,0,-13),Vector3(17,0,8)]
	for i: int in range(positions.size()):
		var particles: GPUParticles3D = GPUParticles3D.new()
		particles.name = "DistantSmoke_%d" % i
		particles.position = positions[i] + Vector3.UP * 1.2
		particles.amount = 28
		particles.lifetime = 5.5
		particles.randomness = 0.65
		particles.visibility_aabb = AABB(Vector3(-5,0,-5),Vector3(10,15,10))
		var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
		process.direction = Vector3(0.08,1.0,0.03)
		process.spread = 18.0
		process.initial_velocity_min = 0.45
		process.initial_velocity_max = 1.0
		process.gravity = Vector3(0,0.10,0)
		particles.process_material = process
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(1.4,1.4)
		var smoke_mat: StandardMaterial3D = StandardMaterial3D.new()
		smoke_mat.albedo_color = Color(0.12,0.12,0.115,0.20)
		smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smoke_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = smoke_mat
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_objective_lighting(parent: Node3D) -> void:
	var lights: Array[Vector3] = [Vector3(13,2.1,0),Vector3(0,2.4,9),Vector3(0,2.4,-9)]
	for i: int in range(lights.size()):
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "ObjectivePractical_%d" % i
		light.position = lights[i]
		light.light_color = Color(1.0,0.72,0.42)
		light.light_energy = 0.65
		light.omni_range = 5.0
		light.shadow_enabled = true
		parent.add_child(light)


static func _beam_between(parent: Node3D, name: String, a: Vector3, b: Vector3, thickness: float, mat: Material) -> void:
	var delta: Vector3 = b - a
	var length: float = delta.length()
	if length <= 0.001:
		return
	var mi: MeshInstance3D = _box(parent,name,(a+b)*0.5,Vector3(thickness,thickness,length),mat)
	mi.look_at(b, Vector3.UP)
