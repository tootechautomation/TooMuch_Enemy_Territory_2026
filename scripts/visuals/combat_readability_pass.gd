extends RefCounted
class_name CombatReadabilityPass

# v8.61 visual-only readability pass.
# Keeps the battlefield moody while reducing flat gray target/background merge.

static func apply(root: Node) -> void:
	if root == null or root.has_node("CombatReadabilityPass_v861"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "CombatReadabilityPass_v861"
	root.add_child(holder)

	_add_soft_overcast_fill(holder)
	_add_objective_edge_lights(holder)


static func _add_soft_overcast_fill(parent: Node3D) -> void:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.name = "ReadabilitySkyFill"
	light.rotation_degrees = Vector3(-61.0, -32.0, 0.0)
	light.light_color = Color(0.58, 0.66, 0.73)
	light.light_energy = 0.12
	light.shadow_enabled = false
	parent.add_child(light)


static func _add_objective_edge_lights(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(12.0, 2.4, -2.0),
		Vector3(1.5, 2.3, 8.0),
		Vector3(-1.5, 2.3, -8.0)
	]

	for index: int in range(positions.size()):
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "ObjectiveEdge_%d" % index
		light.position = positions[index]
		light.light_color = Color(0.95, 0.72, 0.46)
		light.light_energy = 0.20
		light.omni_range = 3.8
		light.shadow_enabled = false
		parent.add_child(light)
