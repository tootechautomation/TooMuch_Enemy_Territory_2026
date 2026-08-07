extends Node
class_name FPSPresentationPass

# v8.51.0
# The player weapon_view now owns the one authoritative hand/arm rig.
# This helper intentionally adds NO duplicate geometry.

var root: Node
var camera: Camera3D
var fill_light: OmniLight3D

func initialize(game_root: Node) -> void:
    root = game_root
    call_deferred("_setup")


func _setup() -> void:
    camera = _find_active_camera(root)
    if camera == null:
        return

    fill_light = OmniLight3D.new()
    fill_light.name = "ViewmodelFill_v851"
    fill_light.position = Vector3(0.05, 0.08, -0.42)
    fill_light.light_color = Color(0.72, 0.77, 0.84)
    fill_light.light_energy = 0.24
    fill_light.omni_range = 2.0
    fill_light.shadow_enabled = false
    camera.add_child(fill_light)


func _find_active_camera(node: Node) -> Camera3D:
    if node is Camera3D:
        var candidate: Camera3D = node as Camera3D
        if candidate.current:
            return candidate

    for child: Node in node.get_children():
        var found: Camera3D = _find_active_camera(child)
        if found != null:
            return found

    return null
