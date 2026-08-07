extends RefCounted
class_name RoadStreetDetailPass

# v8.73 — visual-only street/road realism pass.
# Adds curbs, sidewalks, drainage, shell damage, road repairs, utility access
# covers and roadside debris while preserving authoritative collision.

static func apply(root: Node) -> void:
	if root == null or root.has_node("RoadStreetDetailPass_v873"):
		return

	var holder := Node3D.new()
	holder.name = "RoadStreetDetailPass_v873"
	root.add_child(holder)

	var road := _mat(Color(0.105,0.105,0.098),0.92)
	var repair := _mat(Color(0.075,0.075,0.070),0.84)
	var concrete := _mat(Color(0.31,0.30,0.27),0.97)
	var dark := _mat(Color(0.035,0.034,0.031),0.95)
	var metal := _mat(Color(0.075,0.080,0.078),0.47,0.72)
	var mud := _mat(Color(0.085,0.064,0.038),0.72)
	var rubble := _mat(Color(0.17,0.16,0.145),0.98)

	_build_sidewalk_edges(holder, concrete)
	_build_road_repairs(holder, repair, road)
	_build_shell_damage(holder, dark, rubble, mud)
	_build_drainage(holder, concrete, metal, dark)
	_build_access_covers(holder, metal)
	_build_roadside_debris(holder, rubble, metal)
	_build_crossing_breakup(holder, concrete, road)


static func _build_sidewalk_edges(parent: Node3D, concrete: Material) -> void:
	var strips: Array[Dictionary] = [
		{"p":Vector3(-11.5,0.09,-2.8),"s":Vector3(10.0,0.18,1.05),"r":2.0},
		{"p":Vector3(11.5,0.09,2.8),"s":Vector3(10.0,0.18,1.05),"r":-2.0},
		{"p":Vector3(-2.8,0.09,10.8),"s":Vector3(1.05,0.18,8.5),"r":0.0},
		{"p":Vector3(2.8,0.09,-10.8),"s":Vector3(1.05,0.18,8.5),"r":0.0}
	]
	for i: int in range(strips.size()):
		var d: Dictionary = strips[i]
		_box(parent,"Sidewalk_%d" % i,d["p"],d["s"],concrete,float(d["r"]))

		# segmented curb face gives stronger street depth
		var p: Vector3 = d["p"]
		if float(d["s"].x) > float(d["s"].z):
			for n: int in range(8):
				_box(parent,"CurbSegment",p+Vector3(-4.2+n*1.2,0.16,0.57),
					Vector3(1.05,0.30,0.18),concrete,float(d["r"]))
		else:
			for n: int in range(7):
				_box(parent,"CurbSegment",p+Vector3(0.57,0.16,-3.6+n*1.2),
					Vector3(0.18,0.30,1.05),concrete,float(d["r"]))


static func _build_road_repairs(
	parent: Node3D,
	repair: Material,
	road: Material
) -> void:
	var patches: Array[Vector3] = [
		Vector3(-6.0,0.024,-0.4),
		Vector3(2.0,0.024,0.7),
		Vector3(8.5,0.024,-0.5),
		Vector3(0.4,0.024,6.5),
		Vector3(-0.6,0.024,-7.5)
	]
	for i: int in range(patches.size()):
		_box(parent,"RoadPatch",patches[i],
			Vector3(2.1+0.25*float(i%2),0.018,1.05+0.18*float(i%3)),
			repair,float(-8+i*9))
		# smaller inner tone prevents perfectly rectangular patch reading
		_box(parent,"RoadPatchInner",patches[i]+Vector3(0,0.011,0),
			Vector3(1.35,0.010,0.62),road,float(7-i*4))


static func _build_shell_damage(
	parent: Node3D,
	dark: Material,
	rubble: Material,
	mud: Material
) -> void:
	var sites: Array[Vector3] = [
		Vector3(-3.8,0.02,2.0),
		Vector3(6.8,0.02,-1.8),
		Vector3(1.5,0.02,-5.5)
	]
	for s: int in range(sites.size()):
		var base := sites[s]
		# dark impact center
		_box(parent,"ShellImpact",base,
			Vector3(1.0,0.016,0.82),dark,float(s*17))
		_box(parent,"ImpactMud",base+Vector3(0.08,0.012,-0.03),
			Vector3(0.62,0.012,0.50),mud,float(-12+s*13))

		# radial loose fragments
		for i: int in range(10):
			var a := deg_to_rad(float(i*36+s*11))
			var r := 0.65+0.11*float(i%4)
			_box(parent,"ImpactDebris",
				base+Vector3(cos(a)*r,0.07,sin(a)*r),
				Vector3(0.12+0.025*float(i%3),0.09,0.16),
				rubble,float(i*21))


static func _build_drainage(
	parent: Node3D,
	concrete: Material,
	metal: Material,
	dark: Material
) -> void:
	var drains: Array[Vector3] = [
		Vector3(-8.0,0.11,-2.15),
		Vector3(7.5,0.11,2.15),
		Vector3(-2.15,0.11,7.0),
		Vector3(2.15,0.11,-7.0)
	]
	for i: int in range(drains.size()):
		var p := drains[i]
		_box(parent,"DrainRecess",p,Vector3(0.80,0.08,0.48),dark,float(i*90))
		for bar: int in range(5):
			_box(parent,"DrainBar",
				p+Vector3(-0.30+bar*0.15,0.055,0),
				Vector3(0.045,0.055,0.44),metal,float(i*90))
		_box(parent,"DrainLip",p+Vector3(0,-0.02,0.34),
			Vector3(0.92,0.18,0.15),concrete,float(i*90))


static func _build_access_covers(parent: Node3D, metal: Material) -> void:
	var points: Array[Vector3] = [
		Vector3(-1.5,0.04,1.0),
		Vector3(4.2,0.04,-0.7),
		Vector3(-0.8,0.04,-4.0)
	]
	for i: int in range(points.size()):
		_cyl(parent,"AccessCover",points[i],0.46,0.035,metal)
		for n: int in range(4):
			var a := deg_to_rad(float(n*90))
			_box(parent,"CoverNotch",
				points[i]+Vector3(cos(a)*0.25,0.025,sin(a)*0.25),
				Vector3(0.10,0.025,0.045),metal,float(n*90))


static func _build_roadside_debris(
	parent: Node3D,
	rubble: Material,
	metal: Material
) -> void:
	var edges: Array[Vector3] = [
		Vector3(-9.5,0.05,-2.2),
		Vector3(10.5,0.05,2.2),
		Vector3(-2.2,0.05,10.0),
		Vector3(2.2,0.05,-10.0)
	]
	for e: int in range(edges.size()):
		var base := edges[e]
		for i: int in range(8):
			_box(parent,"RoadEdgeDebris",
				base+Vector3(-0.55+0.17*float(i),0.03*float(i%2),
					0.10*float((i+e)%3)),
				Vector3(0.12,0.09,0.15),rubble,float(i*23))
		if e % 2 == 0:
			var scrap := _box(parent,"RoadEdgeMetal",
				base+Vector3(0.45,0.18,0.25),
				Vector3(0.07,0.65,0.08),metal)
			scrap.rotation.z = deg_to_rad(52.0)


static func _build_crossing_breakup(
	parent: Node3D,
	concrete: Material,
	road: Material
) -> void:
	# Broken paving bands near central combat intersection.
	for i: int in range(6):
		_box(parent,"BrokenPaver",
			Vector3(-2.1+i*0.82,0.035,3.35),
			Vector3(0.68,0.05,0.55),
			concrete if i%2==0 else road,float(-3+i*2))
	for i: int in range(5):
		_box(parent,"BrokenPaver",
			Vector3(3.35,0.035,-1.7+i*0.82),
			Vector3(0.55,0.05,0.68),
			concrete if i%2==1 else road,float(2-i))


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


static func _cyl(
	parent: Node3D,
	name: String,
	position: Vector3,
	radius: float,
	height: float,
	material: Material
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mi.mesh = mesh
	mi.position = position
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
