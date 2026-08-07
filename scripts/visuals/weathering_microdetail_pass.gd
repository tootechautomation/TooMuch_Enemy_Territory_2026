extends RefCounted
class_name WeatheringMicrodetailPass

# v8.54.0 — visual-only microdetail/weathering.
# Adds depth cues and rain aging without touching collision or gameplay.

static func apply(root: Node) -> void:
	if root == null or root.has_node("WeatheringMicrodetailPass_v854"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "WeatheringMicrodetailPass_v854"
	root.add_child(holder)

	var structural_meshes: Array[MeshInstance3D] = []
	for node: Node in root.find_children("*", "MeshInstance3D", true):
		var mi: MeshInstance3D = node as MeshInstance3D
		if mi == null or mi.mesh == null or not mi.visible:
			continue

		var key: String = (mi.name + " " + str(mi.get_path())).to_lower()
		if (
			"wall" in key or "building" in key or "house" in key
			or "bunker" in key or "fort" in key or "depot" in key
			or "facade" in key or "warehouse" in key
		):
			structural_meshes.append(mi)

	for mi: MeshInstance3D in structural_meshes:
		_weather_structure(holder, mi)

	_add_ground_microdetail(holder)
	_add_rain_splash_fields(holder)


static func _weather_structure(parent: Node3D, source: MeshInstance3D) -> void:
	var aabb: AABB = source.get_aabb()
	var scale: Vector3 = source.global_transform.basis.get_scale().abs()
	var size: Vector3 = aabb.size * scale
	if maxf(size.x, size.z) < 2.5 or size.y < 1.8:
		return

	var center: Vector3 = source.global_transform * (
		aabb.position + aabb.size * 0.5
	)
	var thin_z: bool = size.z <= size.x
	var width: float = size.x if thin_z else size.z
	var outward: Vector3 = (
		source.global_transform.basis.z.normalized()
		if thin_z
		else source.global_transform.basis.x.normalized()
	)
	var tangent: Vector3 = (
		source.global_transform.basis.x.normalized()
		if thin_z
		else source.global_transform.basis.z.normalized()
	)
	var basis: Basis = _face_basis(tangent, outward)

	var grime: StandardMaterial3D = _transparent_material(
		Color(0.055, 0.048, 0.040, 0.34),
		0.98
	)
	var soot: StandardMaterial3D = _transparent_material(
		Color(0.018, 0.018, 0.017, 0.27),
		0.99
	)
	var wet: StandardMaterial3D = _transparent_material(
		Color(0.09, 0.10, 0.10, 0.16),
		0.30
	)
	var rust: StandardMaterial3D = _solid_material(
		Color(0.23, 0.095, 0.045),
		0.78,
		0.18
	)

	# Dark damp/grime band along lower walls.
	_box(
		parent,
		"LowerWallGrime",
		center - Vector3.UP * (size.y * 0.5 - 0.28) + outward * 0.17,
		Vector3(width * 0.94, 0.48, 0.025),
		basis,
		grime
	)

	# Thin wet strip above the grime produces a rain-darkened gradient.
	_box(
		parent,
		"WetWallBand",
		center - Vector3.UP * (size.y * 0.5 - 0.62) + outward * 0.175,
		Vector3(width * 0.88, 0.34, 0.020),
		basis,
		wet
	)

	# Water streaks below roof/cornice at irregular deterministic intervals.
	var streak_count: int = clampi(int(width / 1.7), 1, 8)
	for i: int in range(streak_count):
		if (i + int(source.get_instance_id())) % 3 == 0:
			continue
		var alpha: float = (
			float(i + 1) / float(streak_count + 1)
		)
		var x: float = lerpf(-width * 0.43, width * 0.43, alpha)
		var streak_height: float = 0.55 + 0.16 * float(i % 4)
		_box(
			parent,
			"RainStreak",
			center
				+ tangent * x
				+ Vector3.UP * (size.y * 0.22)
				+ outward * 0.18,
			Vector3(0.045, streak_height, 0.018),
			basis,
			grime
		)

	# A few irregular soot streaks/impact scars.
	for i: int in range(clampi(int(width / 3.6), 1, 4)):
		var x: float = -width * 0.30 + float(i) * minf(2.6, width * 0.28)
		var y: float = -size.y * 0.02 + 0.32 * float(i % 2)
		_box(
			parent,
			"SootScar",
			center + tangent * x + Vector3.UP * y + outward * 0.185,
			Vector3(0.26, 0.58, 0.022),
			basis.rotated(Vector3.FORWARD, deg_to_rad(7.0 * float(i - 1))),
			soot
		)

	# Gutters/downspouts create small-scale architectural silhouette.
	if width >= 4.0 and size.y >= 2.5:
		_box(
			parent,
			"RoofGutter",
			center
				+ Vector3.UP * (size.y * 0.5 - 0.08)
				+ outward * 0.22,
			Vector3(width * 0.92, 0.07, 0.09),
			basis,
			rust
		)

		for side: float in [-1.0, 1.0]:
			var x: float = side * width * 0.40
			_box(
				parent,
				"Downspout",
				center
					+ tangent * x
					+ Vector3.UP * (-0.03)
					+ outward * 0.23,
				Vector3(0.07, size.y * 0.86, 0.08),
				basis,
				rust
			)


static func _add_ground_microdetail(parent: Node3D) -> void:
	var dark_mud: StandardMaterial3D = _solid_material(
		Color(0.105, 0.082, 0.050),
		0.96
	)
	var wet_mud: StandardMaterial3D = _solid_material(
		Color(0.085, 0.075, 0.055),
		0.34
	)
	var gravel: StandardMaterial3D = _solid_material(
		Color(0.20, 0.19, 0.17),
		0.98
	)

	var patches: Array[Vector3] = [
		Vector3(-7.0, 0.025, -3.8),
		Vector3(3.5, 0.025, 4.2),
		Vector3(11.2, 0.025, -6.0),
		Vector3(-12.0, 0.025, 9.5),
		Vector3(18.0, 0.025, 12.0),
		Vector3(5.0, 0.025, -12.0)
	]

	for p: int in range(patches.size()):
		var base: Vector3 = patches[p]

		# Dark tire/foot traffic strips.
		for i: int in range(3):
			var offset: Vector3 = Vector3(
				-0.65 + float(i) * 0.65,
				0.0,
				0.18 * float((i + p) % 2)
			)
			_box(
				parent,
				"MudTrack",
				base + offset,
				Vector3(0.48, 0.025, 2.1),
				Basis(Vector3.UP, deg_to_rad(float(p * 17))),
				dark_mud
			)

		# Small reflective wet patch.
		_box(
			parent,
			"WetPatch",
			base + Vector3(0.25, 0.006, -0.35),
			Vector3(1.4, 0.012, 0.85),
			Basis(Vector3.UP, deg_to_rad(float(p * 13))),
			wet_mud
		)

		# Pebble/debris cluster.
		for i: int in range(7):
			var ang: float = deg_to_rad(float(i * 51 + p * 19))
			var radius: float = 0.35 + 0.08 * float(i % 3)
			_box(
				parent,
				"GroundChip",
				base + Vector3(
					cos(ang) * radius,
					0.045,
					sin(ang) * radius
				),
				Vector3(
					0.08 + 0.025 * float(i % 3),
					0.045 + 0.015 * float(i % 2),
					0.10 + 0.020 * float((i + 1) % 3)
				),
				Basis(Vector3.UP, ang),
				gravel
			)


static func _add_rain_splash_fields(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-4.0, 0.05, -1.0),
		Vector3(6.0, 0.05, 2.5),
		Vector3(13.0, 0.05, -2.0)
	]

	for index: int in range(positions.size()):
		var particles: GPUParticles3D = GPUParticles3D.new()
		particles.name = "RainSplashField_%d" % index
		particles.position = positions[index]
		particles.amount = 18
		particles.lifetime = 0.38
		particles.randomness = 0.85
		particles.visibility_aabb = AABB(
			Vector3(-4.0, -0.2, -4.0),
			Vector3(8.0, 1.6, 8.0)
		)

		var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
		process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		process.emission_box_extents = Vector3(3.5, 0.04, 3.5)
		process.direction = Vector3(0.0, 1.0, 0.0)
		process.spread = 38.0
		process.initial_velocity_min = 0.10
		process.initial_velocity_max = 0.38
		process.gravity = Vector3(0.0, -1.4, 0.0)
		particles.process_material = process

		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(0.035, 0.08)
		var splash: StandardMaterial3D = StandardMaterial3D.new()
		splash.albedo_color = Color(0.70, 0.78, 0.82, 0.32)
		splash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		splash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = splash
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _solid_material(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


static func _transparent_material(
	color: Color,
	roughness: float
) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


static func _box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	basis: Basis,
	material: Material
) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	mi.global_transform = Transform3D(basis.orthonormalized(), position)
	return mi


static func _face_basis(tangent: Vector3, outward: Vector3) -> Basis:
	var x_axis: Vector3 = tangent.normalized()
	var z_axis: Vector3 = outward.normalized()
	var y_axis: Vector3 = z_axis.cross(x_axis).normalized()
	if y_axis.dot(Vector3.UP) < 0.0:
		y_axis = -y_axis
	return Basis(x_axis, y_axis, z_axis)
