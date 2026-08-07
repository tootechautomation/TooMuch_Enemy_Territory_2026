extends RefCounted
class_name RooflineVerticalityPass

# v8.72 — visual-only roofline / skyline / verticality pass.
# Adds believable upper-story silhouettes without changing navigation/collision.

static func apply(root: Node) -> void:
	if root == null or root.has_node("RooflineVerticalityPass_v872"):
		return

	var holder := Node3D.new()
	holder.name = "RooflineVerticalityPass_v872"
	root.add_child(holder)

	var brick := _mat(Color(0.245,0.105,0.058),0.96)
	var plaster := _mat(Color(0.36,0.34,0.30),0.98)
	var roof := _mat(Color(0.095,0.085,0.070),0.91)
	var wood := _mat(Color(0.16,0.085,0.035),0.94)
	var metal := _mat(Color(0.08,0.085,0.08),0.50,0.62)
	var soot := _mat(Color(0.025,0.023,0.020),0.94)
	var glass := _glass()

	_build_roofline_clusters(holder, brick, plaster, roof, wood, metal, soot, glass)
	_build_chimneys(holder, brick, soot)
	_build_roof_damage(holder, wood, roof, soot)
	_build_upper_story_lights(holder)


static func _build_roofline_clusters(
	parent: Node3D,
	brick: Material,
	plaster: Material,
	roof: Material,
	wood: Material,
	metal: Material,
	soot: Material,
	glass: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-14.5,5.1,-8.8),
		Vector3(-13.0,5.1,10.0),
		Vector3(10.8,5.1,10.8),
		Vector3(16.0,5.1,-7.0)
	]
	var yaws: Array[float] = [4.0,-6.0,5.0,-4.0]

	for b: int in range(centers.size()):
		var building := Node3D.new()
		building.name = "UpperStory_%d" % b
		building.position = centers[b]
		building.rotation.y = deg_to_rad(yaws[b])
		parent.add_child(building)

		var facade: Material = brick if b % 2 == 0 else plaster

		# Partial upper story keeps silhouettes irregular rather than box towers.
		_box(building,"UpperMass",Vector3(0,0.85,0),
			Vector3(5.2,1.7,3.4),facade)

		# Recessed upper windows.
		for wx: float in [-1.45,0.0,1.45]:
			_box(building,"UpperVoid",Vector3(wx,0.88,-1.73),
				Vector3(0.78,0.92,0.10),soot)
			_box(building,"UpperGlass",Vector3(wx,0.88,-1.80),
				Vector3(0.64,0.76,0.025),glass)
			_box(building,"UpperSill",Vector3(wx,0.36,-1.82),
				Vector3(0.88,0.10,0.24),facade)

		# Pitched roof using two rotated slabs.
		var left := _box(building,"RoofSlopeL",Vector3(-1.30,2.05,0),
			Vector3(3.0,0.18,3.8),roof)
		left.rotation.z = deg_to_rad(23.0)

		var right := _box(building,"RoofSlopeR",Vector3(1.30,2.05,0),
			Vector3(3.0,0.18,3.8),roof)
		right.rotation.z = deg_to_rad(-23.0)

		# Ridge and gutter lines.
		_box(building,"RoofRidge",Vector3(0,2.64,0),
			Vector3(0.16,0.16,3.75),metal)
		for x: float in [-2.62,2.62]:
			_box(building,"RoofGutter",Vector3(x,1.48,0),
				Vector3(0.09,0.09,3.75),metal)

		# Exposed attic timber on one building in two.
		if b % 2 == 0:
			_box(building,"AtticBeam",Vector3(0,1.62,-1.90),
				Vector3(4.8,0.13,0.13),wood)
			for x: float in [-1.7,0.0,1.7]:
				_box(building,"AtticStud",Vector3(x,2.0,-1.90),
					Vector3(0.12,0.95,0.12),wood)


static func _build_chimneys(
	parent: Node3D,
	brick: Material,
	soot: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-15.8,7.4,-8.2),
		Vector3(-11.9,7.4,10.6),
		Vector3(11.9,7.4,10.4),
		Vector3(15.0,7.4,-6.5)
	]

	for i: int in range(points.size()):
		_box(parent,"Chimney",points[i],
			Vector3(0.55,1.8,0.55),brick,float(i*7))
		_box(parent,"ChimneyCap",points[i]+Vector3(0,0.95,0),
			Vector3(0.72,0.14,0.72),soot,float(i*7))


static func _build_roof_damage(
	parent: Node3D,
	wood: Material,
	roof: Material,
	soot: Material
) -> void:
	var sites: Array[Vector3] = [
		Vector3(-14.0,7.1,-9.0),
		Vector3(11.0,7.1,10.7),
		Vector3(16.2,7.1,-7.2)
	]

	for s: int in range(sites.size()):
		var base := sites[s]

		# Broken rafters crossing the roof opening.
		for i: int in range(4):
			var rafter := _box(parent,"BrokenRafter",
				base+Vector3(-0.8+i*0.52,0.12,0),
				Vector3(0.10,0.10,2.1),wood,float(-18+i*12))
			rafter.rotation.x = deg_to_rad(float(-8+i*4))

		# Dark hole underneath.
		_box(parent,"RoofHole",base+Vector3(0,-0.08,0),
			Vector3(1.8,0.04,1.6),soot,float(s*9))

		# Loose roof fragments.
		for i: int in range(5):
			var frag := _box(parent,"RoofFragment",
				base+Vector3(-0.7+i*0.34,0.22,0.65-0.15*float(i%3)),
				Vector3(0.30,0.07,0.46),roof,float(i*19))
			frag.rotation.z = deg_to_rad(float(-10+i*5))


static func _build_upper_story_lights(parent: Node3D) -> void:
	var points: Array[Vector3] = [
		Vector3(-14.5,6.0,-10.3),
		Vector3(-13.0,6.0,8.4),
		Vector3(10.8,6.0,9.2),
		Vector3(16.0,6.0,-8.5)
	]

	for i: int in range(points.size()):
		var light := OmniLight3D.new()
		light.name = "UpperStoryGlow_%d" % i
		light.position = points[i]
		light.light_color = Color(1.0,0.55,0.22)
		light.light_energy = 0.16 if i % 2 == 0 else 0.10
		light.omni_range = 3.4
		light.shadow_enabled = false
		parent.add_child(light)


static func _mat(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


static func _glass() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10,0.13,0.14,0.34)
	mat.roughness = 0.18
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


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
