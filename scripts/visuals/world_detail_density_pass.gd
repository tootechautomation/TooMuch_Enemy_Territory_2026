extends RefCounted
class_name WorldDetailDensityPass

# v8.60 — visual-only world-detail expansion.
# Adds density and scene breakup without changing collision.

static func apply(root: Node) -> void:
	if root == null or root.has_node("WorldDetailDensity_v860"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "WorldDetailDensity_v860"
	root.add_child(holder)

	var rubble: StandardMaterial3D = _mat(Color(0.18,0.17,0.15),0.97)
	var brick: StandardMaterial3D = _mat(Color(0.28,0.12,0.07),0.95)
	var wood: StandardMaterial3D = _mat(Color(0.20,0.12,0.055),0.93)
	var rust: StandardMaterial3D = _mat(Color(0.15,0.13,0.10),0.76,0.25)
	var mud: StandardMaterial3D = _mat(Color(0.10,0.085,0.06),0.82)
	var wet: StandardMaterial3D = _mat(Color(0.075,0.08,0.075),0.30)

	_add_rubble_fields(holder, rubble, brick, wood)
	_add_barricade_dressing(holder, wood, rust)
	_add_wet_ground_breakup(holder, mud, wet)
	_add_wall_damage_chunks(holder, brick, rubble)
	_add_objective_practicals(holder)


static func _add_rubble_fields(
	parent: Node3D,
	rubble: Material,
	brick: Material,
	wood: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-6.0,0.05,-5.0),
		Vector3(4.5,0.05,7.0),
		Vector3(11.0,0.05,-4.0),
		Vector3(-12.0,0.05,10.0),
		Vector3(18.0,0.05,8.0)
	]

	for c: int in range(centers.size()):
		var base: Vector3 = centers[c]
		for i: int in range(12):
			var angle: float = deg_to_rad(float(i * 41 + c * 23))
			var radius: float = 0.30 + 0.11 * float(i % 5)
			var pos: Vector3 = base + Vector3(
				cos(angle) * radius,
				0.04 + 0.02 * float(i % 2),
				sin(angle) * radius
			)
			var mat: Material = brick if i % 3 == 0 else rubble
			_box(
				parent,
				"RubbleChunk",
				pos,
				Vector3(
					0.12 + 0.04 * float(i % 3),
					0.08 + 0.03 * float(i % 2),
					0.15 + 0.05 * float((i+1) % 3)
				),
				mat,
				float(i * 17)
			)

		for i: int in range(3):
			_box(
				parent,
				"BrokenBoard",
				base + Vector3(-0.5 + 0.45 * float(i),0.10,0.4 - 0.18 * float(i)),
				Vector3(1.2,0.08,0.10),
				wood,
				-18.0 + 21.0 * float(i)
			)


static func _add_barricade_dressing(
	parent: Node3D,
	wood: Material,
	rust: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-9.0,0.0,-2.0),
		Vector3(7.0,0.0,5.5),
		Vector3(14.0,0.0,2.0)
	]

	for p: int in range(points.size()):
		var base: Vector3 = points[p]
		for i: int in range(4):
			_box(
				parent,
				"BarricadeCrate",
				base + Vector3(float(i%2)*0.9,0.40 + 0.72*float(i/2),float(i%3)*0.14),
				Vector3(0.78,0.70,0.74),
				wood,
				float((i+p)*7)
			)

		for i: int in range(2):
			var post := _box(
				parent,
				"SteelObstacle",
				base + Vector3(-0.7 + 1.9*float(i),0.65,1.0),
				Vector3(0.12,1.5,0.12),
				rust,
				0.0
			)
			post.rotation.z = deg_to_rad(-48.0 if i == 0 else 48.0)


static func _add_wet_ground_breakup(
	parent: Node3D,
	mud: Material,
	wet: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-3.0,0.018,2.0),
		Vector3(3.0,0.018,-2.0),
		Vector3(8.0,0.018,8.0),
		Vector3(-10.0,0.018,6.0)
	]

	for i: int in range(centers.size()):
		_box(
			parent,
			"MudPatch",
			centers[i],
			Vector3(2.5 + 0.4*float(i%2),0.018,1.2 + 0.2*float(i%3)),
			mud,
			float(i*13)
		)
		_box(
			parent,
			"WetPatch",
			centers[i] + Vector3(0.25,0.006,-0.10),
			Vector3(1.7,0.010,0.75),
			wet,
			float(i*13+4)
		)


static func _add_wall_damage_chunks(
	parent: Node3D,
	brick: Material,
	rubble: Material
) -> void:
	var wall_points: Array[Vector3] = [
		Vector3(-15.0,1.0,-6.0),
		Vector3(15.0,1.0,4.0),
		Vector3(-8.0,1.0,13.0)
	]
	for w: int in range(wall_points.size()):
		var base: Vector3 = wall_points[w]
		for i: int in range(5):
			_box(
				parent,
				"WallBreakChunk",
				base + Vector3(
					0.28*float(i),
					0.18*float(i%3),
					0.10*float((i+1)%2)
				),
				Vector3(0.34,0.20,0.24),
				brick if i%2==0 else rubble,
				float(i*11)
			)


static func _add_objective_practicals(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(13.0,2.15,0.0),
		Vector3(0.0,2.05,9.0),
		Vector3(0.0,2.05,-9.0),
		Vector3(-8.0,2.0,6.0)
	]
	for i: int in range(positions.size()):
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "DetailPractical_%d" % i
		light.position = positions[i]
		light.light_color = Color(1.0,0.62,0.28)
		light.light_energy = 0.34
		light.omni_range = 3.6
		light.shadow_enabled = true
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


static func _box(
	parent: Node3D,
	name: String,
	pos: Vector3,
	size: Vector3,
	mat: Material,
	yaw: float
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
