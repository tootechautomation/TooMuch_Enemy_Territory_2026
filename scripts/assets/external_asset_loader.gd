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
