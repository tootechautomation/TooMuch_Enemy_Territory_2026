extends RefCounted
class_name HeroEnvironmentDetailPass

# v8.64 — code-built environment depth/details inspired by the visual target.
# Visual-only: no collision changes.

static func apply(root: Node) -> void:
	if root == null or root.has_node("HeroEnvironmentDetailPass_v864"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "HeroEnvironmentDetailPass_v864"
	root.add_child(holder)

	var brick: StandardMaterial3D = _mat(Color(0.24, 0.105, 0.060), 0.94)
	var concrete: StandardMaterial3D = _mat(Color(0.285, 0.275, 0.255), 0.96)
	var wood: StandardMaterial3D = _mat(Color(0.18, 0.095, 0.040), 0.88)
	var metal: StandardMaterial3D = _mat(Color(0.105, 0.11, 0.105), 0.54, 0.58)
	var dark: StandardMaterial3D = _mat(Color(0.018, 0.020, 0.020), 0.78)
	var mud: StandardMaterial3D = _mat(Color(0.095, 0.075, 0.050), 0.86)
	var puddle: StandardMaterial3D = _mat(Color(0.055, 0.065, 0.070), 0.18)

	_build_deep_facades(holder, brick, concrete, dark, wood)
	_build_roof_damage(holder, wood, metal)
	_build_ground_detail(holder, mud, puddle, brick, wood)
	_build_lamp_clusters(holder, metal)
	_build_smoke(holder)
	_build_cover_clusters(holder, wood, metal, concrete)


static func _build_deep_facades(
	parent: Node3D,
	brick: Material,
	concrete: Material,
	dark: Material,
	wood: Material
) -> void:
	var buildings: Array[Vector3] = [
		Vector3(-12.0, 0.0, -11.0),
		Vector3(-13.5, 0.0, 11.5),
		Vector3(11.8, 0.0, 11.5),
		Vector3(17.0, 0.0, -8.0)
	]
	var yaws: Array[float] = [6.0, -7.0, 4.0, -5.0]

	for index: int in range(buildings.size()):
		var shell: Node3D = Node3D.new()
		shell.name = "DetailedFacade_%d" % index
		shell.position = buildings[index]
		shell.rotation.y = deg_to_rad(yaws[index])
		parent.add_child(shell)

		var wall_mat: Material = brick if index % 2 == 0 else concrete

		# Main shell with deep open sections rather than a single box.
		_box(shell, "BackWall", Vector3(0.0, 2.2, 2.2),
			Vector3(6.4, 4.4, 0.42), wall_mat)
		_box(shell, "LeftPier", Vector3(-2.85, 2.0, 0.0),
			Vector3(0.55, 4.0, 4.6), wall_mat)
		_box(shell, "RightPier", Vector3(2.85, 1.65, 0.4),
			Vector3(0.55, 3.3, 3.8), wall_mat)

		# Dark interior volumes create genuine visual depth.
		_box(shell, "InteriorVoid", Vector3(0.0, 1.65, 1.85),
			Vector3(4.4, 2.7, 0.18), dark)
		_box(shell, "DoorVoid", Vector3(-1.25, 1.0, 1.72),
			Vector3(1.15, 2.05, 0.12), dark)
		_box(shell, "WindowVoid", Vector3(1.30, 2.0, 1.72),
			Vector3(1.25, 1.15, 0.12), dark)

		# Recess frames / lintels.
		for x: float in [-1.25, 1.30]:
			_box(shell, "OpeningLintel", Vector3(x, 2.62, 1.62),
				Vector3(1.45, 0.16, 0.32), concrete)
			_box(shell, "OpeningSill", Vector3(x, 1.33, 1.62),
				Vector3(1.38, 0.13, 0.32), concrete)

		# Interior floor edge and scattered crates.
		_box(shell, "FloorLip", Vector3(0.0, 0.25, 1.65),
			Vector3(5.0, 0.18, 0.65), concrete)

		for c: int in range(3):
			_box(shell, "InteriorCrate", Vector3(-0.8 + c*0.75, 0.55, 1.15),
				Vector3(0.62, 0.62, 0.62), wood, float(c*11))


static func _build_roof_damage(
	parent: Node3D,
	wood: Material,
	metal: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-12.0, 4.5, -11.0),
		Vector3(11.8, 4.4, 11.5),
		Vector3(17.0, 4.0, -8.0)
	]

	for b: int in range(centers.size()):
		var base: Vector3 = centers[b]
		for i: int in range(5):
			var beam := _box(
				parent,
				"BrokenRoofBeam",
				base + Vector3(-2.0 + i*1.0, 0.0, 0.0),
				Vector3(0.16, 0.18, 4.2),
				wood,
				0.0
			)
			beam.rotation.x = deg_to_rad(-8.0 + float((i+b)%4)*5.0)
			beam.rotation.z = deg_to_rad(-4.0 + float(i%3)*4.0)

		# Hanging/broken metal sheet.
		var sheet := _box(
			parent,
			"BrokenRoofSheet",
			base + Vector3(1.2, -0.18, 0.3),
			Vector3(1.8, 0.08, 1.4),
			metal,
			float(b*9)
		)
		sheet.rotation.x = deg_to_rad(11.0 + b*4.0)


static func _build_ground_detail(
	parent: Node3D,
	mud: Material,
	puddle: Material,
	brick: Material,
	wood: Material
) -> void:
	var puddles: Array[Vector3] = [
		Vector3(-4.0, 0.016, 2.5),
		Vector3(3.5, 0.016, -1.5),
		Vector3(9.5, 0.016, 7.0),
		Vector3(-10.5, 0.016, 7.5),
		Vector3(15.5, 0.016, -5.0)
	]

	for i: int in range(puddles.size()):
		_box(parent, "MudBase", puddles[i],
			Vector3(2.4, 0.018, 1.4), mud, float(i*14))
		_box(parent, "Puddle", puddles[i] + Vector3(0,0.010,0),
			Vector3(1.55, 0.012, 0.82), puddle, float(i*14+3))

		for d: int in range(6):
			var angle: float = deg_to_rad(float(d*57 + i*21))
			_box(parent, "GroundDebris",
				puddles[i] + Vector3(cos(angle)*0.95, 0.06, sin(angle)*0.62),
				Vector3(0.13,0.09,0.17),
				brick if d%2==0 else wood,
				float(d*19))


static func _build_lamp_clusters(
	parent: Node3D,
	metal: Material
) -> void:
	var positions: Array[Vector3] = [
		Vector3(-7.0,0.0,1.5),
		Vector3(6.2,0.0,-2.0),
		Vector3(13.0,0.0,3.0),
		Vector3(-12.0,0.0,8.2),
		Vector3(17.0,0.0,-5.0)
	]

	for i: int in range(positions.size()):
		var p: Vector3 = positions[i]

		_box(parent, "LampPost", p + Vector3.UP*1.3,
			Vector3(0.09,2.6,0.09), metal)

		var lamp: OmniLight3D = OmniLight3D.new()
		lamp.name = "WarmLamp_%d" % i
		lamp.position = p + Vector3(0.0,2.55,0.0)
		lamp.light_color = Color(1.0,0.58,0.24)
		lamp.light_energy = 0.55
		lamp.omni_range = 5.0
		lamp.shadow_enabled = true
		parent.add_child(lamp)


static func _build_smoke(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-13.0,0.8,-12.0),
		Vector3(16.0,0.8,7.0),
		Vector3(2.0,0.8,15.0)
	]

	for i: int in range(positions.size()):
		var particles: GPUParticles3D = GPUParticles3D.new()
		particles.name = "BattleSmoke_%d" % i
		particles.position = positions[i]
		particles.amount = 24
		particles.lifetime = 6.0
		particles.randomness = 0.72
		particles.visibility_aabb = AABB(Vector3(-5,0,-5),Vector3(10,16,10))

		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.05,1.0,0.02)
		process.spread = 20.0
		process.initial_velocity_min = 0.35
		process.initial_velocity_max = 0.85
		process.gravity = Vector3(0.0,0.06,0.0)
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(1.35,1.35)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.075,0.075,0.07,0.20)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = mat
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_cover_clusters(
	parent: Node3D,
	wood: Material,
	metal: Material,
	concrete: Material
) -> void:
	var clusters: Array[Vector3] = [
		Vector3(-5.0,0.0,-5.0),
		Vector3(5.0,0.0,5.0),
		Vector3(12.0,0.0,-4.0)
	]

	for c: int in range(clusters.size()):
		var base := clusters[c]

		for i: int in range(4):
			_box(parent, "CoverCrate",
				base + Vector3((i%2)*0.82,0.38+(i/2)*0.68,(i%3)*0.15),
				Vector3(0.72,0.68,0.72), wood, float(i*7))

		var barrier := _box(parent, "BrokenBarrier",
			base + Vector3(-0.8,0.55,1.0),
			Vector3(1.6,1.1,0.28), concrete, -12.0)
		barrier.rotation.z = deg_to_rad(4.0)

		for i: int in range(2):
			var steel := _box(parent, "SteelDebris",
				base + Vector3(-0.5+i*1.5,0.7,-0.8),
				Vector3(0.10,1.7,0.12), metal, 0.0)
			steel.rotation.z = deg_to_rad(-45.0 if i==0 else 45.0)


static func _mat(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m


static func _box(
	parent: Node3D,
	name: String,
	pos: Vector3,
	size: Vector3,
	mat: Material,
	yaw: float = 0.0
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation.y = deg_to_rad(yaw)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
