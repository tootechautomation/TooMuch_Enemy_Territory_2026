extends RefCounted
class_name HeroLocationReconstruction

# v8.46.0
# Rebuilds the map's most important combat landmarks with visual-only geometry.
# Existing gameplay collision and objective nodes remain authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("HeroLocationReconstruction_v846"):
		return

	var visual_root := Node3D.new()
	visual_root.name = "HeroLocationReconstruction_v846"
	root.add_child(visual_root)

	_rebuild_bridge(root, visual_root)
	_rebuild_objective_bunker(root, visual_root)
	_rebuild_supply_depot(root, visual_root)
	_rebuild_command_post(root, visual_root)
	_rebuild_fort_gate(root, visual_root)
	_rebuild_fort_watchtower(root, visual_root)
	_build_defensive_positions(root, visual_root)


static func _mat(root: Node, kind: String, color: Color, rough := 0.9, metallic := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metallic

	var tex_name := ""
	var normal_name := ""
	var rough_name := ""
	match kind:
		"concrete":
			tex_name = "pbr_concrete_albedo"
			normal_name = "pbr_concrete_normal"
			rough_name = "pbr_concrete_roughness"
		"brick":
			tex_name = "pbr_brick_albedo"
			normal_name = "pbr_brick_normal"
			rough_name = "pbr_brick_roughness"
		"wood":
			tex_name = "pbr_wood_albedo"
			normal_name = "pbr_wood_normal"
			rough_name = "pbr_wood_roughness"
		"rust":
			tex_name = "pbr_rust_albedo"
			normal_name = "pbr_rust_normal"
			rough_name = "pbr_rust_roughness"

	if tex_name != "":
		var tex = root.get(tex_name)
		if tex is Texture2D:
			m.albedo_texture = tex
			m.uv1_triplanar = true
			m.uv1_world_triplanar = true
			m.uv1_scale = Vector3(0.65, 0.65, 0.65)

		var normal_tex = root.get(normal_name)
		if normal_tex is Texture2D:
			m.normal_enabled = true
			m.normal_texture = normal_tex
			m.normal_scale = 0.85

		var rough_tex = root.get(rough_name)
		if rough_tex is Texture2D:
			m.roughness_texture = rough_tex

	return m


static func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3,
		mat: Material, rotation_y := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation.y = rotation_y
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _cylinder(parent: Node3D, name: String, pos: Vector3, radius: float,
		height: float, mat: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 14
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rotation
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _rebuild_bridge(root: Node, visual_root: Node) -> void:
	var bridge := root.get_node_or_null("ConstructedBridge") as Node3D
	if bridge == null:
		return

	var holder := Node3D.new()
	holder.name = "BridgeHeroGeometry"
	bridge.add_child(holder)

	var wood := _mat(root, "wood", Color(0.22, 0.13, 0.065), 0.94)
	var metal := _mat(root, "rust", Color(0.20, 0.17, 0.14), 0.72, 0.35)

	# Heavy timber deck slats over the existing collision slab.
	for i in range(11):
		var z := -2.45 + float(i) * 0.49
		_box(holder, "DeckPlank_%02d" % i, Vector3(0.0, 0.23, z),
			Vector3(4.75, 0.12, 0.39), wood)

	# Long support beams and edge rails make the bridge read as a structure.
	for x in [-2.16, 2.16]:
		_box(holder, "LongBeam", Vector3(x, -0.05, 0.0),
			Vector3(0.22, 0.30, 5.25), wood)
		for z in [-2.35, 2.35]:
			_box(holder, "Post", Vector3(x, 0.75, z),
				Vector3(0.18, 1.45, 0.18), wood)

	for z in [-2.35, 2.35]:
		_box(holder, "CrossBrace", Vector3(0.0, -0.14, z),
			Vector3(4.6, 0.18, 0.20), metal)

	# Simple diagonal side truss silhouette.
	for side in [-1.0, 1.0]:
		for i in range(4):
			var z := -1.8 + float(i) * 1.2
			var brace := _box(holder, "SideBrace", Vector3(side*2.20, 0.72, z),
				Vector3(0.12, 1.55, 0.13), metal)
			brace.rotation.z = deg_to_rad(38.0 if i % 2 == 0 else -38.0)


static func _rebuild_objective_bunker(root: Node, visual_root: Node) -> void:
	var objective := root.get_node_or_null("Objective") as Node3D
	if objective == null:
		return

	var holder := Node3D.new()
	holder.name = "BunkerHeroGeometry"
	objective.add_child(holder)

	var concrete := _mat(root, "concrete", Color(0.25, 0.255, 0.245), 0.96)
	var dark := _mat(root, "", Color(0.035, 0.038, 0.036), 0.75)
	var rust := _mat(root, "rust", Color(0.20, 0.15, 0.11), 0.78, 0.25)

	# Existing objective is 4 x 3 x 7. Build a layered bunker shell around it.
	_box(holder, "RoofSlab", Vector3(0.0, 1.72, 0.0),
		Vector3(5.25, 0.42, 8.05), concrete)
	_box(holder, "LeftCheek", Vector3(-2.18, 0.25, -0.15),
		Vector3(0.72, 3.55, 6.9), concrete)
	_box(holder, "RightCheek", Vector3(2.18, 0.25, -0.15),
		Vector3(0.72, 3.55, 6.9), concrete)

	# Deep firing aperture instead of a painted black rectangle.
	_box(holder, "EmbrasureVoid", Vector3(-0.55, 0.55, -3.58),
		Vector3(2.25, 0.78, 0.18), dark)
	_box(holder, "EmbrasureLintel", Vector3(-0.55, 1.06, -3.66),
		Vector3(2.75, 0.24, 0.42), concrete)
	_box(holder, "EmbrasureSill", Vector3(-0.55, 0.08, -3.66),
		Vector3(2.65, 0.28, 0.48), concrete)

	# Recessed personnel entrance and steel door.
	_box(holder, "EntranceVoid", Vector3(1.10, -0.05, 3.58),
		Vector3(1.45, 2.35, 0.22), dark)
	_box(holder, "SteelDoor", Vector3(1.10, -0.10, 3.72),
		Vector3(1.12, 2.08, 0.12), rust)
	for y in [-0.70, 0.0, 0.70]:
		_box(holder, "DoorBrace", Vector3(1.10, y, 3.80),
			Vector3(0.94, 0.08, 0.06), rust)

	# Angled blast wings build a stronger silhouette.
	for side in [-1.0, 1.0]:
		var wing := _box(holder, "BlastWing", Vector3(side*2.85, -0.10, 2.55),
			Vector3(1.5, 2.6, 0.58), concrete, deg_to_rad(side * 24.0))
		wing.position.x = side * 2.75

	# Roof debris and exposed reinforcement.
	for i in range(5):
		var x := -1.7 + float(i) * 0.82
		_cylinder(holder, "Rebar", Vector3(x, 2.08, -1.9 + 0.35*(i%2)),
			0.025, 0.85, rust, Vector3(deg_to_rad(78.0), 0.2*i, 0.0))


static func _rebuild_supply_depot(root: Node, visual_root: Node) -> void:
	var depot := root.get_node_or_null("SupplyDepot") as Node3D
	if depot == null:
		return

	var holder := Node3D.new()
	holder.name = "SupplyDepotHeroGeometry"
	depot.add_child(holder)

	var wood := _mat(root, "wood", Color(0.25, 0.15, 0.075), 0.94)
	var metal := _mat(root, "rust", Color(0.17, 0.18, 0.16), 0.78, 0.30)
	var tarp := _mat(root, "", Color(0.16, 0.20, 0.12), 0.98)

	# Four-post covered depot shelter.
	for x in [-2.45, 2.45]:
		for z in [-2.05, 2.05]:
			_box(holder, "DepotPost", Vector3(x, 1.45, z),
				Vector3(0.20, 2.9, 0.20), wood)

	_box(holder, "DepotRoof", Vector3(0.0, 3.00, 0.0),
		Vector3(5.7, 0.18, 4.9), tarp)
	_box(holder, "RoofBeamFront", Vector3(0.0, 2.72, -2.1),
		Vector3(5.25, 0.23, 0.18), wood)
	_box(holder, "RoofBeamBack", Vector3(0.0, 2.72, 2.1),
		Vector3(5.25, 0.23, 0.18), wood)

	# Stacked crates and fuel drums give the capture area vertical layers.
	for row in range(2):
		for col in range(4):
			var x := -1.65 + float(col) * 1.05
			var y := 0.48 + float(row) * 0.82
			var z := 1.32 if row == 0 else 1.47
			_box(holder, "CrateStack", Vector3(x, y, z),
				Vector3(0.88, 0.76, 0.82), wood)

	for x in [-1.55, 1.55]:
		_cylinder(holder, "FuelDrum", Vector3(x, 0.52, -1.30),
			0.38, 1.02, metal)

	# Depot sign board.
	_box(holder, "DepotSignBoard", Vector3(0.0, 2.05, -2.30),
		Vector3(2.8, 0.65, 0.10), wood)


static func _rebuild_command_post(root: Node, visual_root: Node) -> void:
	var cp := root.get_node_or_null("CommandPost") as Node3D
	if cp == null:
		return

	var holder := Node3D.new()
	holder.name = "CommandPostHeroGeometry"
	cp.add_child(holder)

	var wood := _mat(root, "wood", Color(0.20, 0.125, 0.065), 0.95)
	var canvas := _mat(root, "", Color(0.23, 0.25, 0.18), 0.98)
	var metal := _mat(root, "rust", Color(0.16, 0.17, 0.15), 0.80, 0.28)

	# Field command shelter with a sloped canopy.
	for x in [-2.3, 2.3]:
		for z in [-1.8, 1.8]:
			_box(holder, "CPPost", Vector3(x, 1.4, z),
				Vector3(0.18, 2.8, 0.18), wood)

	var roof := _box(holder, "CPCanopy", Vector3(0.0, 2.82, 0.0),
		Vector3(5.2, 0.16, 4.25), canvas)
	roof.rotation.x = deg_to_rad(-5.0)

	# Map table, radio shelf and cable mast.
	_box(holder, "MapTableTop", Vector3(0.0, 0.92, 0.65),
		Vector3(2.3, 0.10, 1.25), wood)
	for x in [-0.92, 0.92]:
		for z in [0.20, 1.10]:
			_box(holder, "MapTableLeg", Vector3(x, 0.45, z),
				Vector3(0.12, 0.90, 0.12), wood)

	_box(holder, "RadioShelf", Vector3(-1.45, 1.10, -0.60),
		Vector3(1.4, 0.10, 0.55), wood)
	_cylinder(holder, "AntennaMast", Vector3(2.1, 2.25, -0.9),
		0.045, 4.5, metal)


static func _rebuild_fort_gate(root: Node, visual_root: Node) -> void:
	var holder := Node3D.new()
	holder.name = "FortGateHeroGeometry"
	holder.position = Vector3(18.0, 0.0, 25.0)
	visual_root.add_child(holder)

	var concrete := _mat(root, "concrete", Color(0.24, 0.245, 0.235), 0.96)
	var metal := _mat(root, "rust", Color(0.13, 0.14, 0.13), 0.78, 0.38)

	# Gate lintel + inner steel frame connect the two existing gate wall blocks.
	_box(holder, "GateLintel", Vector3(0.0, 4.45, 0.0),
		Vector3(1.15, 0.70, 6.1), concrete)
	for z in [-3.0, 3.0]:
		_box(holder, "GateFrame", Vector3(-0.54, 2.30, z),
			Vector3(0.18, 4.0, 0.22), metal)

	# Czech-hedgehog style steel obstacles in front of the gate.
	for i in range(3):
		var z := -2.7 + float(i) * 2.7
		var p := Vector3(-2.2, 0.55, z)
		for angle in [0.0, 60.0, -60.0]:
			var beam := _box(holder, "GateObstacle", p,
				Vector3(0.18, 1.8, 0.18), metal)
			beam.rotation = Vector3(deg_to_rad(angle), 0.0, deg_to_rad(48.0))


static func _rebuild_fort_watchtower(root: Node, visual_root: Node) -> void:
	var tower := root.get_node_or_null("FortWatchtower") as Node3D
	if tower == null:
		return

	var holder := Node3D.new()
	holder.name = "WatchtowerHeroGeometry"
	tower.add_child(holder)

	var wood := _mat(root, "wood", Color(0.18, 0.115, 0.055), 0.95)
	var dark := _mat(root, "", Color(0.055, 0.060, 0.055), 0.88)

	# Extra X-bracing, roof overhang and sandbag parapet.
	for side_x in [-1.0, 1.0]:
		for side_z in [-1.0, 1.0]:
			var brace := _box(holder, "TowerBrace", Vector3(side_x*0.72, 2.2, side_z*0.72),
				Vector3(0.10, 3.2, 0.12), wood)
			brace.rotation.z = deg_to_rad(28.0 * side_x * side_z)

	_box(holder, "TowerRoof", Vector3(0.0, 4.65, 0.0),
		Vector3(2.7, 0.16, 2.7), dark)

	var sand := _mat(root, "", Color(0.30, 0.27, 0.18), 0.99)
	for side in [-1.0, 1.0]:
		for i in range(4):
			_box(holder, "TowerSandbag", Vector3(-0.75 + i*0.50, 3.72, side*0.98),
				Vector3(0.44, 0.20, 0.27), sand)


static func _build_defensive_positions(root: Node, visual_root: Node) -> void:
	var sand := _mat(root, "", Color(0.30, 0.27, 0.18), 0.99)
	var wood := _mat(root, "wood", Color(0.19, 0.115, 0.055), 0.95)
	var rust := _mat(root, "rust", Color(0.16, 0.15, 0.13), 0.80, 0.32)

	var nests := [
		[Vector3(8.0, 0.0, 8.2), 25.0],
		[Vector3(9.5, 0.0, -9.0), -20.0],
		[Vector3(23.0, 0.0, 13.8), 5.0],
		[Vector3(24.0, 0.0, 35.7), 178.0]
	]

	for n in range(nests.size()):
		var data = nests[n]
		var nest := Node3D.new()
		nest.name = "DefensiveNest_%d" % n
		nest.position = data[0]
		nest.rotation.y = deg_to_rad(float(data[1]))
		visual_root.add_child(nest)

		# Curved-looking sandbag wall assembled from offset bags.
		for row in range(3):
			for i in range(7):
				var x := -1.45 + float(i) * 0.48 + (0.24 if row % 2 else 0.0)
				var z := 0.12 * abs(i - 3)
				_box(nest, "Sandbag", Vector3(x, 0.18 + row*0.19, z),
					Vector3(0.46, 0.18, 0.28), sand)

		# Rear timber revetment and ammo details.
		_box(nest, "Revetment", Vector3(0.0, 0.55, 1.1),
			Vector3(3.2, 1.0, 0.16), wood)
		_box(nest, "AmmoBox", Vector3(1.1, 0.32, 0.65),
			Vector3(0.65, 0.48, 0.48), wood)
		_cylinder(nest, "SpentDrum", Vector3(-1.05, 0.32, 0.68),
			0.28, 0.60, rust)
