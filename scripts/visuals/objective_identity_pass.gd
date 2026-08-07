extends RefCounted
class_name ObjectiveIdentityPass

# v8.70 — visual-only objective identity / landmark pass.
# Makes bunker, depot and command-post areas visually distinct at a glance.

static func apply(root: Node) -> void:
	if root == null or root.has_node("ObjectiveIdentityPass_v870"):
		return

	var holder := Node3D.new()
	holder.name = "ObjectiveIdentityPass_v870"
	root.add_child(holder)

	var concrete := _mat(Color(0.26,0.26,0.24),0.98)
	var wood := _mat(Color(0.17,0.09,0.04),0.94)
	var metal := _mat(Color(0.085,0.09,0.085),0.48,0.68)
	var rust := _mat(Color(0.18,0.065,0.025),0.80,0.20)
	var canvas := _mat(Color(0.18,0.19,0.12),0.99)
	var dark := _mat(Color(0.018,0.019,0.018),0.90)
	var sand := _mat(Color(0.32,0.28,0.19),0.99)

	_build_bunker_landmark(holder, concrete, metal, rust, sand)
	_build_depot_landmark(holder, wood, metal, canvas, dark)
	_build_command_landmark(holder, wood, metal, canvas)
	_build_route_markers(holder, wood, metal)
	_build_objective_light_hierarchy(holder)


static func _build_bunker_landmark(
	parent: Node3D,
	concrete: Material,
	metal: Material,
	rust: Material,
	sand: Material
) -> void:
	var base := Vector3(13.0,0.0,0.0)

	# Reinforced entrance frame.
	_box(parent,"BunkerHeader",base+Vector3(0,2.45,-2.55),
		Vector3(3.5,0.32,0.42),concrete)
	for x: float in [-1.55,1.55]:
		_box(parent,"BunkerEntrancePier",base+Vector3(x,1.25,-2.55),
			Vector3(0.38,2.5,0.45),concrete)

	# Bent external pipe / vent stack.
	_box(parent,"BunkerVent",base+Vector3(1.35,3.0,1.2),
		Vector3(0.20,2.0,0.20),rust)
	_box(parent,"BunkerVentCap",base+Vector3(1.05,3.95,1.2),
		Vector3(0.70,0.16,0.24),metal)

	# Sandbag apron.
	for row: int in range(2):
		for i: int in range(7):
			_box(parent,"BunkerApronBag",
				base+Vector3(-1.4+i*0.46+(0.23 if row==1 else 0.0),
				0.16+row*0.18,-3.05),
				Vector3(0.42,0.17,0.28),sand,float(i*3))

	# Recognition light.
	_add_light(parent,"BunkerIdentityLight",
		base+Vector3(0,2.15,-2.8),Color(1.0,0.48,0.16),0.62,5.2)


static func _build_depot_landmark(
	parent: Node3D,
	wood: Material,
	metal: Material,
	canvas: Material,
	dark: Material
) -> void:
	var base := Vector3(0.0,0.0,9.0)

	# Loading gantry silhouette.
	for x: float in [-2.5,2.5]:
		_box(parent,"DepotGantryPost",base+Vector3(x,2.0,-2.4),
			Vector3(0.16,4.0,0.16),metal)
	_box(parent,"DepotGantryBeam",base+Vector3(0,3.9,-2.4),
		Vector3(5.2,0.18,0.18),metal)

	# Hanging hook/cable.
	_box(parent,"DepotHoistCable",base+Vector3(0.7,3.1,-2.4),
		Vector3(0.035,1.45,0.035),dark)
	_box(parent,"DepotHoistHook",base+Vector3(0.7,2.38,-2.4),
		Vector3(0.16,0.20,0.08),metal)

	# Canvas loading canopy.
	_box(parent,"DepotCanopy",base+Vector3(-0.5,3.15,-1.7),
		Vector3(4.2,0.10,1.3),canvas,-3.0)

	# Shipping pallets.
	for p: int in range(3):
		var pbase := base+Vector3(-2.0+p*1.55,0.0,-1.2)
		for slat: int in range(4):
			_box(parent,"PalletSlat",
				pbase+Vector3(-0.45+slat*0.30,0.09,0),
				Vector3(0.24,0.08,0.90),wood)

	_add_light(parent,"DepotIdentityLight",
		base+Vector3(0,3.45,-2.2),Color(1.0,0.68,0.28),0.56,5.5)


static func _build_command_landmark(
	parent: Node3D,
	wood: Material,
	metal: Material,
	canvas: Material
) -> void:
	var base := Vector3(0.0,0.0,-9.0)

	# Tall radio mast gives the command post a unique skyline.
	_box(parent,"CPRadioMast",base+Vector3(2.1,3.5,0.8),
		Vector3(0.10,7.0,0.10),metal)
	for h: float in [2.4,4.2,5.8]:
		_box(parent,"CPMastCrossarm",base+Vector3(2.1,h,0.8),
			Vector3(1.15,0.08,0.08),metal)

	# Guy-line approximations.
	for side: float in [-1.0,1.0]:
		var line := _box(parent,"CPGuyLine",
			base+Vector3(2.1+side*1.1,2.2,0.8),
			Vector3(0.035,4.7,0.035),metal)
		line.rotation.z = deg_to_rad(side*25.0)

	# Canvas awning / briefing area.
	_box(parent,"CPAwning",base+Vector3(-0.8,2.75,0.2),
		Vector3(3.4,0.10,2.3),canvas,2.0)
	for x: float in [-2.3,0.7]:
		_box(parent,"CPAwningPole",base+Vector3(x,1.4,-0.8),
			Vector3(0.09,2.8,0.09),wood)

	_add_light(parent,"CPIdentityLight",
		base+Vector3(-0.8,2.55,-0.7),Color(0.92,0.72,0.38),0.52,5.0)


static func _build_route_markers(
	parent: Node3D,
	wood: Material,
	metal: Material
) -> void:
	var positions: Array[Vector3] = [
		Vector3(-4.5,0.0,-2.0),
		Vector3(4.5,0.0,2.0),
		Vector3(-8.0,0.0,4.0)
	]
	var yaws: Array[float] = [18.0,-20.0,35.0]

	for i: int in range(positions.size()):
		var base := positions[i]
		_box(parent,"RoutePost",base+Vector3(0,0.85,0),
			Vector3(0.10,1.7,0.10),wood,yaws[i])
		_box(parent,"RouteBoard",base+Vector3(0.35,1.45,0),
			Vector3(0.85,0.30,0.10),wood,yaws[i])
		_box(parent,"RouteBracket",base+Vector3(0.0,1.42,0),
			Vector3(0.45,0.06,0.08),metal,yaws[i])


static func _build_objective_light_hierarchy(parent: Node3D) -> void:
	# Low-energy secondary lights pull the eye toward objective approaches.
	var points: Array[Vector3] = [
		Vector3(9.0,1.7,0.0),
		Vector3(0.0,1.7,5.8),
		Vector3(0.0,1.7,-5.8)
	]
	for i: int in range(points.size()):
		_add_light(parent,"ObjectiveApproach_%d" % i,points[i],
			Color(1.0,0.58,0.25),0.22,3.6)


static func _add_light(
	parent: Node3D,
	name: String,
	position: Vector3,
	color: Color,
	energy: float,
	range_value: float
) -> void:
	var light := OmniLight3D.new()
	light.name = name
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
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
