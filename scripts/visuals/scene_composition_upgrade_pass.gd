extends RefCounted
class_name SceneCompositionUpgradePass

# v8.58 — strengthens scene depth using lighting hierarchy and visual framing.
# Visual only: no collision/objective changes.

static func apply(root: Node) -> void:
	if root == null or root.has_node("SceneCompositionUpgrade_v858"):
		return

	var marker: Node3D = Node3D.new()
	marker.name = "SceneCompositionUpgrade_v858"
	root.add_child(marker)

	_add_warm_practicals(marker)
	_add_cool_fill(marker)
	_add_foreground_occluders(marker)


static func _add_warm_practicals(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-7.0, 2.2, 1.5),
		Vector3(6.5, 2.1, -2.0),
		Vector3(13.0, 2.0, 3.0),
		Vector3(-12.0, 2.15, 8.0)
	]
	for i: int in range(positions.size()):
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "WarmPractical_%d" % i
		light.position = positions[i]
		light.light_color = Color(1.0, 0.63, 0.30)
		light.light_energy = 0.42
		light.omni_range = 4.4
		light.shadow_enabled = true
		parent.add_child(light)


static func _add_cool_fill(parent: Node3D) -> void:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.name = "StormFill"
	light.rotation_degrees = Vector3(-54.0, 28.0, 0.0)
	light.light_color = Color(0.52, 0.61, 0.70)
	light.light_energy = 0.22
	light.shadow_enabled = false
	parent.add_child(light)


static func _add_foreground_occluders(parent: Node3D) -> void:
	var dark: StandardMaterial3D = StandardMaterial3D.new()
	dark.albedo_color = Color(0.08, 0.075, 0.065)
	dark.roughness = 0.95

	var pieces: Array[Dictionary] = [
		{"p": Vector3(-18.0, 0.75, -4.0), "s": Vector3(2.4, 1.5, 0.5), "r": -14.0},
		{"p": Vector3(17.0, 0.55, 6.0), "s": Vector3(1.8, 1.1, 0.5), "r": 12.0},
		{"p": Vector3(-9.0, 0.40, 14.0), "s": Vector3(2.0, 0.8, 0.45), "r": 8.0}
	]
	for i: int in range(pieces.size()):
		var data: Dictionary = pieces[i]
		var mi: MeshInstance3D = MeshInstance3D.new()
		mi.name = "ForegroundDebris_%d" % i
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = data["s"] as Vector3
		mi.mesh = mesh
		mi.position = data["p"] as Vector3
		mi.rotation.y = deg_to_rad(float(data["r"]))
		mi.material_override = dark
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		parent.add_child(mi)
