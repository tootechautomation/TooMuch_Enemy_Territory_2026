extends RefCounted
class_name InteriorStorytellingPass

# v8.75 — visual-only interior storytelling / room-density pass.
# Adds believable WWII field-space dressing without touching weapons,
# objectives, collision or networking.

static func apply(root: Node) -> void:
	if root == null or root.has_node("InteriorStorytellingPass_v875"):
		return

	var holder := Node3D.new()
	holder.name = "InteriorStorytellingPass_v875"
	root.add_child(holder)

	var wood := _mat(Color(0.16,0.085,0.035),0.95)
	var dark_wood := _mat(Color(0.095,0.050,0.025),0.97)
	var metal := _mat(Color(0.075,0.080,0.078),0.48,0.68)
	var paper := _mat(Color(0.52,0.47,0.34),0.99)
	var canvas := _mat(Color(0.17,0.18,0.11),0.99)
	var dark := _mat(Color(0.022,0.022,0.020),0.94)
	var glass := _glass()

	_build_command_room(holder, wood, dark_wood, metal, paper, canvas)
	_build_depot_room(holder, wood, dark_wood, metal, canvas)
	_build_bunker_room(holder, wood, metal, paper, dark)
	_build_field_lamps(holder, metal, glass)
	_build_floor_clutter(holder, paper, wood, metal)


static func _build_command_room(
	parent: Node3D,
	wood: Material,
	dark_wood: Material,
	metal: Material,
	paper: Material,
	canvas: Material
) -> void:
	var base := Vector3(0.0,0.0,-9.0)

	# Map/briefing table with raised edge and papers.
	_box(parent,"CPTableTop",base+Vector3(-0.7,0.88,0.15),
		Vector3(2.6,0.14,1.35),wood)
	for x: float in [-1.75,0.35]:
		for z: float in [-0.35,0.65]:
			_box(parent,"CPTableLeg",base+Vector3(x,0.43,z),
				Vector3(0.13,0.86,0.13),dark_wood)

	for i: int in range(5):
		_box(parent,"MapPaper",
			base+Vector3(-1.45+i*0.38,0.965,0.05+0.08*float(i%2)),
			Vector3(0.46,0.015,0.34),paper,float(-12+i*8))

	# Radio stack.
	for i: int in range(2):
		var p := base+Vector3(1.05,0.55+i*0.48,0.3)
		_box(parent,"FieldRadio",p,Vector3(0.75,0.42,0.52),metal)
		_box(parent,"RadioFace",p+Vector3(0,0,-0.27),
			Vector3(0.58,0.25,0.035),dark_wood)
		for knob: int in range(3):
			_cyl(parent,"RadioKnob",
				p+Vector3(-0.20+knob*0.20,-0.02,-0.30),
				0.035,0.05,metal,90.0)

	# Canvas notice board.
	_box(parent,"CPNoticeBoard",base+Vector3(-2.15,1.65,1.05),
		Vector3(1.25,1.05,0.08),canvas)
	for i: int in range(4):
		_box(parent,"PinnedPaper",
			base+Vector3(-2.45+0.22*float(i),1.55+0.13*float(i%2),0.995),
			Vector3(0.25,0.30,0.012),paper,float(-5+i*4))


static func _build_depot_room(
	parent: Node3D,
	wood: Material,
	dark_wood: Material,
	metal: Material,
	canvas: Material
) -> void:
	var base := Vector3(0.0,0.0,9.0)

	# Dense shelving.
	for side: float in [-1.0,1.0]:
		var x := side*2.2
		for y: float in [0.45,1.15,1.85]:
			_box(parent,"DepotShelf",
				base+Vector3(x,y,0.8),
				Vector3(0.65,0.09,3.0),wood)
		for z: float in [-0.55,1.95]:
			_box(parent,"DepotShelfPost",
				base+Vector3(x,1.1,z),
				Vector3(0.11,2.2,0.11),dark_wood)

	# Small supply boxes on shelves.
	for i: int in range(8):
		var side := -1.0 if i%2==0 else 1.0
		var y := 0.62 + 0.70*float((i/2)%3)
		var z := -0.20 + 0.55*float(i%4)
		_box(parent,"DepotSupplyBox",
			base+Vector3(side*2.2,y,z),
			Vector3(0.48,0.32,0.42),wood,float(i*7))

	# Hanging canvas divider.
	_box(parent,"DepotCanvasDivider",
		base+Vector3(0.0,1.45,2.15),
		Vector3(3.4,2.65,0.055),canvas)

	# Tool / pipe rack silhouette.
	_box(parent,"DepotToolRail",
		base+Vector3(1.2,1.45,-1.15),
		Vector3(2.0,0.10,0.10),metal)
	for i: int in range(5):
		var tool := _box(parent,"DepotTool",
			base+Vector3(0.45+i*0.35,0.95,-1.18),
			Vector3(0.055,0.95,0.055),metal)
		tool.rotation.z = deg_to_rad(float(-8+i*4))


static func _build_bunker_room(
	parent: Node3D,
	wood: Material,
	metal: Material,
	paper: Material,
	dark: Material
) -> void:
	var base := Vector3(13.0,0.0,0.0)

	# Narrow work bench.
	_box(parent,"BunkerBenchTop",base+Vector3(0.0,0.82,1.3),
		Vector3(3.0,0.13,0.72),wood)
	for x: float in [-1.25,1.25]:
		_box(parent,"BunkerBenchLeg",base+Vector3(x,0.40,1.3),
			Vector3(0.12,0.80,0.12),metal)

	# Ammo/tool boxes.
	for i: int in range(4):
		var p := base+Vector3(-1.0+i*0.68,1.02,1.3)
		_box(parent,"BunkerAmmoBox",p,
			Vector3(0.52,0.28,0.38),metal,float(i*5))
		_box(parent,"AmmoLatch",p+Vector3(0,-0.02,-0.205),
			Vector3(0.12,0.11,0.025),dark)

	# Wall papers / tactical notes.
	for i: int in range(5):
		_box(parent,"BunkerNote",
			base+Vector3(-1.0+i*0.48,1.65,1.68),
			Vector3(0.34,0.42,0.014),paper,float(-4+i*3))

	# Overhead conduit.
	_box(parent,"BunkerConduit",
		base+Vector3(0.0,2.35,1.68),
		Vector3(3.6,0.06,0.06),metal)
	for x: float in [-1.4,0.0,1.4]:
		_box(parent,"ConduitDrop",
			base+Vector3(x,1.95,1.68),
			Vector3(0.055,0.80,0.055),metal)


static func _build_field_lamps(
	parent: Node3D,
	metal: Material,
	glass: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-0.7,1.55,-8.9),
		Vector3(0.0,2.25,9.0),
		Vector3(13.0,2.15,1.25)
	]
	for i: int in range(points.size()):
		var p := points[i]
		_cyl(parent,"LampBody",p,0.12,0.24,metal)
		_cyl(parent,"LampGlass",p+Vector3(0,-0.18,0),
			0.095,0.18,glass)

		var light := OmniLight3D.new()
		light.name = "InteriorPracticalLamp_%d" % i
		light.position = p+Vector3(0,-0.20,0)
		light.light_color = Color(1.0,0.60,0.27)
		light.light_energy = 0.38
		light.omni_range = 3.2
		light.shadow_enabled = true
		parent.add_child(light)


static func _build_floor_clutter(
	parent: Node3D,
	paper: Material,
	wood: Material,
	metal: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(0.0,0.03,-9.0),
		Vector3(0.0,0.03,9.0),
		Vector3(13.0,0.03,0.5)
	]
	for c: int in range(centers.size()):
		var base := centers[c]
		for i: int in range(5):
			_box(parent,"InteriorPaperScrap",
				base+Vector3(-0.65+i*0.28,0,0.12*float((i+c)%3)),
				Vector3(0.22,0.012,0.16),paper,float(i*17+c*9))

		_box(parent,"InteriorWoodScrap",
			base+Vector3(0.65,0.08,-0.4),
			Vector3(0.85,0.08,0.10),wood,float(-20+c*12))

		var pipe := _box(parent,"InteriorMetalScrap",
			base+Vector3(-0.7,0.12,0.45),
			Vector3(0.055,0.65,0.055),metal)
		pipe.rotation.z = deg_to_rad(62.0)


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
	mat.albedo_color = Color(0.55,0.42,0.20,0.34)
	mat.roughness = 0.20
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


static func _cyl(
	parent: Node3D,
	name: String,
	position: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotate_x: float = 0.0
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mi.mesh = mesh
	mi.position = position
	mi.rotation.x = deg_to_rad(rotate_x)
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
