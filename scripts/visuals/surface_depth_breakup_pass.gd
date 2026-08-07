extends RefCounted
class_name SurfaceDepthBreakupPass

# v8.63 visual-only micro-geometry for remaining broad flat surfaces.
# No collision is added.

static func apply(root: Node) -> void:
	if root == null or root.has_node("SurfaceDepthBreakupPass_v863"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "SurfaceDepthBreakupPass_v863"
	root.add_child(holder)

	var dark: StandardMaterial3D = _mat(Color(0.07, 0.065, 0.055), 0.96)
	var mortar: StandardMaterial3D = _mat(Color(0.24, 0.23, 0.21), 0.98)
	var rust: StandardMaterial3D = _mat(Color(0.20, 0.08, 0.035), 0.78, 0.18)

	_add_wall_breakup(root, holder, dark, mortar, rust)


static func _add_wall_breakup(
	root: Node,
	parent: Node3D,
	dark: Material,
	mortar: Material,
	rust: Material
) -> void:
	for value: Node in root.find_children("*", "MeshInstance3D", true):
		var source: MeshInstance3D = value as MeshInstance3D
		if source == null or source.mesh == null or not source.visible:
			continue

		var key: String = (source.name + " " + str(source.get_path())).to_lower()
		if not (
			"wall" in key
			or "building" in key
			or "bunker" in key
			or "facade" in key
		):
			continue

		var aabb: AABB = source.get_aabb()
		var scale: Vector3 = source.global_transform.basis.get_scale().abs()
		var size: Vector3 = aabb.size * scale
		var width: float = maxf(size.x, size.z)
		if width < 4.0 or size.y < 2.0:
			continue

		var center: Vector3 = source.global_transform * (
			aabb.position + aabb.size * 0.5
		)
		var thin_z: bool = size.z <= size.x
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

		# Thin horizontal weathering ledges and broken repair bands create
		# shadows/parallax on otherwise flat walls.
		var band_count: int = clampi(int(width / 4.5), 1, 4)
		for i: int in range(band_count):
			var x: float = -width * 0.32 + float(i) * minf(3.0, width * 0.26)
			var y: float = -size.y * 0.16 + 0.42 * float(i % 2)
			_box(
				parent,
				"WallRepairBand",
				center + tangent * x + Vector3.UP * y + outward * 0.19,
				Vector3(1.15, 0.16, 0.055),
				basis,
				mortar if i % 2 == 0 else dark
			)

		# Small protruding anchors/metal remnants.
		for i: int in range(clampi(int(width / 3.5), 1, 5)):
			var x: float = -width * 0.38 + float(i) * (width * 0.76 / float(maxi(clampi(int(width / 3.5), 1, 5) - 1, 1)))
			_box(
				parent,
				"WallAnchor",
				center + tangent * x + Vector3.UP * (size.y * 0.10) + outward * 0.21,
				Vector3(0.07, 0.36, 0.07),
				basis,
				rust
			)


static func _mat(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


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


static func _face_basis(tangent: Vector3, outward: Vector3) -> Basis:
	var x_axis: Vector3 = tangent.normalized()
	var z_axis: Vector3 = outward.normalized()
	var y_axis: Vector3 = z_axis.cross(x_axis).normalized()
	if y_axis.dot(Vector3.UP) < 0.0:
		y_axis = -y_axis
	return Basis(x_axis, y_axis, z_axis)
