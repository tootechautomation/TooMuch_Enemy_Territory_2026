extends Node
class_name LowCostVisualClarity

var world_root: Node
var quality_manager: Node

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	apply_quality()


func on_quality_changed() -> void:
	apply_quality()


func apply_quality() -> void:
	if world_root == null or quality_manager == null:
		return

	var preset: int = clampi(
		int(quality_manager.get("current_preset")),
		0,
		2
	)

	for value: Node in world_root.find_children(
		"*",
		"WorldEnvironment",
		true
	):
		var world_environment := value as WorldEnvironment
		if (
			world_environment == null
			or world_environment.environment == null
		):
			continue

		var environment: Environment = world_environment.environment

		# Cheap readability improvements: no added meshes, lights, particles,
		# shadows or post-process passes. Low actually becomes LESS foggy.
		_set_if_available(environment, &"adjustment_enabled", true)

		match preset:
			0:
				_set_if_available(environment, &"fog_density", 0.0032)
				_set_if_available(environment, &"adjustment_brightness", 0.98)
				_set_if_available(environment, &"adjustment_contrast", 1.10)
				_set_if_available(environment, &"adjustment_saturation", 0.96)

			1:
				_set_if_available(environment, &"fog_density", 0.0052)
				_set_if_available(environment, &"adjustment_brightness", 0.99)
				_set_if_available(environment, &"adjustment_contrast", 1.085)
				_set_if_available(environment, &"adjustment_saturation", 0.94)

			_:
				_set_if_available(environment, &"fog_density", 0.0075)
				_set_if_available(environment, &"adjustment_brightness", 0.99)
				_set_if_available(environment, &"adjustment_contrast", 1.075)
				_set_if_available(environment, &"adjustment_saturation", 0.92)

		# Avoid washed-out white atmospheric light where the property exists.
		_set_if_available(
			environment,
			&"fog_light_color",
			Color(0.48, 0.53, 0.56)
		)


func _set_if_available(
	object: Object,
	property_name: StringName,
	value: Variant
) -> void:
	if object == null:
		return
	for property_data: Dictionary in object.get_property_list():
		if StringName(property_data.get("name", "")) == property_name:
			object.set(property_name, value)
			return
