extends RefCounted
class_name StructuralDepthReconstruction

# Geometry-first visual depth pass. All added geometry is visual-only so the
# existing gameplay collision system remains authoritative.
# v8.46.2: strict typing for projects that treat warnings as parser errors.

static func apply(root: Node) -> void:
	if root == null or root.has_node("StructuralDepthReconstruction_v845"):
		return

	var detail_root: Node3D = Node3D.new()
	detail_root.name = "StructuralDepthReconstruction_v845"
	root.add_child(detail_root)

	for node: Node in root.find_children("*", "MeshInstance3D", true):
		var source: MeshInstance3D = node as MeshInstance3D
		if source == null or source.mesh == null or not source.visible:
			continue
		_reconstruct_mesh(detail_root, source)

	_add_depth_debris(detail_root)


static func _reconstruct_mesh(parent: Node3D, source: MeshInstance3D) -> void:
	var key: String = (source.name + " " + str(source.get_path())).to_lower()
	var structural: bool = (
		"wall" in key or "building" in key or "house" in key or
		"warehouse" in key or "bunker" in key or "fort" in key or
		"depot" in key or "facade" in key
	)
	if not structural:
		return

	var aabb: AABB = source.get_aabb()
	var source_scale: Vector3 = source.global_transform.basis.get_scale().abs()
	var size: Vector3 = aabb.size * source_scale
	if maxf(size.x, size.z) < 3.0 or size.y < 2.0:
		return

	var c: Vector3 = source.global_transform * (aabb.position + aabb.size * 0.5)
	var thin_z: bool = size.z <= size.x
	var w: float = size.x if thin_z else size.z
	var o: Vector3 = (
		source.global_transform.basis.z.normalized()
		if thin_z
		else source.global_transform.basis.x.normalized()
	)
	var t: Vector3 = (
		source.global_transform.basis.x.normalized()
		if thin_z
		else source.global_transform.basis.z.normalized()
	)
	var b: Basis = _face_basis(t, o)

	_box(
		parent,
		"Foundation",
		c - Vector3.UP * (size.y * 0.5 - 0.18) + o * 0.10,
		Vector3(w + 0.18, 0.36, 0.26),
		b,
		_mat(Color(0.15, 0.145, 0.13))
	)
	_box(
		parent,
		"Cornice",
		c + Vector3.UP * (size.y * 0.5 - 0.10) + o * 0.14,
		Vector3(w + 0.28, 0.20, 0.34),
		b,
		_mat(Color(0.22, 0.21, 0.19))
	)

	var breaks: int = clampi(int(floor(w / 2.7)), 1, 8)
	for i: int in range(breaks + 1):
		var denominator: float = float(maxi(breaks, 1))
		var alpha: float = float(i) / denominator
		var x: float = lerpf(-w * 0.47, w * 0.47, alpha)
		_box(
			parent,
			"Pilaster",
			c + t * x + o * 0.115,
			Vector3(0.18, size.y * 0.91, 0.24),
			b,
			_mat(Color(0.20, 0.19, 0.17))
		)

	var cols: int = clampi(int(floor(w / 3.2)), 1, 5)
	var rows: int = 1 if size.y < 4.2 else 2
	for row: int in range(rows):
		for col: int in range(cols):
			var source_id: int = int(source.get_instance_id())
			if (row * 7 + col * 3 + source_id) % 5 == 0:
				continue

			var x: float = (
				-w * 0.5
				+ (float(col) + 0.5) * (w / float(cols))
			)
			var row_step: float = minf(2.05, size.y * 0.34)
			var y: float = -size.y * 0.18 + float(row) * row_step
			var pw: float = minf(1.25, (w / float(cols)) * 0.52)
			var ph: float = minf(1.55, size.y * 0.31)
			var p: Vector3 = c + t * x + Vector3.UP * y + o * 0.135

			_box(
				parent, "Recess", p,
				Vector3(pw, ph, 0.08),
				b,
				_mat(Color(0.03, 0.033, 0.033), 0.72)
			)

			var trim: StandardMaterial3D = _mat(Color(0.19, 0.175, 0.15))
			_box(
				parent, "Lintel",
				p + Vector3.UP * (ph * 0.5 + 0.07),
				Vector3(pw + 0.24, 0.14, 0.19),
				b, trim
			)
			_box(
				parent, "Sill",
				p - Vector3.UP * (ph * 0.5 + 0.05),
				Vector3(pw + 0.20, 0.12, 0.22),
				b, trim
			)
			_box(
				parent, "FrameL",
				p - t * (pw * 0.5 + 0.055),
				Vector3(0.11, ph, 0.18),
				b, trim
			)
			_box(
				parent, "FrameR",
				p + t * (pw * 0.5 + 0.055),
				Vector3(0.11, ph, 0.18),
				b, trim
			)

	if "brick" in key or "house" in key or "building" in key:
		_add_brick_damage(parent, c, t, o, b, w, size.y)

	if "bunker" in key or "fort" in key or "concrete" in key:
		_add_concrete_detail(parent, c, t, o, b, w, size.y)


static func _add_brick_damage(
	parent: Node3D,
	c: Vector3,
	t: Vector3,
	o: Vector3,
	b: Basis,
	w: float,
	h: float
) -> void:
	var brick: StandardMaterial3D = _mat(Color(0.25, 0.10, 0.06), 0.97)
	var patches: int = clampi(int(w / 4.0), 1, 4)

	for pidx: int in range(patches):
		var patch_step: float = minf(3.1, w * 0.28)
		var bx: float = -w * 0.34 + float(pidx) * patch_step
		var by: float = -h * 0.20 + float(pidx % 2) * 0.55

		for row: int in range(4):
			for col: int in range(5):
				if (row + col + pidx) % 4 == 0:
					continue

				var stagger: float = 0.12 if row % 2 != 0 else 0.0
				var x: float = bx + (float(col) - 2.0) * 0.24 + stagger
				var y: float = by + (float(row) - 1.5) * 0.13

				_box(
					parent,
					"ExposedBrick",
					c + t * x + Vector3.UP * y + o * 0.19,
					Vector3(0.42, 0.105, 0.16),
					b,
					brick
				)


static func _add_concrete_detail(
	parent: Node3D,
	c: Vector3,
	t: Vector3,
	o: Vector3,
	b: Basis,
	w: float,
	h: float
) -> void:
	var dark: StandardMaterial3D = _mat(Color(0.09, 0.095, 0.09), 0.98)
	var count: int = clampi(int(w / 2.4), 1, 7)

	for i: int in range(1, count):
		var x: float = -w * 0.5 + float(i) * w / float(count)
		_box(
			parent,
			"PourJoint",
			c + t * x + o * 0.145,
			Vector3(0.035, h * 0.84, 0.045),
			b,
			dark
		)

	var tie_denominator: float = float(maxi(count - 1, 1))
	for row: int in range(2):
		for col: int in range(count):
			var x: float = (
				-w * 0.44
				+ float(col) * (w * 0.88 / tie_denominator)
			)
			var y: float = -h * 0.20 + float(row) * h * 0.34
			_box(
				parent,
				"FormTie",
				c + t * x + Vector3.UP * y + o * 0.155,
				Vector3(0.07, 0.07, 0.055),
				b,
				dark
			)


static func _add_depth_debris(parent: Node3D) -> void:
	var rubble: StandardMaterial3D = _mat(Color(0.18, 0.17, 0.15), 0.98)
	var wood: StandardMaterial3D = _mat(Color(0.18, 0.105, 0.05), 0.94)
	var spots: Array[Vector3] = [
		Vector3(-11.0, 0.1, -5.0),
		Vector3(-6.0, 0.1, 8.0),
		Vector3(7.0, 0.1, -8.0),
		Vector3(13.0, 0.1, 5.0),
		Vector3(2.0, 0.1, 13.0),
		Vector3(-15.0, 0.1, 11.0)
	]

	for cluster: int in range(spots.size()):
		var base: Vector3 = spots[cluster]

		for i: int in range(7):
			var ang: float = float(i * 71 + cluster * 23) * 0.0174533
			var r: float = 0.35 + float(i % 3) * 0.28
			_box(
				parent,
				"Rubble",
				base + Vector3(cos(ang) * r, 0.08, sin(ang) * r),
				Vector3(
					0.20 + 0.06 * float(i % 3),
					0.12 + 0.04 * float(i % 2),
					0.26 + 0.05 * float((i + 1) % 3)
				),
				Basis(Vector3.UP, ang),
				rubble
			)

		for i: int in range(2):
			_box(
				parent,
				"BrokenTimber",
				base + Vector3(
					-0.7 + float(i) * 0.65,
					0.10,
					0.45 - float(i) * 0.25
				),
				Vector3(1.35, 0.10, 0.12),
				Basis(Vector3.UP, 0.35 + float(i) * 0.7),
				wood
			)


static func _face_basis(t: Vector3, o: Vector3) -> Basis:
	var x: Vector3 = t.normalized()
	var z: Vector3 = o.normalized()
	var y: Vector3 = z.cross(x).normalized()

	if y.dot(Vector3.UP) < 0.0:
		y = -y

	return Basis(x, y, z)


static func _mat(
	color: Color,
	rough: float = 0.90
) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m


static func _box(
	parent: Node3D,
	name: String,
	pos: Vector3,
	size: Vector3,
	basis: Basis,
	mat: Material
) -> void:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	parent.add_child(mi)
	mi.global_transform = Transform3D(basis.orthonormalized(), pos)
