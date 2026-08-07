extends RefCounted
class_name InteriorBattlefieldPropsPass

# v8.66 — visual-only interior depth and battlefield prop dressing.
# Existing gameplay collision and objective logic remain authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("InteriorBattlefieldPropsPass_v866"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "InteriorBattlefieldPropsPass_v866"
	root.add_child(holder)

	var concrete: StandardMaterial3D = _mat(Color(0.27, 0.27, 0.25), 0.97)
	var brick: StandardMaterial3D = _mat(Color(0.25, 0.11, 0.065), 0.95)
	var wood: StandardMaterial3D = _mat(Color(0.18, 0.10, 0.045), 0.92)
	var metal: StandardMaterial3D = _mat(Color(0.10, 0.105, 0.10), 0.52, 0.60)
	var dark: StandardMaterial3D = _mat(Color(0.018, 0.020, 0.020), 0.88)
	var sand: StandardMaterial3D = _mat(Color(0.34, 0.30, 0.20), 0.98)
	var canvas: StandardMaterial3D = _mat(Color(0.17, 0.19, 0.12), 0.99)
	var wet: StandardMaterial3D = _mat(Color(0.052, 0.060, 0.062), 0.16)

	_build_bunker_interior(holder, concrete, metal, dark, wood, wet)
	_build_depot_interior(holder, brick, wood, metal, canvas, dark)
	_build_command_post_interior(holder, wood, metal, canvas, dark)
	_build_defensive_prop_clusters(holder, sand, wood, metal)
	_build_floor_detail(holder, wet, concrete)
	_build_practical_lighting(holder)


static func _build_bunker_interior(
	parent: Node3D,
	concrete: Material,
	metal: Material,
	dark: Material,
	wood: Material,
	wet: Material
) -> void:
	var base := Vector3(13.0, 0.0, 0.0)

	# Inner floor/ceiling layers make the bunker read as a volume, not a shell.
	_box(parent, "BunkerInnerFloor", base + Vector3(0.0, 0.08, 0.0),
		Vector3(3.3, 0.16, 5.7), concrete)
	_box(parent, "BunkerInnerCeiling", base + Vector3(0.0, 2.55, 0.0),
		Vector3(3.3, 0.18, 5.7), concrete)

	# Rear dark chamber.
	_box(parent, "BunkerRearVoid", base + Vector3(0.0, 1.25, 2.3),
		Vector3(2.8, 2.3, 0.20), dark)

	# Interior support beams and conduit.
	for x: float in [-1.35, 1.35]:
		_box(parent, "BunkerColumn", base + Vector3(x, 1.25, 0.0),
			Vector3(0.22, 2.5, 0.22), concrete)

	for z: float in [-1.7, 0.0, 1.7]:
		_box(parent, "BunkerCeilingBeam", base + Vector3(0.0, 2.35, z),
			Vector3(3.0, 0.18, 0.22), concrete)

	_box(parent, "BunkerConduit", base + Vector3(1.25, 1.70, -0.6),
		Vector3(0.07, 1.8, 0.07), metal)
	_box(parent, "BunkerJunctionBox", base + Vector3(1.20, 1.10, -0.6),
		Vector3(0.28, 0.38, 0.18), metal)

	# Workbench + ammo crates.
	_box(parent, "BunkerBenchTop", base + Vector3(-0.65, 0.75, 1.0),
		Vector3(1.5, 0.12, 0.65), wood)
	for x: float in [-1.2, -0.1]:
		_box(parent, "BunkerBenchLeg", base + Vector3(x, 0.38, 1.0),
			Vector3(0.10, 0.75, 0.10), metal)

	for i: int in range(3):
		_box(parent, "BunkerAmmoCrate", base + Vector3(-0.7 + i*0.62, 0.38, -1.55),
			Vector3(0.55, 0.55, 0.62), wood, float(i*6))

	# Wet floor patch reflecting the practical light.
	_box(parent, "BunkerWetFloor", base + Vector3(0.15, 0.17, -0.4),
		Vector3(1.9, 0.012, 1.0), wet)


static func _build_depot_interior(
	parent: Node3D,
	brick: Material,
	wood: Material,
	metal: Material,
	canvas: Material,
	dark: Material
) -> void:
	var depot := Vector3(0.0, 0.0, 9.0)

	# Back wall shelving and shadowed storage bays.
	for bay: int in range(3):
		var x := -1.7 + bay * 1.7
		_box(parent, "DepotBayVoid", depot + Vector3(x, 1.15, 1.5),
			Vector3(1.35, 2.0, 0.16), dark)
		_box(parent, "DepotShelfTop", depot + Vector3(x, 1.65, 1.35),
			Vector3(1.25, 0.10, 0.52), wood)
		_box(parent, "DepotShelfMid", depot + Vector3(x, 0.95, 1.35),
			Vector3(1.25, 0.10, 0.52), wood)

	# Hanging tarp partition.
	_box(parent, "DepotCanvasPartition", depot + Vector3(2.25, 1.45, 0.25),
		Vector3(0.08, 2.5, 2.4), canvas)

	# Fuel and supply grouping.
	for i: int in range(4):
		_cyl(parent, "DepotDrum", depot + Vector3(-2.1 + i*0.60, 0.52, -1.25),
			0.32, 1.02, metal)

	for row: int in range(2):
		for col: int in range(4):
			_box(parent, "DepotCrate", depot + Vector3(
				0.2 + col*0.72,
				0.36 + row*0.64,
				-1.15 + 0.12*(row%2)
			), Vector3(0.62, 0.60, 0.62), wood, float((row+col)*5))

	# Brick side repair wall for additional depth.
	_box(parent, "DepotRepairWall", depot + Vector3(-2.7, 1.2, 0.4),
		Vector3(0.30, 2.4, 2.6), brick)


static func _build_command_post_interior(
	parent: Node3D,
	wood: Material,
	metal: Material,
	canvas: Material,
	dark: Material
) -> void:
	var cp := Vector3(0.0, 0.0, -9.0)

	# Raised command platform.
	_box(parent, "CPPlatform", cp + Vector3(0.0, 0.22, 0.0),
		Vector3(4.5, 0.22, 3.4), wood)

	# Two simple steps.
	_box(parent, "CPStep1", cp + Vector3(0.0, 0.12, -2.0),
		Vector3(1.8, 0.22, 0.55), wood)
	_box(parent, "CPStep2", cp + Vector3(0.0, 0.28, -1.55),
		Vector3(1.8, 0.22, 0.55), wood)

	# Map table + radio station.
	_box(parent, "CPMapTable", cp + Vector3(-0.55, 0.92, 0.3),
		Vector3(1.9, 0.10, 1.1), wood)
	for x: float in [-1.25, 0.15]:
		for z: float in [-0.05, 0.65]:
			_box(parent, "CPMapLeg", cp + Vector3(x, 0.50, z),
				Vector3(0.10, 0.80, 0.10), metal)

	_box(parent, "CPRadioDesk", cp + Vector3(1.25, 0.80, 0.45),
		Vector3(1.3, 0.12, 0.70), wood)
	_box(parent, "CPRadioBox", cp + Vector3(1.25, 1.15, 0.45),
		Vector3(0.72, 0.48, 0.45), dark)

	# Canvas flap and support poles.
	_box(parent, "CPCanvasWall", cp + Vector3(-2.15, 1.4, 0.0),
		Vector3(0.08, 2.6, 3.0), canvas)
	for z: float in [-1.35, 1.35]:
		_box(parent, "CPSupportPole", cp + Vector3(-2.05, 1.5, z),
			Vector3(0.10, 3.0, 0.10), metal)


static func _build_defensive_prop_clusters(
	parent: Node3D,
	sand: Material,
	wood: Material,
	metal: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(7.0,0.0,-7.0),
		Vector3(-7.0,0.0,7.0),
		Vector3(18.0,0.0,13.0),
		Vector3(-15.0,0.0,-3.0)
	]

	for c: int in range(centers.size()):
		var base := centers[c]

		# Staggered sandbag stack.
		for row: int in range(3):
			for i: int in range(6):
				var x := -1.25 + i*0.48 + (0.24 if row%2==1 else 0.0)
				_box(parent, "Sandbag", base + Vector3(x, 0.17 + row*0.19, 0.0),
					Vector3(0.44,0.18,0.28), sand, float((i+row)*3))

		# Ammo boxes + loose steel.
		_box(parent, "AmmoBoxA", base + Vector3(1.35,0.35,0.55),
			Vector3(0.62,0.55,0.52), wood, 8.0)
		_box(parent, "AmmoBoxB", base + Vector3(1.85,0.35,0.80),
			Vector3(0.55,0.48,0.50), wood, -7.0)

		var steel := _box(parent, "SteelScrap", base + Vector3(-1.55,0.58,0.65),
			Vector3(0.10,1.35,0.12), metal)
		steel.rotation.z = deg_to_rad(48.0)


static func _build_floor_detail(
	parent: Node3D,
	wet: Material,
	concrete: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(13.0,0.02,0.0),
		Vector3(0.0,0.02,9.0),
		Vector3(0.0,0.02,-9.0)
	]

	for i: int in range(points.size()):
		_box(parent, "InteriorWetPatch", points[i],
			Vector3(1.6,0.010,0.85), wet, float(i*17))
		_box(parent, "BrokenFloorSlab", points[i] + Vector3(1.1,0.06,0.35),
			Vector3(0.85,0.10,0.72), concrete, float(i*11-7))


static func _build_practical_lighting(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(13.0,2.1,-1.0),
		Vector3(-1.7,2.25,9.8),
		Vector3(1.7,2.2,-9.2)
	]

	for i: int in range(positions.size()):
		var light := OmniLight3D.new()
		light.name = "InteriorPractical_%d" % i
		light.position = positions[i]
		light.light_color = Color(1.0,0.58,0.24)
		light.light_energy = 0.42
		light.omni_range = 4.2
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
	mesh.radial_segments = 12
	mi.mesh = mesh
	mi.position = position
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
