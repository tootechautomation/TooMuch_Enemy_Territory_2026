extends RefCounted
class_name CoverMicrodetailPass

# v8.74 — visual-only combat-cover microdetail.
# Adds believable construction/detail to sandbags, crates, barricades,
# checkpoints and fighting positions without changing collision/gameplay.

static func apply(root: Node) -> void:
	if root == null or root.has_node("CoverMicrodetailPass_v874"):
		return

	var holder := Node3D.new()
	holder.name = "CoverMicrodetailPass_v874"
	root.add_child(holder)

	var wood := _mat(Color(0.17,0.09,0.04),0.94)
	var wood_dark := _mat(Color(0.105,0.055,0.025),0.96)
	var metal := _mat(Color(0.075,0.080,0.078),0.46,0.70)
	var rust := _mat(Color(0.19,0.070,0.026),0.80,0.20)
	var sand := _mat(Color(0.31,0.27,0.18),0.99)
	var canvas := _mat(Color(0.16,0.17,0.105),0.99)
	var dark := _mat(Color(0.028,0.027,0.024),0.95)

	_build_checkpoint_cover(holder, wood, wood_dark, metal, rust, sand)
	_build_crate_detail(holder, wood, wood_dark, metal)
	_build_sandbag_detail(holder, sand, canvas, dark)
	_build_fighting_positions(holder, wood, metal, sand, canvas)
	_build_wire_obstacles(holder, metal, rust)
	_build_cover_debris(holder, wood, metal)


static func _build_checkpoint_cover(
	parent: Node3D,
	wood: Material,
	wood_dark: Material,
	metal: Material,
	rust: Material,
	sand: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-5.5,0.0,-6.0),
		Vector3(6.0,0.0,6.5),
		Vector3(11.5,0.0,-10.0)
	]
	for c: int in range(centers.size()):
		var base := centers[c]

		# Heavy timber road barricade.
		for x: float in [-1.2,1.2]:
			_box(parent,"BarricadeLeg",base+Vector3(x,0.55,0),
				Vector3(0.16,1.1,0.16),wood)
			var foot := _box(parent,"BarricadeFoot",base+Vector3(x,0.12,0),
				Vector3(0.95,0.13,0.16),wood_dark,90.0)
			foot.rotation.z = deg_to_rad(2.0)

		for y: float in [0.45,0.90]:
			_box(parent,"BarricadePlank",base+Vector3(0,y,0),
				Vector3(3.0,0.22,0.16),wood)

		# Metal fasteners.
		for x: float in [-1.15,1.15]:
			for y: float in [0.45,0.90]:
				_box(parent,"BarricadeBolt",base+Vector3(x,y,-0.10),
					Vector3(0.10,0.10,0.035),metal)

		# Sandbag anchor piles.
		for side: float in [-1.0,1.0]:
			for i: int in range(3):
				_box(parent,"BarricadeBag",
					base+Vector3(side*(1.45+0.22*float(i)),0.16,0.20*float(i%2)),
					Vector3(0.42,0.18,0.30),sand,float(i*8))

		# Bent warning plate / scrap.
		var plate := _box(parent,"BarricadePlate",base+Vector3(0.55,1.18,-0.10),
			Vector3(0.65,0.28,0.045),rust,-6.0)
		plate.rotation.z = deg_to_rad(5.0)


static func _build_crate_detail(
	parent: Node3D,
	wood: Material,
	wood_dark: Material,
	metal: Material
) -> void:
	var clusters: Array[Vector3] = [
		Vector3(-9.0,0.0,5.0),
		Vector3(9.0,0.0,-4.0),
		Vector3(2.0,0.0,11.0)
	]
	for c: int in range(clusters.size()):
		var base := clusters[c]
		for box_i: int in range(3):
			var p := base+Vector3(box_i*0.78,0.38,0.18*float(box_i%2))
			_box(parent,"DetailedCrate",p,Vector3(0.68,0.68,0.68),wood,float(box_i*5))
			# external slats
			for y: float in [-0.24,0.24]:
				_box(parent,"CrateSlat",p+Vector3(0,y,-0.36),
					Vector3(0.72,0.09,0.07),wood_dark,float(box_i*5))
			for x: float in [-0.25,0.25]:
				_box(parent,"CrateBand",p+Vector3(x,0,-0.375),
					Vector3(0.055,0.72,0.035),metal,float(box_i*5))


static func _build_sandbag_detail(
	parent: Node3D,
	sand: Material,
	canvas: Material,
	dark: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-12.5,0.0,-8.0),
		Vector3(12.5,0.0,8.0)
	]
	for c: int in range(centers.size()):
		var base := centers[c]
		for row: int in range(3):
			for i: int in range(7-row):
				var p := base+Vector3(
					-1.35+i*0.46+0.23*float(row%2),
					0.15+row*0.19,
					0
				)
				_box(parent,"LayeredSandbag",p,
					Vector3(0.43,0.18,0.30),sand,float((i+row)*4))
				# seam strip along the bag
				_box(parent,"SandbagSeam",p+Vector3(0,0.01,-0.155),
					Vector3(0.34,0.025,0.018),canvas,float((i+row)*4))

		# dark firing recess behind bags
		_box(parent,"FiringRecess",base+Vector3(0,0.65,0.35),
			Vector3(1.65,0.60,0.08),dark)


static func _build_fighting_positions(
	parent: Node3D,
	wood: Material,
	metal: Material,
	sand: Material,
	canvas: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-16.0,0.0,10.0),
		Vector3(16.0,0.0,-12.0)
	]
	for p_i: int in range(points.size()):
		var base := points[p_i]

		# low firing wall
		for i: int in range(8):
			_box(parent,"PositionBag",
				base+Vector3(-1.6+i*0.46,0.18,0),
				Vector3(0.42,0.18,0.30),sand,float(i*3))

		# timber side braces
		for side: float in [-1.0,1.0]:
			var brace := _box(parent,"PositionBrace",
				base+Vector3(side*1.7,0.65,0.40),
				Vector3(0.13,1.45,0.13),wood)
			brace.rotation.z = deg_to_rad(side*14.0)

		# canvas roof fragment / camouflage strip
		var tarp := _box(parent,"PositionCanvas",
			base+Vector3(0,1.55,0.55),
			Vector3(3.2,0.06,1.35),canvas,float(-4+p_i*8))
		tarp.rotation.z = deg_to_rad(-3.0)

		# simple support bar
		_box(parent,"PositionRoofBar",
			base+Vector3(0,1.45,0.55),
			Vector3(3.3,0.09,0.09),metal)


static func _build_wire_obstacles(
	parent: Node3D,
	metal: Material,
	rust: Material
) -> void:
	var starts: Array[Vector3] = [
		Vector3(-18.0,0.0,0.0),
		Vector3(18.0,0.0,1.0)
	]
	for s: int in range(starts.size()):
		var base := starts[s]
		for i: int in range(6):
			var x := -1.8+i*0.72
			# X-shaped stakes
			var a := _box(parent,"WireStakeA",
				base+Vector3(x,0.48,0),
				Vector3(0.07,1.15,0.07),rust)
			a.rotation.z = deg_to_rad(43.0)
			var b := _box(parent,"WireStakeB",
				base+Vector3(x,0.48,0),
				Vector3(0.07,1.15,0.07),metal)
			b.rotation.z = deg_to_rad(-43.0)

		# horizontal wire approximations
		for y: float in [0.35,0.65]:
			_box(parent,"ObstacleWire",
				base+Vector3(0,y,0),
				Vector3(4.2,0.025,0.025),metal)


static func _build_cover_debris(
	parent: Node3D,
	wood: Material,
	metal: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-5.0,0.06,-6.7),
		Vector3(6.4,0.06,7.1),
		Vector3(11.0,0.06,-10.7)
	]
	for p_i: int in range(points.size()):
		var base := points[p_i]
		for i: int in range(4):
			_box(parent,"CoverWoodScrap",
				base+Vector3(-0.45+i*0.30,0.04,0.10*float(i%2)),
				Vector3(0.55,0.07,0.10),wood,float(-25+i*18))
		var scrap := _box(parent,"CoverMetalScrap",
			base+Vector3(0.5,0.22,0.35),
			Vector3(0.055,0.65,0.07),metal)
		scrap.rotation.z = deg_to_rad(57.0)


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
