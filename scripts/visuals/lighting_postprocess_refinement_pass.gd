extends RefCounted
class_name LightingPostProcessRefinementPass

# v8.79 — visual-only lighting and post-process refinement.
# Designed to improve separation/readability without altering gameplay.

static func apply(root: Node) -> void:
	if root == null or root.has_node("LightingPostProcessRefinement_v879"):
		return

	var marker := Node3D.new()
	marker.name = "LightingPostProcessRefinement_v879"
	root.add_child(marker)

	_refine_world_environment(root)
	_add_cool_rim(marker)
	_add_warm_bounce(marker)
	_add_objective_fill(marker)


static func _refine_world_environment(root: Node) -> void:
	var environment_nodes := root.find_children("*", "WorldEnvironment", true)

	for value: Node in environment_nodes:
		var world_environment := value as WorldEnvironment
		if world_environment == null or world_environment.environment == null:
			continue

		var environment: Environment = world_environment.environment

		# Contact/depth separation.
		_set_if_available(environment, &"ssao_enabled", true)
		_set_if_available(environment, &"ssao_radius", 2.15)
		_set_if_available(environment, &"ssao_intensity", 1.85)
		_set_if_available(environment, &"ssao_power", 1.32)

		_set_if_available(environment, &"ssil_enabled", true)
		_set_if_available(environment, &"ssil_radius", 3.25)
		_set_if_available(environment, &"ssil_intensity", 0.82)

		# Restrained cinematic grading. This is intentionally subtle so blue/red
		# team colors and enemy silhouettes remain easy to identify.
		_set_if_available(environment, &"adjustment_enabled", true)
		_set_if_available(environment, &"adjustment_brightness", 0.99)
		_set_if_available(environment, &"adjustment_contrast", 1.075)
		_set_if_available(environment, &"adjustment_saturation", 0.91)

		# Keep emissive lamps/fire present without excessive bloom.
		_set_if_available(environment, &"glow_enabled", true)
		_set_if_available(environment, &"glow_intensity", 0.48)

		# Slightly stronger distance falloff, but never heavy enough to obscure
		# objective markers or normal combat ranges.
		_set_if_available(environment, &"fog_enabled", true)
		var current_density: float = float(
			environment.get("fog_density")
			if _has_property(environment, &"fog_density")
			else 0.008
		)
		_set_if_available(
			environment,
			&"fog_density",
			clampf(maxf(current_density, 0.0075), 0.0, 0.0105)
		)

		# Volumetric fog remains conservative because this map already uses
		# rain, smoke and low-ground haze.
		if _has_property(environment, &"volumetric_fog_enabled"):
			_set_if_available(environment, &"volumetric_fog_enabled", true)
			_set_if_available(environment, &"volumetric_fog_density", 0.014)
			_set_if_available(environment, &"volumetric_fog_length", 64.0)


static func _add_cool_rim(parent: Node3D) -> void:
	var rim := DirectionalLight3D.new()
	rim.name = "CoolStormRim_v879"
	rim.rotation_degrees = Vector3(-38.0, 142.0, 0.0)
	rim.light_color = Color(0.42, 0.52, 0.64)
	rim.light_energy = 0.14
	rim.shadow_enabled = false
	parent.add_child(rim)


static func _add_warm_bounce(parent: Node3D) -> void:
	var points: Array[Vector3] = [
		Vector3(-11.0, 1.5, -5.5),
		Vector3(16.0, 1.5, 8.0),
		Vector3(0.0, 1.6, -9.0),
		Vector3(0.0, 1.6, 9.0)
	]

	for i: int in range(points.size()):
		var light := OmniLight3D.new()
		light.name = "WarmBounce_%d" % i
		light.position = points[i]
		light.light_color = Color(1.0, 0.49, 0.20)
		light.light_energy = 0.12
		light.omni_range = 4.0
		light.shadow_enabled = false
		parent.add_child(light)


static func _add_objective_fill(parent: Node3D) -> void:
	# Neutral fill around main combat areas prevents players from becoming flat
	# black silhouettes when viewed against brighter fog/sky.
	var points: Array[Vector3] = [
		Vector3(13.0, 2.0, 0.0),
		Vector3(0.0, 2.0, 9.0),
		Vector3(0.0, 2.0, -9.0)
	]

	for i: int in range(points.size()):
		var light := OmniLight3D.new()
		light.name = "ObjectiveNeutralFill_%d" % i
		light.position = points[i]
		light.light_color = Color(0.66, 0.70, 0.72)
		light.light_energy = 0.095
		light.omni_range = 5.5
		light.shadow_enabled = false
		parent.add_child(light)


static func _set_if_available(
	object: Object,
	property_name: StringName,
	value: Variant
) -> void:
	if _has_property(object, property_name):
		object.set(property_name, value)


static func _has_property(
	object: Object,
	property_name: StringName
) -> bool:
	for property_data: Dictionary in object.get_property_list():
		if StringName(property_data.get("name", "")) == property_name:
			return true
	return false
