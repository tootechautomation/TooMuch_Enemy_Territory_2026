extends RefCounted
class_name TerrainVegetationPass

# v8.69 — visual-only terrain silhouette + vegetation breakup.
# Existing collision remains authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("TerrainVegetationPass_v869"):
		return

	var holder := Node3D.new()
	holder.name = "TerrainVegetationPass_v869"
	root.add_child(holder)

	var earth := _mat(Color(0.11,0.085,0.050),0.99)
	var wet_earth := _mat(Color(0.075,0.064,0.045),0.62)
	var grass := _mat(Color(0.105,0.135,0.070),0.99)
	var dead_grass := _mat(Color(0.20,0.17,0.095),0.99)
	var wood := _mat(Color(0.16,0.09,0.04),0.95)
	var rust := _mat(Color(0.17,0.065,0.025),0.82,0.18)
	var stone := _mat(Color(0.18,0.18,0.17),0.98)

	_build_embankments(holder, earth, wet_earth, stone)
	_build_drainage_edges(holder, earth, stone)
	_build_grass_clusters(holder, grass, dead_grass)
	_build_broken_fences(holder, wood, rust)
	_build_foreground_silhouette(holder, wood, grass, stone)
	_build_muddy_ruts(holder, wet_earth)


static func _build_embankments(
	parent: Node3D,
	earth: Material,
	wet_earth: Material,
	stone: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-18.0,0.0,-1.0),
		Vector3(17.0,0.0,2.0),
		Vector3(-4.0,0.0,15.0),
		Vector3(5.0,0.0,-15.0)
	]
	var yaws: Array[float] = [8.0,-6.0,90.0,90.0]

	for c: int in range(centers.size()):
		var berm := Node3D.new()
		berm.name = "RoadsideBerm_%d" % c
		berm.position = centers[c]
		berm.rotation.y = deg_to_rad(yaws[c])
		parent.add_child(berm)

		for i: int in range(6):
			var z := -2.3 + i*0.92
			_box(
				berm,
				"EarthRise",
				Vector3(0.0,0.18+0.05*float(i%3),z),
				Vector3(2.2,0.42,0.90),
				earth,
				float((i%3)-1)*4.0
			)

		# Wet toe at base of slope.
		_box(
			berm,
			"WetToe",
			Vector3(0.15,0.03,0.0),
			Vector3(2.8,0.03,5.2),
			wet_earth
		)

		# Embedded stones.
		for i: int in range(7):
			var x := -0.8 + 0.28*float(i%4)
			var z := -2.0 + 0.66*float(i)
			_box(
				berm,
				"EmbeddedStone",
				Vector3(x,0.32+0.04*float(i%2),z),
				Vector3(0.18,0.14,0.22),
				stone,
				float(i*17)
			)


static func _build_drainage_edges(
	parent: Node3D,
	earth: Material,
	stone: Material
) -> void:
	var channels: Array[Vector3] = [
		Vector3(-7.0,0.0,-3.3),
		Vector3(7.5,0.0,3.3)
	]

	for c: int in range(channels.size()):
		var base := channels[c]
		# Visual-only ditch lips on each side.
		for side: float in [-1.0,1.0]:
			_box(
				parent,
				"DrainLip",
				base + Vector3(side*0.85,0.15,0.0),
				Vector3(0.55,0.30,7.0),
				earth,
				0.0
			)
		for i: int in range(8):
			_box(
				parent,
				"DrainStone",
				base + Vector3(-0.45+0.13*float(i%4),0.08,-3.0+0.85*float(i)),
				Vector3(0.15,0.10,0.18),
				stone,
				float(i*21)
			)


static func _build_grass_clusters(
	parent: Node3D,
	grass: Material,
	dead_grass: Material
) -> void:
	var clusters: Array[Vector3] = [
		Vector3(-16.0,0.0,-10.0),
		Vector3(-12.0,0.0,13.0),
		Vector3(-3.0,0.0,16.0),
		Vector3(8.0,0.0,15.0),
		Vector3(15.0,0.0,-11.0),
		Vector3(19.0,0.0,10.0),
		Vector3(4.0,0.0,-14.0),
		Vector3(-9.0,0.0,-13.0)
	]

	for c: int in range(clusters.size()):
		var base := clusters[c]
		for i: int in range(9):
			var angle := deg_to_rad(float(i*43+c*19))
			var radius := 0.18+0.10*float(i%4)
			var blade := _box(
				parent,
				"GrassBlade",
				base+Vector3(cos(angle)*radius,0.28+0.04*float(i%3),sin(angle)*radius),
				Vector3(0.045,0.55+0.08*float(i%3),0.08),
				grass if i%3 != 0 else dead_grass,
				float(i*23)
			)
			blade.rotation.z = deg_to_rad(-9.0+float(i%4)*6.0)


static func _build_broken_fences(
	parent: Node3D,
	wood: Material,
	rust: Material
) -> void:
	var starts: Array[Vector3] = [
		Vector3(-17.0,0.0,7.5),
		Vector3(7.0,0.0,17.0)
	]
	var yaws: Array[float] = [0.0,90.0]

	for f: int in range(starts.size()):
		var fence := Node3D.new()
		fence.name = "BrokenFence_%d" % f
		fence.position = starts[f]
		fence.rotation.y = deg_to_rad(yaws[f])
		parent.add_child(fence)

		for i: int in range(7):
			var post := _box(
				fence,
				"FencePost",
				Vector3(i*1.25,0.75,0),
				Vector3(0.12,1.5,0.12),
				wood
			)
			if i in [2,5]:
				post.rotation.z = deg_to_rad(17.0 if i==2 else -14.0)

			if i < 6 and i != 2:
				_box(
					fence,
					"FenceRail",
					Vector3(i*1.25+0.62,0.95,0),
					Vector3(1.15,0.07,0.09),
					wood
				)
				_box(
					fence,
					"FenceWire",
					Vector3(i*1.25+0.62,0.45,0),
					Vector3(1.15,0.035,0.04),
					rust
				)


static func _build_foreground_silhouette(
	parent: Node3D,
	wood: Material,
	grass: Material,
	stone: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-19.0,0.0,-4.0),
		Vector3(19.0,0.0,5.0),
		Vector3(-5.0,0.0,18.0)
	]

	for p: int in range(points.size()):
		var base := points[p]

		# Stump / broken timber silhouette.
		var stump := _box(
			parent,
			"BrokenStump",
			base+Vector3(0,0.65,0),
			Vector3(0.32,1.3,0.34),
			wood,
			float(p*19)
		)
		stump.rotation.z = deg_to_rad(-8.0+float(p)*6.0)

		# Low vegetation mass.
		for i: int in range(5):
			_box(
				parent,
				"BrushMass",
				base+Vector3(-0.5+0.25*float(i),0.25,0.18*float(i%2)),
				Vector3(0.42,0.48,0.38),
				grass,
				float(i*29)
			)

		# Stone at base.
		_box(
			parent,
			"ForegroundStone",
			base+Vector3(0.65,0.18,0.25),
			Vector3(0.65,0.34,0.48),
			stone,
			float(-12+p*11)
		)


static func _build_muddy_ruts(
	parent: Node3D,
	wet_earth: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-6.0,0.018,0.0),
		Vector3(5.0,0.018,0.0)
	]
	for c: int in range(centers.size()):
		for lane: float in [-0.48,0.48]:
			_box(
				parent,
				"WheelRut",
				centers[c]+Vector3(0.0,0.0,lane),
				Vector3(7.0,0.012,0.16),
				wet_earth,
				float(c*4)
			)


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
