extends RefCounted
class_name TerrainArchitectureReconstruction

# v8.47.0 — visual-only terrain and architecture reconstruction.
# The existing collision/gameplay map remains authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("TerrainArchitectureReconstruction_v847"):
		return

	var visual_root: Node3D = Node3D.new()
	visual_root.name = "TerrainArchitectureReconstruction_v847"
	root.add_child(visual_root)

	_build_bunker_earthworks(root, visual_root)
	_build_bridge_approaches(root, visual_root)
	_build_command_post_earthworks(root, visual_root)
	_build_supply_depot_perimeter(root, visual_root)
	_build_broken_road_system(root, visual_root)
	_build_ruined_building_shells(root, visual_root)
	_build_trench_network(root, visual_root)


static func _material(
	root: Node,
	kind: String,
	color: Color,
	roughness: float = 0.92,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic

	var albedo_name: String = ""
	var normal_name: String = ""
	var rough_name: String = ""

	match kind:
		"mud":
			albedo_name = "pbr_mud_albedo"
			normal_name = "pbr_mud_normal"
			rough_name = "pbr_mud_roughness"
		"concrete":
			albedo_name = "pbr_concrete_albedo"
			normal_name = "pbr_concrete_normal"
			rough_name = "pbr_concrete_roughness"
		"brick":
			albedo_name = "pbr_brick_albedo"
			normal_name = "pbr_brick_normal"
			rough_name = "pbr_brick_roughness"
		"wood":
			albedo_name = "pbr_wood_albedo"
			normal_name = "pbr_wood_normal"
			rough_name = "pbr_wood_roughness"
		"rust":
			albedo_name = "pbr_rust_albedo"
			normal_name = "pbr_rust_normal"
			rough_name = "pbr_rust_roughness"

	if albedo_name != "":
		var albedo_value: Variant = root.get(albedo_name)
		if albedo_value is Texture2D:
			mat.albedo_texture = albedo_value as Texture2D
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(0.58, 0.58, 0.58)

		var normal_value: Variant = root.get(normal_name)
		if normal_value is Texture2D:
			mat.normal_enabled = true
			mat.normal_texture = normal_value as Texture2D
			mat.normal_scale = 0.95

		var rough_value: Variant = root.get(rough_name)
		if rough_value is Texture2D:
			mat.roughness_texture = rough_value as Texture2D

	return mat


static func _box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	yaw_degrees: float = 0.0
) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.rotation.y = deg_to_rad(yaw_degrees)
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mesh_instance)
	return mesh_instance


static func _wedge(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	yaw_degrees: float,
	slope_degrees: float
) -> MeshInstance3D:
	var wedge: MeshInstance3D = _box(
		parent, name, position, size, material, yaw_degrees
	)
	wedge.rotation.x = deg_to_rad(slope_degrees)
	return wedge


static func _build_bunker_earthworks(root: Node, parent: Node3D) -> void:
	var bunker: Node3D = root.get_node_or_null("Objective") as Node3D
	if bunker == null:
		return

	var holder: Node3D = Node3D.new()
	holder.name = "BunkerEarthworks"
	holder.position = bunker.position
	parent.add_child(holder)

	var mud: StandardMaterial3D = _material(
		root, "mud", Color(0.19, 0.155, 0.105), 0.98
	)
	var concrete: StandardMaterial3D = _material(
		root, "concrete", Color(0.25, 0.25, 0.235), 0.96
	)
	var wood: StandardMaterial3D = _material(
		root, "wood", Color(0.19, 0.11, 0.055), 0.96
	)

	# Earth berms wrap the bunker instead of leaving it as an isolated box.
	_box(holder, "RearBerm", Vector3(2.7, -0.55, 0.0),
		Vector3(3.8, 1.15, 9.0), mud, 0.0)
	_box(holder, "NorthBerm", Vector3(0.2, -0.58, -4.15),
		Vector3(6.7, 1.10, 1.55), mud, -5.0)
	_box(holder, "SouthBerm", Vector3(0.2, -0.58, 4.15),
		Vector3(6.7, 1.10, 1.55), mud, 5.0)

	# Retaining slabs create clear layering between dirt and concrete.
	for z_value: float in [-3.82, 3.82]:
		_box(holder, "RetainingWall", Vector3(-0.1, -0.12, z_value),
			Vector3(5.6, 0.85, 0.18), concrete)

	# Timber revetment pieces.
	for index: int in range(7):
		var z_value: float = -3.15 + float(index) * 1.02
		_box(holder, "RevetmentPost", Vector3(3.0, 0.05, z_value),
			Vector3(0.18, 1.4, 0.18), wood)

	# Entry trench leading toward the rear personnel door.
	_box(holder, "EntryTrenchFloor", Vector3(-4.1, -0.50, 2.0),
		Vector3(4.1, 0.22, 1.45), mud, 0.0)
	for z_value: float in [1.25, 2.75]:
		_box(holder, "EntryTrenchLip", Vector3(-4.0, -0.03, z_value),
			Vector3(4.5, 0.75, 0.65), mud)


static func _build_bridge_approaches(root: Node, parent: Node3D) -> void:
	var bridge: Node3D = root.get_node_or_null("ConstructedBridge") as Node3D
	if bridge == null:
		return

	var mud: StandardMaterial3D = _material(
		root, "mud", Color(0.18, 0.145, 0.095), 0.98
	)
	var concrete: StandardMaterial3D = _material(
		root, "concrete", Color(0.23, 0.23, 0.22), 0.96
	)

	# Slight raised approaches frame the bridge and create a shallow valley.
	for z_value: float in [-4.7, 4.7]:
		_box(parent, "BridgeApproach", Vector3(0.0, -0.28, z_value),
			Vector3(7.4, 0.72, 3.2), mud)

	# Broken concrete shoulders.
	for side: float in [-1.0, 1.0]:
		for index: int in range(4):
			var x_value: float = side * (2.9 + 0.42 * float(index))
			var z_value: float = -1.8 + 1.2 * float(index)
			var chunk: MeshInstance3D = _box(
				parent,
				"BridgeShoulderChunk",
				Vector3(x_value, 0.04, z_value),
				Vector3(0.65, 0.24, 1.05),
				concrete,
				side * (6.0 + float(index) * 2.0)
			)
			chunk.rotation.z = deg_to_rad(side * 4.0)

	# Drainage ditches to either side.
	for x_value: float in [-4.2, 4.2]:
		_box(parent, "BridgeDrainageCut", Vector3(x_value, -0.34, 0.0),
			Vector3(1.1, 0.35, 11.0), mud)


static func _build_command_post_earthworks(root: Node, parent: Node3D) -> void:
	var command_post: Node3D = root.get_node_or_null("CommandPost") as Node3D
	if command_post == null:
		return

	var holder: Node3D = Node3D.new()
	holder.name = "CommandPostEarthworks"
	holder.position = command_post.position
	parent.add_child(holder)

	var mud: StandardMaterial3D = _material(
		root, "mud", Color(0.175, 0.145, 0.095), 0.98
	)
	var wood: StandardMaterial3D = _material(
		root, "wood", Color(0.19, 0.115, 0.055), 0.96
	)

	# Horseshoe berm around the command post.
	_box(holder, "BackBerm", Vector3(0.0, -0.40, 2.45),
		Vector3(6.2, 0.95, 1.45), mud)
	_box(holder, "LeftBerm", Vector3(-2.65, -0.42, 0.1),
		Vector3(1.35, 0.95, 4.9), mud)
	_box(holder, "RightBerm", Vector3(2.65, -0.42, 0.1),
		Vector3(1.35, 0.95, 4.9), mud)

	# Revetment logs make the berm edge read at eye level.
	for index: int in range(8):
		var x_value: float = -2.4 + float(index) * 0.69
		_box(holder, "CPRevetment", Vector3(x_value, 0.05, 1.82),
			Vector3(0.55, 0.22, 0.24), wood)


static func _build_supply_depot_perimeter(root: Node, parent: Node3D) -> void:
	var depot: Node3D = root.get_node_or_null("SupplyDepot") as Node3D
	if depot == null:
		return

	var holder: Node3D = Node3D.new()
	holder.name = "SupplyDepotPerimeter"
	holder.position = depot.position
	parent.add_child(holder)

	var brick: StandardMaterial3D = _material(
		root, "brick", Color(0.28, 0.13, 0.08), 0.96
	)
	var rust: StandardMaterial3D = _material(
		root, "rust", Color(0.17, 0.16, 0.13), 0.80, 0.30
	)
	var wood: StandardMaterial3D = _material(
		root, "wood", Color(0.19, 0.11, 0.055), 0.96
	)

	# Broken perimeter wall with a large irregular gateway.
	_box(holder, "DepotWallLeft", Vector3(-3.6, 1.15, -3.0),
		Vector3(3.1, 2.3, 0.48), brick)
	_box(holder, "DepotWallRight", Vector3(3.8, 1.15, -3.0),
		Vector3(2.8, 2.3, 0.48), brick)
	_box(holder, "DepotGateLintel", Vector3(0.25, 2.55, -3.0),
		Vector3(2.4, 0.38, 0.56), brick)

	# Steel gate remnants.
	for x_value: float in [-1.0, 1.35]:
		var gate_piece: MeshInstance3D = _box(
			holder, "BrokenGate", Vector3(x_value, 0.95, -3.18),
			Vector3(0.12, 1.8, 1.0), rust, x_value * 10.0
		)
		gate_piece.rotation.z = deg_to_rad(x_value * 8.0)

	# Exterior crate barricade.
	for index: int in range(5):
		var x_value: float = -2.0 + float(index) * 1.0
		var z_value: float = 2.9 + 0.18 * float(index % 2)
		_box(holder, "DepotBarricadeCrate", Vector3(x_value, 0.45, z_value),
			Vector3(0.86, 0.82, 0.86), wood, float(index % 2) * 8.0)


static func _build_broken_road_system(root: Node, parent: Node3D) -> void:
	var concrete: StandardMaterial3D = _material(
		root, "concrete", Color(0.22, 0.215, 0.20), 0.97
	)
	var mud: StandardMaterial3D = _material(
		root, "mud", Color(0.17, 0.135, 0.085), 0.99
	)

	# Main east-west road is made from separated slabs to produce seams and
	# broken shoulders instead of one flat surface.
	for index: int in range(9):
		var x_value: float = -16.0 + float(index) * 4.0
		var z_offset: float = 0.10 * float((index % 3) - 1)
		var slab: MeshInstance3D = _box(
			parent,
			"BrokenRoadSlab",
			Vector3(x_value, 0.035, z_offset),
			Vector3(3.65, 0.14, 4.6),
			concrete,
			float((index % 3) - 1) * 1.4
		)
		slab.rotation.z = deg_to_rad(float((index % 2) * 2 - 1) * 0.6)

	# Mud shoulders create a stronger road/terrain transition.
	for z_value: float in [-3.05, 3.05]:
		_box(parent, "RoadShoulder", Vector3(0.0, -0.16, z_value),
			Vector3(36.0, 0.42, 1.65), mud)


static func _build_ruined_building_shells(root: Node, parent: Node3D) -> void:
	var brick: StandardMaterial3D = _material(
		root, "brick", Color(0.27, 0.115, 0.07), 0.96
	)
	var wood: StandardMaterial3D = _material(
		root, "wood", Color(0.17, 0.10, 0.05), 0.96
	)
	var dark: StandardMaterial3D = _material(
		root, "", Color(0.028, 0.030, 0.029), 0.82
	)

	var centers: Array[Vector3] = [
		Vector3(-12.5, 0.0, -11.5),
		Vector3(-13.0, 0.0, 12.5),
		Vector3(12.0, 0.0, 11.5)
	]
	var yaws: Array[float] = [8.0, -5.0, 5.0]

	for building_index: int in range(centers.size()):
		var shell: Node3D = Node3D.new()
		shell.name = "RuinedShell_%d" % building_index
		shell.position = centers[building_index]
		shell.rotation.y = deg_to_rad(yaws[building_index])
		parent.add_child(shell)

		# Unequal wall heights create a genuinely damaged skyline.
		_box(shell, "BackWall", Vector3(0.0, 1.8, 2.2),
			Vector3(6.0, 3.6, 0.38), brick)
		_box(shell, "LeftWall", Vector3(-2.8, 1.55, 0.0),
			Vector3(0.38, 3.1, 4.8), brick)
		_box(shell, "RightWallLower", Vector3(2.8, 1.05, 0.6),
			Vector3(0.38, 2.1, 3.2), brick)

		# Deep doorway and window cavities.
		_box(shell, "DoorVoid", Vector3(-0.8, 1.0, 1.98),
			Vector3(1.25, 2.05, 0.14), dark)
		_box(shell, "WindowVoid", Vector3(1.35, 1.85, 1.98),
			Vector3(1.2, 1.15, 0.14), dark)

		# Broken upper fragments and exposed roof beams.
		_box(shell, "UpperFragmentL", Vector3(-1.65, 3.85, 2.2),
			Vector3(2.2, 0.65, 0.38), brick, -4.0)
		_box(shell, "UpperFragmentR", Vector3(1.85, 3.35, 2.2),
			Vector3(1.5, 0.55, 0.38), brick, 5.0)

		for beam_index: int in range(4):
			var beam_x: float = -2.1 + float(beam_index) * 1.4
			var beam: MeshInstance3D = _box(
				shell, "RoofBeam", Vector3(beam_x, 3.55, 0.1),
				Vector3(0.16, 0.18, 4.6), wood
			)
			beam.rotation.x = deg_to_rad(
				-4.0 + float(beam_index % 3) * 4.0
			)


static func _build_trench_network(root: Node, parent: Node3D) -> void:
	var mud: StandardMaterial3D = _material(
		root, "mud", Color(0.165, 0.13, 0.08), 0.99
	)
	var wood: StandardMaterial3D = _material(
		root, "wood", Color(0.18, 0.105, 0.052), 0.96
	)

	var trench_centers: Array[Vector3] = [
		Vector3(-5.0, -0.34, -8.7),
		Vector3(5.0, -0.34, 8.7),
		Vector3(9.7, -0.34, -4.8)
	]
	var trench_yaws: Array[float] = [0.0, 0.0, 82.0]

	for trench_index: int in range(trench_centers.size()):
		var trench: Node3D = Node3D.new()
		trench.name = "LayeredTrench_%d" % trench_index
		trench.position = trench_centers[trench_index]
		trench.rotation.y = deg_to_rad(trench_yaws[trench_index])
		parent.add_child(trench)

		# Darker lowered floor plus two high lips creates the illusion of a
		# dug position while leaving player collision untouched.
		_box(trench, "TrenchFloor", Vector3.ZERO,
			Vector3(7.0, 0.18, 1.35), mud)
		for z_value: float in [-1.0, 1.0]:
			_box(trench, "TrenchLip", Vector3(0.0, 0.42, z_value),
				Vector3(7.4, 0.95, 0.72), mud)

		# Timber revetment segments inside the lip.
		for index: int in range(9):
			var x_value: float = -3.15 + float(index) * 0.78
			_box(trench, "TrenchTimber", Vector3(x_value, 0.28, 0.66),
				Vector3(0.10, 0.85, 0.16), wood)
