extends RefCounted
class_name ExternalAssetLoader

static func instantiate_scene(
	parent: Node,
	scene: PackedScene,
	node_name: String,
	position: Vector3,
	rotation_y: float = 0.0,
	scale_value: Vector3 = Vector3.ONE
) -> Node3D:
	if parent == null or scene == null:
		return null

	var instance: Node = scene.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return null

	var node := instance as Node3D
	node.name = node_name
	node.position = position
	node.rotation.y = rotation_y
	node.scale = scale_value
	parent.add_child(node)
	return node

static func configure_character_model(
	model: Node3D
) -> void:
	if model == null:
		return

	for child in model.find_children("*", "GeometryInstance3D", true):
		var geometry := child as GeometryInstance3D
		geometry.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		)

static func animation_player(model: Node3D) -> AnimationPlayer:
	if model == null:
		return null
	for child in model.find_children("*", "AnimationPlayer", true):
		return child as AnimationPlayer
	return null

static func play_first_available(
	player: AnimationPlayer,
	candidates: Array[StringName],
	blend_time: float = 0.15
) -> StringName:
	if player == null:
		return &""

	for candidate in candidates:
		if player.has_animation(candidate):
			if player.current_animation != str(candidate):
				player.play(candidate, blend_time)
			return candidate
	return &""

static func apply_world_collision_contract(model: Node3D) -> int:
	if model == null:
		return 0
	var bodies := 0
	for child in model.find_children("*", "StaticBody3D", true):
		var body := child as StaticBody3D
		body.collision_layer = 1
		body.collision_mask = 1
		bodies += 1
	return bodies

static func find_socket(
	model: Node3D,
	names: Array[String]
) -> Node3D:
	if model == null:
		return null
	for socket_name in names:
		var exact := model.find_child(socket_name, true, false)
		if exact is Node3D:
			return exact as Node3D
	return null

static func hide_named_nodes(
	root: Node,
	names: Array[String]
) -> void:
	if root == null:
		return
	for node_name in names:
		var found := root.find_child(node_name, true, false)
		if found is Node3D:
			(found as Node3D).visible = false
