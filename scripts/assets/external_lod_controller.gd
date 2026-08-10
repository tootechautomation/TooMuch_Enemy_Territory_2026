extends Node
class_name ExternalLODController

@export var near_distance := 30.0
@export var medium_distance := 65.0
@export var far_distance := 110.0
@export var update_interval := 0.30

var camera: Camera3D
var tracked: Array[Node3D] = []
var accumulator := 0.0

func _ready() -> void:
	set_process(DisplayServer.get_name() != "headless")

func configure(active_camera: Camera3D) -> void:
	camera = active_camera

func register_external(node: Node3D) -> void:
	if node == null or tracked.has(node):
		return
	tracked.append(node)

func _process(delta: float) -> void:
	accumulator += delta
	if accumulator < update_interval:
		return
	accumulator = 0.0

	if camera == null or not is_instance_valid(camera):
		camera = get_viewport().get_camera_3d()
	if camera == null:
		return

	for node in tracked.duplicate():
		if node == null or not is_instance_valid(node):
			tracked.erase(node)
			continue
		_apply_lod(node)

func _apply_lod(node: Node3D) -> void:
	var distance: float = camera.global_position.distance_to(
		node.global_position
	)

	var node_far_distance: float = float(
		node.get_meta("lod_far", far_distance)
	)
	var node_medium_distance: float = float(
		node.get_meta("lod_medium", medium_distance)
	)
	var node_near_distance: float = float(
		node.get_meta("lod_near", near_distance)
	)

	var visible_geometry := distance <= node_far_distance
	node.visible = visible_geometry
	if not visible_geometry:
		return

	var medium_or_near := distance <= node_medium_distance
	var near := distance <= node_near_distance

	for child in node.find_children("*", "GeometryInstance3D", true):
		var geometry := child as GeometryInstance3D
		geometry.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			if medium_or_near
			else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
		geometry.visibility_range_end = node_far_distance
		geometry.visibility_range_fade_mode = (
			GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		)
		if geometry is MeshInstance3D:
			var mesh_instance := geometry as MeshInstance3D
			mesh_instance.gi_mode = (
				GeometryInstance3D.GI_MODE_STATIC
				if near
				else GeometryInstance3D.GI_MODE_DISABLED
			)
