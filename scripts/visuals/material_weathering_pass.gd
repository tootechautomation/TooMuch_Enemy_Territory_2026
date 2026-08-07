extends RefCounted
class_name MaterialWeatheringPass

# v8.68 — visual-only material/weathering depth.
# Adds grime, water staining, chipped wall layers, soot and small street detail
# without touching authoritative gameplay collision.

static func apply(root: Node) -> void:
	if root == null or root.has_node("MaterialWeatheringPass_v868"):
		return

	var holder := Node3D.new()
	holder.name = "MaterialWeatheringPass_v868"
	root.add_child(holder)

	var grime := _mat(Color(0.075,0.068,0.055),0.96)
	var damp := _mat(Color(0.055,0.060,0.057),0.34)
	var soot := _mat(Color(0.025,0.024,0.021),0.92)
	var exposed_brick := _mat(Color(0.285,0.105,0.055),0.96)
	var plaster := _mat(Color(0.43,0.40,0.35),0.98)
	var rust := _mat(Color(0.20,0.070,0.025),0.79,0.18)
	var glass := _glass()
	var paper := _mat(Color(0.48,0.43,0.32),0.99)

	_add_wall_weathering(root, holder, grime, damp, soot, exposed_brick, plaster)
	_add_window_damage(root, holder, glass, soot)
	_add_metal_weathering(root, holder, rust)
	_add_street_microdetail(holder, paper, grime)
	_add_wet_edge_breakup(holder, damp)


static func _add_wall_weathering(
	root: Node,
	parent: Node3D,
	grime: Material,
	damp: Material,
	soot: Material,
	exposed_brick: Material,
	plaster: Material
) -> void:
	var count := 0
	for value: Node in root.find_children("*", "MeshInstance3D", true):
		if count >= 42:
			break
		var source := value as MeshInstance3D
		if source == null or source.mesh == null or not source.visible:
			continue

		var key := (source.name + " " + str(source.get_path())).to_lower()
		if not ("wall" in key or "facade" in key or "building" in key):
			continue

		var aabb := source.get_aabb()
		var scl := source.global_transform.basis.get_scale().abs()
		var size := aabb.size * scl
		if maxf(size.x,size.z) < 2.5 or size.y < 1.8:
			continue

		var center := source.global_transform * (aabb.position+aabb.size*0.5)
		var thin_z := size.z <= size.x
		var tangent := (
			source.global_transform.basis.x.normalized()
			if thin_z else source.global_transform.basis.z.normalized()
		)
		var outward := (
			source.global_transform.basis.z.normalized()
			if thin_z else source.global_transform.basis.x.normalized()
		)
		var width := maxf(size.x,size.z)

		# Dark grime strip at wall base.
		_patch(parent,"BaseGrime",
			center + Vector3.DOWN*(size.y*0.42) + outward*0.22,
			tangent,outward,
			Vector3(minf(width*0.72,3.8),0.30,0.025),grime)

		# Damp vertical streaks.
		for i: int in range(2):
			var offset := -width*0.20 + float(i)*width*0.32
			_patch(parent,"DampStreak",
				center+tangent*offset+Vector3.DOWN*(size.y*0.08)+outward*0.225,
				tangent,outward,
				Vector3(0.18,0.85+0.18*float(i),0.022),damp)

		# Irregular chipped-plaster/exposed-brick islands.
		if count % 2 == 0:
			_patch(parent,"ExposedBrick",
				center+tangent*(width*0.16)+Vector3.UP*(size.y*0.10)+outward*0.23,
				tangent,outward,
				Vector3(0.70,0.46,0.028),exposed_brick)
			_patch(parent,"PlasterEdge",
				center+tangent*(width*0.10)+Vector3.UP*(size.y*0.24)+outward*0.235,
				tangent,outward,
				Vector3(0.95,0.16,0.030),plaster)

		# Soot above some openings/war damage.
		if count % 3 == 0:
			_patch(parent,"SootMark",
				center+tangent*(-width*0.18)+Vector3.UP*(size.y*0.20)+outward*0.24,
				tangent,outward,
				Vector3(0.48,0.72,0.025),soot)

		count += 1


static func _add_window_damage(
	root: Node,
	parent: Node3D,
	glass: Material,
	soot: Material
) -> void:
	var count := 0
	for value: Node in root.find_children("*", "MeshInstance3D", true):
		if count >= 24:
			break
		var source := value as MeshInstance3D
		if source == null:
			continue
		var key := source.name.to_lower()
		if not ("windowglass" in key or "upperwindowglass" in key):
			continue

		var pos := source.global_position
		# A few shards/protruding dark edges break up perfect windows.
		for i: int in range(3):
			var shard := _box(parent,"GlassShard",
				pos+Vector3(-0.22+i*0.20,-0.18+0.14*float(i%2),-0.05),
				Vector3(0.12,0.30,0.018),glass,float(-18+i*17))
			shard.rotation.z = deg_to_rad(float(-14+i*11))
		_box(parent,"WindowSoot",pos+Vector3(0.0,0.62,0.02),
			Vector3(0.56,0.16,0.025),soot)
		count += 1


static func _add_metal_weathering(
	root: Node,
	parent: Node3D,
	rust: Material
) -> void:
	var count := 0
	for value: Node in root.find_children("*", "MeshInstance3D", true):
		if count >= 30:
			break
		var source := value as MeshInstance3D
		if source == null:
			continue
		var key := source.name.to_lower()
		if not (
			"metal" in key or "gutter" in key or "downspout" in key
			or "steel" in key or "pole" in key
		):
			continue
		var pos := source.global_position
		_box(parent,"RustAccent",pos+Vector3(0.025,0.02,0.025),
			Vector3(0.09,0.24,0.035),rust,float(count*13))
		count += 1


static func _add_street_microdetail(
	parent: Node3D,
	paper: Material,
	grime: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-6.0,0.025,1.0),
		Vector3(4.0,0.025,3.0),
		Vector3(10.0,0.025,-3.5),
		Vector3(-11.0,0.025,-5.0)
	]
	for c: int in range(centers.size()):
		for i: int in range(5):
			var p := centers[c]+Vector3(-0.7+i*0.32,0,0.15*float((i+c)%3))
			var scrap := _box(parent,"PaperScrap",p,
				Vector3(0.22+0.04*float(i%2),0.012,0.16),paper,float(i*19+c*7))
			scrap.rotation.x = deg_to_rad(float(-2+i%3))
		_box(parent,"StreetGrime",centers[c]+Vector3(0,-0.006,0),
			Vector3(1.7,0.010,0.75),grime,float(c*11))


static func _add_wet_edge_breakup(parent: Node3D, damp: Material) -> void:
	var points: Array[Vector3] = [
		Vector3(-2.0,0.018,-6.0),
		Vector3(6.0,0.018,8.0),
		Vector3(14.0,0.018,1.0),
		Vector3(-12.0,0.018,10.0)
	]
	for i: int in range(points.size()):
		_box(parent,"WetEdge",points[i],
			Vector3(2.2,0.010,0.38),damp,float(-12+i*17))


static func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


static func _glass() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12,0.16,0.17,0.38)
	mat.roughness = 0.16
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


static func _patch(
	parent: Node3D,
	name: String,
	position: Vector3,
	tangent: Vector3,
	outward: Vector3,
	size: Vector3,
	material: Material
) -> void:
	var x := tangent.normalized()
	var z := outward.normalized()
	var y := z.cross(x).normalized()
	if y.dot(Vector3.UP) < 0.0:
		y = -y
	var mi := _box(parent,name,position,size,material)
	mi.global_transform = Transform3D(Basis(x,y,z).orthonormalized(),position)


static func _box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	yaw: float = 0.0
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = position
	mi.rotation.y = deg_to_rad(yaw)
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
