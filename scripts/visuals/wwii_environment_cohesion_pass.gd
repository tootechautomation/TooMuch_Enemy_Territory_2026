extends Node

var world_root: Node = null
var detail_holder: Node3D = null
var detail_nodes: Array[Node] = []
var update_accumulator: float = 0.0


static func apply(root: Node) -> void:
	if root == null:
		return
	if DisplayServer.get_name() == "headless":
		return
	if root.has_node("WWIIEnvironmentCohesionPass_v918"):
		return

	var pass_node: Node = load(
		"res://scripts/visuals/wwii_environment_cohesion_pass.gd"
	).new()
	pass_node.name = "WWIIEnvironmentCohesionPass_v918"
	root.add_child(pass_node)
	pass_node.call("_initialize", root)


func _initialize(root: Node) -> void:
	world_root = root
	detail_holder = Node3D.new()
	detail_holder.name = "EnvironmentCohesionDetail"
	add_child(detail_holder)

	_build_street_definition()
	_build_architectural_detail()
	_apply_quality()


func _process(delta: float) -> void:
	update_accumulator += delta
	if update_accumulator < 0.75:
		return
	update_accumulator = 0.0
	_apply_quality()


func _make_material(color: Color, roughness_value: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	return material


func _add_box(
	node_name: String,
	pos: Vector3,
	box_size: Vector3,
	material: Material,
	range_end: float
) -> void:
	if detail_holder == null:
		return

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name

	var box: BoxMesh = BoxMesh.new()
	box.size = box_size
	mesh_instance.mesh = box
	mesh_instance.position = pos
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.visibility_range_end = range_end

	detail_holder.add_child(mesh_instance)
	detail_nodes.append(mesh_instance)


func _build_street_definition() -> void:
	var curb: StandardMaterial3D = _make_material(
		Color(0.31, 0.31, 0.29),
		0.98
	)

	_add_box(
		"StreetCurb_A",
		Vector3(-22.0, 0.075, -11.7),
		Vector3(42.0, 0.15, 0.28),
		curb,
		64.0
	)
	_add_box(
		"StreetCurb_B",
		Vector3(-22.0, 0.075, 11.7),
		Vector3(42.0, 0.15, 0.28),
		curb,
		64.0
	)
	_add_box(
		"StreetCurb_C",
		Vector3(22.0, 0.075, -11.7),
		Vector3(42.0, 0.15, 0.28),
		curb,
		64.0
	)
	_add_box(
		"StreetCurb_D",
		Vector3(22.0, 0.075, 11.7),
		Vector3(42.0, 0.15, 0.28),
		curb,
		64.0
	)


func _build_architectural_detail() -> void:
	var stone: StandardMaterial3D = _make_material(
		Color(0.36, 0.35, 0.32),
		0.97
	)
	var wood: StandardMaterial3D = _make_material(
		Color(0.18, 0.12, 0.07),
		0.92
	)

	_add_box(
		"MinorDetail_StoneA",
		Vector3(-25.0, 1.0, -15.0),
		Vector3(0.28, 2.0, 0.28),
		stone,
		46.0
	)
	_add_box(
		"MinorDetail_StoneB",
		Vector3(25.0, 1.0, 15.0),
		Vector3(0.28, 2.0, 0.28),
		stone,
		46.0
	)
	_add_box(
		"MinorDetail_TimberA",
		Vector3(-12.0, 1.05, -18.5),
		Vector3(0.18, 2.1, 0.18),
		wood,
		44.0
	)
	_add_box(
		"MinorDetail_TimberB",
		Vector3(12.0, 1.05, 18.5),
		Vector3(0.18, 2.1, 0.18),
		wood,
		44.0
	)


func _quality_preset() -> int:
	if world_root == null:
		return 1

	var manager_value: Variant = world_root.get("visual_quality_manager")
	if manager_value == null:
		return 1

	var manager: Node = manager_value as Node
	if manager == null:
		return 1

	var preset_value: Variant = manager.get("current_preset")
	if preset_value == null:
		return 1

	return clampi(int(preset_value), 0, 2)


func _apply_quality() -> void:
	var quality: int = _quality_preset()

	for detail: Node in detail_nodes:
		if detail == null:
			continue
		if not is_instance_valid(detail):
			continue

		var geometry: GeometryInstance3D = detail as GeometryInstance3D
		if geometry == null:
			continue

		if quality == 0:
			geometry.visible = not geometry.name.begins_with("MinorDetail")
			geometry.visibility_range_end = minf(
				geometry.visibility_range_end,
				34.0
			)
		elif quality == 1:
			geometry.visible = true
		else:
			geometry.visible = true
			if geometry.name.begins_with("MinorDetail"):
				geometry.visibility_range_end = 58.0
