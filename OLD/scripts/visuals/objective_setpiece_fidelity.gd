extends Node3D
class_name ObjectiveSetpieceFidelity

var world_root: Node
var bridge_stages: Array[Node3D] = []
var dynamite_detail: Node3D
var sector_flags: Dictionary = {}
var materials: Dictionary = {}

func build(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	world_root = root
	_build_bridge_site()
	_build_command_post()
	_build_supply_depot()
	_build_dynamite_bundle()
	_build_bunker_details()
	_build_sector_flags()

func _process(_delta: float) -> void:
	if world_root == null:
		return
	_update_bridge_stages()
	_update_dynamite()
	_update_sector_flags()

func _material(
	key: String,
	color: Color,
	roughness: float = 0.9,
	metallic: float = 0.0,
	emission: Color = Color(0.0, 0.0, 0.0, 1.0)
) -> StandardMaterial3D:
	if materials.has(key):
		return materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emission != Color(0.0, 0.0, 0.0, 1.0):
		material.emission_enabled = true
		material.emission = emission
	materials[key] = material
	return material

func _box(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	size: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _cylinder(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO,
	segments: int = 14
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	instance.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	instance.mesh = mesh
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _build_bridge_site() -> void:
	var site := world_root.get_node_or_null("BridgeBuildSite") as Node3D
	if site == null:
		return
	var wood := _material("bridge_wood", Color(0.26, 0.125, 0.045), 0.87)
	var steel := _material("bridge_steel", Color(0.09, 0.10, 0.105), 0.43, 0.72)
	var rope := _material("bridge_rope", Color(0.25, 0.19, 0.105), 1.0)
	for stage_index in range(10):
		var stage := Node3D.new()
		stage.name = "BridgeConstructionStage_%02d" % (stage_index + 1)
		stage.set_meta("required_progress", stage_index + 1)
		site.add_child(stage)
		var row := stage_index / 5
		var column := stage_index % 5
		var z := -2.2 + float(column) * 1.1
		var x := -1.15 if row == 0 else 1.15
		_box(stage, "BridgeDeckPlank", Vector3(x, 0.18, z), Vector3(2.15, 0.16, 0.92), wood)
		if column in [0, 4]:
			_box(stage, "BridgeEdgeRail", Vector3(x, 0.78, z), Vector3(2.15, 0.10, 0.10), steel)
			_cylinder(stage, "BridgeRailPost", Vector3(x - 0.85, 0.48, z), 0.045, 0.72, steel)
			_cylinder(stage, "BridgeRailPost", Vector3(x + 0.85, 0.48, z), 0.045, 0.72, steel)
		bridge_stages.append(stage)
	for x in [-2.1, 2.1]:
		for z in [-2.25, 2.25]:
			_cylinder(site, "BridgeGuideRope", Vector3(x, 0.60, z), 0.025, 1.2, rope)

func _build_command_post() -> void:
	var post := world_root.get_node_or_null("CommandPost") as Node3D
	if post == null:
		return
	var wood := _material("cp_wood", Color(0.20, 0.10, 0.035), 0.90)
	var radio := _material("cp_radio", Color(0.13, 0.16, 0.12), 0.52, 0.38)
	var metal := _material("cp_metal", Color(0.07, 0.075, 0.07), 0.42, 0.68)
	var canvas := _material("cp_canvas", Color(0.30, 0.29, 0.20), 0.98)
	_box(post, "FieldTableTop", Vector3(0.0, 0.76, 0.18), Vector3(2.45, 0.13, 1.35), wood)
	for x in [-1.02, 1.02]:
		for z in [-0.38, 0.70]:
			_box(post, "FieldTableLeg", Vector3(x, 0.38, z), Vector3(0.12, 0.76, 0.12), wood)
	_box(post, "RadioChassis", Vector3(0.0, 1.18, 0.10), Vector3(1.25, 0.72, 0.72), radio)
	for x in [-0.38, 0.0, 0.38]:
		_cylinder(post, "RadioControlKnob", Vector3(x, 1.18, -0.275), 0.065, 0.05, metal, Vector3(90.0, 0.0, 0.0), 12)
	_box(post, "RadioFrequencyWindow", Vector3(0.0, 1.39, -0.285), Vector3(0.56, 0.16, 0.035), _material("radio_glow", Color(0.36, 0.48, 0.22), 0.35, 0.0, Color(0.08, 0.18, 0.04)))
	_cylinder(post, "RadioAntenna", Vector3(0.52, 2.36, 0.22), 0.018, 2.45, metal, Vector3(0.0, 0.0, -5.0), 10)
	_box(post, "MapBoard", Vector3(-1.58, 1.25, 0.42), Vector3(0.08, 1.15, 1.55), canvas, Vector3(0.0, 0.0, -8.0))

func _build_supply_depot() -> void:
	var depot := world_root.get_node_or_null("SupplyDepot") as Node3D
	if depot == null:
		return
	var wood := _material("depot_wood", Color(0.27, 0.16, 0.065), 0.92)
	var canvas := _material("depot_canvas", Color(0.31, 0.34, 0.22), 0.98)
	var metal := _material("depot_metal", Color(0.10, 0.11, 0.10), 0.48, 0.62)
	for x in [-2.0, 2.0]:
		for z in [-1.55, 1.55]:
			_cylinder(depot, "CanopyPole", Vector3(x, 1.45, z), 0.04, 2.9, metal)
	_box(depot, "CanvasCanopy", Vector3(0.0, 2.82, 0.0), Vector3(4.5, 0.08, 3.55), canvas, Vector3(0.0, 0.0, 2.0))
	for z in [-0.75, 0.0, 0.75]:
		_box(depot, "DetailedSupplyCrate", Vector3(-1.45, 0.38, z), Vector3(0.9, 0.76, 0.62), wood)
		_box(depot, "CrateBand", Vector3(-1.45, 0.38, z - 0.23), Vector3(0.94, 0.10, 0.07), metal)
	for index in range(5):
		_cylinder(depot, "ArtilleryShell", Vector3(1.05 + float(index % 2) * 0.22, 0.34 + float(index / 2) * 0.28, -0.32), 0.055, 0.42, metal, Vector3(90.0, 0.0, 0.0), 12)

func _build_dynamite_bundle() -> void:
	dynamite_detail = Node3D.new()
	dynamite_detail.name = "DetailedDynamiteBundle"
	dynamite_detail.position = Vector3(10.85, 1.45, 0.0)
	world_root.add_child(dynamite_detail)
	var explosive := _material("dynamite", Color(0.54, 0.075, 0.045), 0.88)
	var wire := _material("dynamite_wire", Color(0.06, 0.055, 0.045), 0.55, 0.35)
	var timer := _material("dynamite_timer", Color(0.17, 0.19, 0.16), 0.38, 0.62)
	for row in range(2):
		for column in range(3):
			_cylinder(dynamite_detail, "ExplosiveStick", Vector3((float(column) - 1.0) * 0.16, (float(row) - 0.5) * 0.14, 0.0), 0.065, 0.52, explosive, Vector3(90.0, 0.0, 0.0), 14)
	_box(dynamite_detail, "TimerBox", Vector3(0.0, -0.18, -0.08), Vector3(0.30, 0.18, 0.22), timer)
	_cylinder(dynamite_detail, "DetonatorWire", Vector3(0.0, -0.04, -0.24), 0.018, 0.46, wire, Vector3(90.0, 0.0, 0.0), 10)
	dynamite_detail.visible = false

func _build_bunker_details() -> void:
	var bunker := world_root.get_node_or_null("Objective") as Node3D
	if bunker == null:
		return
	var concrete := _material("bunker_concrete", Color(0.31, 0.32, 0.30), 0.98)
	var steel := _material("bunker_steel", Color(0.08, 0.085, 0.08), 0.40, 0.74)
	_box(bunker, "BunkerRoofSlab", Vector3(0.0, 1.72, 0.0), Vector3(4.55, 0.38, 7.55), concrete)
	_box(bunker, "ArmoredBlastDoor", Vector3(-2.08, 0.0, 0.0), Vector3(0.18, 2.30, 2.10), steel)
	for z in [-2.25, 2.25]:
		_box(bunker, "FiringPort", Vector3(-2.10, 0.36, z), Vector3(0.16, 0.48, 1.05), steel)
	for z in [-2.75, 2.75]:
		_cylinder(bunker, "RoofVent", Vector3(0.75, 2.18, z), 0.16, 0.85, steel)

func _build_sector_flags() -> void:
	for sector_name_value in ["Rail_Yard", "Fort", "South_Annex"]:
		var sector := world_root.get_node_or_null("Sector_%s" % sector_name_value) as Node3D
		if sector == null:
			continue
		var flag_root := Node3D.new()
		flag_root.name = "SectorFieldFlag"
		sector.add_child(flag_root)
		_cylinder(flag_root, "FlagPole", Vector3(0.0, 1.8, 0.0), 0.035, 3.6, _material("flag_pole", Color(0.12, 0.13, 0.12), 0.48, 0.62))
		var cloth := _box(flag_root, "FlagCloth", Vector3(0.55, 3.05, 0.0), Vector3(1.05, 0.62, 0.035), _material("flag_%s" % sector_name_value, Color(0.46, 0.44, 0.37), 0.96))
		sector_flags[sector_name_value.replace("_", " ")] = cloth

func _update_bridge_stages() -> void:
	var progress := int(world_root.get("bridge_progress"))
	var stage := int(world_root.get("objective_stage"))
	for stage_node in bridge_stages:
		stage_node.visible = stage == 0 and progress >= int(stage_node.get_meta("required_progress", 1))

func _update_dynamite() -> void:
	if dynamite_detail != null:
		dynamite_detail.visible = bool(world_root.get("dynamite_armed"))

func _update_sector_flags() -> void:
	var control: Dictionary = Dictionary(world_root.get("sector_control"))
	var contested: Dictionary = Dictionary(world_root.get("sector_contested"))
	for sector_name_value in sector_flags.keys():
		var sector_name := str(sector_name_value)
		var cloth := sector_flags[sector_name_value] as MeshInstance3D
		if cloth == null:
			continue
		var owner := int(control.get(sector_name, -1))
		var color := Color(0.46, 0.44, 0.37)
		if bool(contested.get(sector_name, false)):
			color = Color(1.0, 0.62, 0.10)
		elif owner == 0:
			color = Color(0.16, 0.38, 0.82)
		elif owner == 1:
			color = Color(0.78, 0.16, 0.10)
		var material := cloth.material_override as StandardMaterial3D
		if material != null:
			material.albedo_color = color

