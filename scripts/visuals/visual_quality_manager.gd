extends Node
class_name VisualQualityManager

enum QualityMode {
	AUTO,
	CINEMATIC,
	HIGH,
	BALANCED,
	PERFORMANCE
}

const CONFIG_PATH := "user://frontline_graphics.cfg"
const MODE_NAMES: Array[String] = ["AUTO", "CINEMATIC", "HIGH", "BALANCED", "PERFORMANCE"]

var world_root: Node
var selected_mode: int = QualityMode.AUTO
var active_tier: int = QualityMode.CINEMATIC
var low_fps_elapsed: float = 0.0
var high_fps_elapsed: float = 0.0
var sample_elapsed: float = 0.0
var status_label: Label
var status_tween: Tween

func initialize(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		queue_free()
		return
	world_root = root
	_load_selection()
	_build_status()
	if selected_mode == QualityMode.AUTO:
		active_tier = QualityMode.CINEMATIC
	else:
		active_tier = selected_mode
	call_deferred("_apply_active_tier", true)

func _process(delta: float) -> void:
	if selected_mode != QualityMode.AUTO:
		return
	sample_elapsed += delta
	if sample_elapsed < 1.0:
		return
	sample_elapsed = 0.0
	var fps: float = float(Engine.get_frames_per_second())
	if fps < 43.0:
		low_fps_elapsed += 1.0
		high_fps_elapsed = 0.0
	elif fps > 57.0:
		high_fps_elapsed += 1.0
		low_fps_elapsed = maxf(0.0, low_fps_elapsed - 1.0)
	else:
		low_fps_elapsed = maxf(0.0, low_fps_elapsed - 0.5)
		high_fps_elapsed = maxf(0.0, high_fps_elapsed - 0.5)
	if low_fps_elapsed >= 8.0 and active_tier < QualityMode.PERFORMANCE:
		active_tier += 1
		low_fps_elapsed = 0.0
		high_fps_elapsed = 0.0
		_apply_active_tier(true)
	elif high_fps_elapsed >= 20.0 and active_tier > QualityMode.CINEMATIC:
		active_tier -= 1
		low_fps_elapsed = 0.0
		high_fps_elapsed = 0.0
		_apply_active_tier(true)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.physical_keycode != KEY_F6:
		return
	selected_mode = (selected_mode + 1) % QualityMode.size()
	active_tier = QualityMode.CINEMATIC if selected_mode == QualityMode.AUTO else selected_mode
	low_fps_elapsed = 0.0
	high_fps_elapsed = 0.0
	_save_selection()
	_apply_active_tier(true)
	get_viewport().set_input_as_handled()

func _apply_active_tier(show_status: bool = false) -> void:
	if world_root == null:
		return
	_apply_viewport_quality()
	_apply_environment_quality()
	_apply_shadow_quality()
	_apply_effect_visibility()
	if show_status:
		_show_status()

func _apply_viewport_quality() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	match active_tier:
		QualityMode.CINEMATIC:
			viewport.msaa_3d = Viewport.MSAA_4X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = true
		QualityMode.HIGH:
			viewport.msaa_3d = Viewport.MSAA_2X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = true
		QualityMode.BALANCED:
			viewport.msaa_3d = Viewport.MSAA_2X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = false
		_:
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			viewport.use_taa = false

func _apply_environment_quality() -> void:
	for node_value in world_root.find_children("*", "WorldEnvironment", true, false):
		var world_environment := node_value as WorldEnvironment
		if world_environment == null or world_environment.environment == null:
			continue
		var environment: Environment = world_environment.environment
		environment.ssao_enabled = active_tier <= QualityMode.BALANCED
		environment.ssil_enabled = active_tier <= QualityMode.HIGH
		environment.glow_enabled = active_tier <= QualityMode.BALANCED
		environment.volumetric_fog_enabled = active_tier <= QualityMode.HIGH
		match active_tier:
			QualityMode.CINEMATIC:
				environment.ssao_radius = 2.3
				environment.ssao_intensity = 2.35
			QualityMode.HIGH:
				environment.ssao_radius = 2.2
				environment.ssao_intensity = 1.65
			QualityMode.BALANCED:
				environment.ssao_radius = 1.7
				environment.ssao_intensity = 1.25
			_:
				environment.ssao_enabled = false

func _apply_shadow_quality() -> void:
	for node_value in world_root.find_children("*", "DirectionalLight3D", true, false):
		var light := node_value as DirectionalLight3D
		if light == null:
			continue
		light.shadow_enabled = active_tier != QualityMode.PERFORMANCE
		match active_tier:
			QualityMode.CINEMATIC:
				light.directional_shadow_max_distance = 145.0
			QualityMode.HIGH:
				light.directional_shadow_max_distance = 95.0
			QualityMode.BALANCED:
				light.directional_shadow_max_distance = 68.0
			_:
				light.directional_shadow_max_distance = 42.0

func _apply_effect_visibility() -> void:
	var hide_balanced: Array[String] = [
		"WetGroundMist",
		"AirborneDust",
		"MovingOvercastLayer_2"
	]
	var hide_performance: Array[String] = [
		"WetGroundMist",
		"RainImpactSplashes",
		"AirborneDust",
		"MovingOvercastLayer_1",
		"MovingOvercastLayer_2",
		"BattlefieldSmoke",
		"CombatEmbers"
	]
	var optional_effect_names: Array[String] = hide_balanced + hide_performance
	for node_value in world_root.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node_value as GeometryInstance3D
		if geometry == null:
			continue
		if geometry.name not in optional_effect_names:
			continue
		var should_show: bool = true
		if active_tier == QualityMode.BALANCED:
			should_show = geometry.name not in hide_balanced
		elif active_tier == QualityMode.PERFORMANCE:
			should_show = geometry.name not in hide_performance
		geometry.visible = should_show
	for node_value in world_root.find_children("*", "GPUParticles3D", true, false):
		var particles := node_value as GPUParticles3D
		if particles == null:
			continue
		if particles.name not in optional_effect_names:
			continue
		if particles.name in hide_performance and active_tier == QualityMode.PERFORMANCE:
			particles.visible = false
		elif particles.name in hide_balanced and active_tier == QualityMode.BALANCED:
			particles.visible = false
		else:
			particles.visible = true

func _build_status() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GraphicsQualityStatusLayer"
	layer.layer = 110
	add_child(layer)
	status_label = Label.new()
	status_label.name = "GraphicsQualityStatus"
	status_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	status_label.position = Vector2(-180.0, 34.0)
	status_label.custom_minimum_size = Vector2(360.0, 42.0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.94, 0.82, 0.46))
	status_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	status_label.add_theme_constant_override("shadow_offset_x", 2)
	status_label.add_theme_constant_override("shadow_offset_y", 2)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.modulate.a = 0.0
	layer.add_child(status_label)

func _show_status() -> void:
	if status_label == null:
		return
	var mode_text: String = str(MODE_NAMES[selected_mode])
	var tier_text: String = str(MODE_NAMES[active_tier])
	status_label.text = (
		"GRAPHICS: %s (%s)  ·  F6 TO CHANGE"
		% [mode_text, tier_text]
		if selected_mode == QualityMode.AUTO
		else "GRAPHICS: %s  ·  F6 TO CHANGE" % mode_text
	)
	if status_tween != null and status_tween.is_valid():
		status_tween.kill()
	status_label.modulate.a = 1.0
	status_tween = create_tween()
	status_tween.tween_interval(2.3)
	status_tween.tween_property(status_label, "modulate:a", 0.0, 0.55)

func _load_selection() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		selected_mode = QualityMode.AUTO
		return
	selected_mode = clampi(int(config.get_value("graphics", "quality_mode", QualityMode.AUTO)), QualityMode.AUTO, QualityMode.PERFORMANCE)

func _save_selection() -> void:
	var config := ConfigFile.new()
	config.set_value("graphics", "quality_mode", selected_mode)
	config.save(CONFIG_PATH)
