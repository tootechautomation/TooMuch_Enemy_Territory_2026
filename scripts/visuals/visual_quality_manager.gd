extends Node
class_name VisualQualityManager

enum QualityPreset {
	LOW,
	BALANCED,
	HIGH
}

const SETTINGS_PATH := "user://frontline_visual_quality.cfg"

var world_root: Node
var current_preset: QualityPreset = QualityPreset.BALANCED
var status_label: Label

func initialize(root: Node) -> void:
	world_root = root
	_cache_original_render_state()
	_create_status_label()

	# Balanced is the safe default for normal laptops/non-gaming desktops.
	current_preset = _load_quality_preference()
	apply_quality(current_preset, false)


func cycle_quality() -> void:
	var next_value: int = (int(current_preset) + 1) % 3
	apply_quality(next_value as QualityPreset, true)


func set_quality(preset: int) -> void:
	apply_quality(
		clampi(preset, 0, 2) as QualityPreset,
		true
	)


func apply_quality(
	preset: QualityPreset,
	save_preference: bool = true
) -> void:
	if world_root == null:
		return

	current_preset = preset
	_apply_viewport_quality()
	_apply_environment_quality()
	_apply_particle_quality()
	_apply_light_quality()
	_apply_geometry_quality()
	_apply_optional_system_quality()
	_apply_local_effect_budgets()
	_update_status_label()

	if save_preference:
		_save_quality_preference()


func quality_name() -> String:
	match current_preset:
		QualityPreset.LOW:
			return "LOW / LAPTOP"
		QualityPreset.HIGH:
			return "HIGH"
		_:
			return "BALANCED"


func _apply_viewport_quality() -> void:
	var viewport := world_root.get_viewport()
	if viewport == null:
		return

	match current_preset:
		QualityPreset.LOW:
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = false
			_set_if_available(viewport, &"scaling_3d_scale", 0.72)

		QualityPreset.BALANCED:
			viewport.msaa_3d = Viewport.MSAA_2X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = false
			_set_if_available(viewport, &"scaling_3d_scale", 0.88)

		QualityPreset.HIGH:
			viewport.msaa_3d = Viewport.MSAA_4X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = true
			_set_if_available(viewport, &"scaling_3d_scale", 1.0)


func _apply_environment_quality() -> void:
	for value: Node in world_root.find_children(
		"*",
		"WorldEnvironment",
		true
	):
		var world_environment := value as WorldEnvironment
		if world_environment == null or world_environment.environment == null:
			continue

		var environment: Environment = world_environment.environment

		match current_preset:
			QualityPreset.LOW:
				_set_if_available(environment, &"ssao_enabled", false)
				_set_if_available(environment, &"ssil_enabled", false)
				_set_if_available(environment, &"glow_enabled", false)
				_set_if_available(environment, &"volumetric_fog_enabled", false)

			QualityPreset.BALANCED:
				_set_if_available(environment, &"ssao_enabled", true)
				_set_if_available(environment, &"ssao_radius", 1.45)
				_set_if_available(environment, &"ssao_intensity", 1.10)
				_set_if_available(environment, &"ssil_enabled", false)
				_set_if_available(environment, &"glow_enabled", true)
				_set_if_available(environment, &"glow_intensity", 0.30)
				_set_if_available(environment, &"volumetric_fog_enabled", false)

			QualityPreset.HIGH:
				_set_if_available(environment, &"ssao_enabled", true)
				_set_if_available(environment, &"ssao_radius", 2.15)
				_set_if_available(environment, &"ssao_intensity", 1.85)
				_set_if_available(environment, &"ssil_enabled", true)
				_set_if_available(environment, &"ssil_radius", 3.25)
				_set_if_available(environment, &"ssil_intensity", 0.82)
				_set_if_available(environment, &"glow_enabled", true)
				_set_if_available(environment, &"glow_intensity", 0.48)
				_set_if_available(environment, &"volumetric_fog_enabled", true)
				_set_if_available(environment, &"volumetric_fog_density", 0.014)


func _apply_particle_quality() -> void:
	for value: Node in world_root.find_children("*", "GPUParticles3D", true):
		var particles := value as GPUParticles3D
		if particles == null:
			continue

		var original_amount: int = int(
			particles.get_meta("v889_original_amount", particles.amount)
		)
		var original_lifetime: float = float(
			particles.get_meta("v889_original_lifetime", particles.lifetime)
		)

		match current_preset:
			QualityPreset.LOW:
				particles.amount = maxi(2, int(round(original_amount * 0.28)))
				particles.lifetime = original_lifetime * 0.72

			QualityPreset.BALANCED:
				particles.amount = maxi(3, int(round(original_amount * 0.58)))
				particles.lifetime = original_lifetime * 0.88

			QualityPreset.HIGH:
				particles.amount = original_amount
				particles.lifetime = original_lifetime


func _apply_light_quality() -> void:
	var shadow_budget: int = (
		2 if current_preset == QualityPreset.LOW
		else 7 if current_preset == QualityPreset.BALANCED
		else 999
	)
	var used_shadow_lights := 0

	for value: Node in world_root.find_children("*", "Light3D", true):
		var light := value as Light3D
		if light == null:
			continue

		var original_shadow: bool = bool(
			light.get_meta("v889_original_shadow", light.shadow_enabled)
		)
		var original_energy: float = float(
			light.get_meta("v889_original_energy", light.light_energy)
		)

		if current_preset == QualityPreset.HIGH:
			light.shadow_enabled = original_shadow
			light.light_energy = original_energy
			continue

		if current_preset == QualityPreset.BALANCED:
			light.light_energy = original_energy * 0.94
		else:
			light.light_energy = original_energy * 0.78

		if original_shadow and used_shadow_lights < shadow_budget:
			light.shadow_enabled = true
			used_shadow_lights += 1
		else:
			light.shadow_enabled = false


func _apply_geometry_quality() -> void:
	for value: Node in world_root.find_children("*", "GeometryInstance3D", true):
		var geometry := value as GeometryInstance3D
		if geometry == null:
			continue

		var original_end: float = float(
			geometry.get_meta(
				"v889_original_visibility_end",
				geometry.visibility_range_end
			)
		)
		var original_shadow: int = int(
			geometry.get_meta(
				"v889_original_shadow_setting",
				geometry.cast_shadow
			)
		)

		var key := geometry.name.to_lower()
		var is_microdetail := _matches_any(key, [
			"rubble", "debris", "paper", "shard", "scar",
			"chip", "seam", "rust", "grime", "fragment",
			"wetedge", "stone", "paver", "drainbar",
			"categorymarker", "groundring"
		])

		match current_preset:
			QualityPreset.LOW:
				if is_microdetail:
					geometry.visibility_range_end = (
						14.0
						if original_end <= 0.0
						else minf(original_end, 14.0)
					)
					geometry.cast_shadow = (
						GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					)
				else:
					geometry.visibility_range_end = (
						54.0
						if original_end <= 0.0
						else minf(original_end, 54.0)
					)

			QualityPreset.BALANCED:
				if is_microdetail:
					geometry.visibility_range_end = (
						24.0
						if original_end <= 0.0
						else minf(original_end, 24.0)
					)
					geometry.cast_shadow = (
						GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					)
				else:
					geometry.visibility_range_end = original_end
					geometry.cast_shadow = original_shadow

			QualityPreset.HIGH:
				geometry.visibility_range_end = original_end
				geometry.cast_shadow = original_shadow


func _apply_optional_system_quality() -> void:
	var expensive_low_only_disable := [
		"EnvironmentalAnimationPass_v876",
		"RainInteractionPass_v877"
	]

	for node_name: String in expensive_low_only_disable:
		var node := world_root.find_child(node_name, true, false)
		if node is Node3D:
			(node as Node3D).visible = current_preset != QualityPreset.LOW
		elif node != null:
			node.process_mode = (
				Node.PROCESS_MODE_DISABLED
				if current_preset == QualityPreset.LOW
				else Node.PROCESS_MODE_INHERIT
			)

	# Keep battlefield smoke in Low, but reduce secondary haze/dust systems.
	for value: Node in world_root.find_children("*", "GPUParticles3D", true):
		var particles := value as GPUParticles3D
		if particles == null:
			continue
		var key := particles.name.to_lower()

		if current_preset == QualityPreset.LOW:
			if (
				"dust" in key
				or "ember" in key
				or "splash" in key
				or "drip" in key
			):
				particles.emitting = false
			else:
				particles.emitting = true
		else:
			particles.emitting = true


func _apply_local_effect_budgets() -> void:
	# Shell casing budget added in v8.88.
	for value: Node in world_root.find_children(
		"WeaponHandlingFeedback",
		"",
		true
	):
		if current_preset == QualityPreset.LOW:
			value.set("max_casings", 4)
		elif current_preset == QualityPreset.BALANCED:
			value.set("max_casings", 8)
		else:
			value.set("max_casings", 14)


func _cache_original_render_state() -> void:
	for value: Node in world_root.find_children("*", "GPUParticles3D", true):
		var particles := value as GPUParticles3D
		if particles != null:
			particles.set_meta("v889_original_amount", particles.amount)
			particles.set_meta("v889_original_lifetime", particles.lifetime)

	for value: Node in world_root.find_children("*", "Light3D", true):
		var light := value as Light3D
		if light != null:
			light.set_meta("v889_original_shadow", light.shadow_enabled)
			light.set_meta("v889_original_energy", light.light_energy)

	for value: Node in world_root.find_children("*", "GeometryInstance3D", true):
		var geometry := value as GeometryInstance3D
		if geometry != null:
			geometry.set_meta(
				"v889_original_visibility_end",
				geometry.visibility_range_end
			)
			geometry.set_meta(
				"v889_original_shadow_setting",
				geometry.cast_shadow
			)


func _create_status_label() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var layer := CanvasLayer.new()
	layer.name = "VisualQualityOverlay"
	layer.layer = 90
	add_child(layer)

	status_label = Label.new()
	status_label.name = "VisualQualityStatus"
	status_label.position = Vector2(18, 18)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_constant_override("outline_size", 5)
	status_label.modulate = Color(0.92, 0.92, 0.88, 0.82)
	layer.add_child(status_label)


func _update_status_label() -> void:
	if status_label == null:
		return
	status_label.text = "VIDEO: %s  [F8]" % quality_name()


func _load_quality_preference() -> QualityPreset:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return QualityPreset.BALANCED

	var value: int = int(
		config.get_value("video", "quality", int(QualityPreset.BALANCED))
	)
	return clampi(value, 0, 2) as QualityPreset


func _save_quality_preference() -> void:
	var config := ConfigFile.new()
	config.set_value("video", "quality", int(current_preset))
	config.save(SETTINGS_PATH)


func _set_if_available(
	object: Object,
	property_name: StringName,
	value: Variant
) -> void:
	for property_data: Dictionary in object.get_property_list():
		if StringName(property_data.get("name", "")) == property_name:
			object.set(property_name, value)
			return


func _matches_any(text: String, patterns: Array) -> bool:
	for pattern_value: Variant in patterns:
		if str(pattern_value) in text:
			return true
	return false
