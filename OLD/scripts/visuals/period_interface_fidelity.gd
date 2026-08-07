extends Node
class_name PeriodInterfaceFidelity

const STYLE_META := "frontline_period_ui_styled"

var scan_elapsed := 0.0
var panel_style: StyleBoxFlat
var panel_emphasis_style: StyleBoxFlat
var button_normal_style: StyleBoxFlat
var button_hover_style: StyleBoxFlat
var button_pressed_style: StyleBoxFlat
var line_edit_style: StyleBoxFlat
var bar_background_style: StyleBoxFlat
var bar_health_style: StyleBoxFlat
var bar_stamina_style: StyleBoxFlat
var bar_objective_style: StyleBoxFlat

func initialize() -> void:
	if DisplayServer.get_name() == "headless":
		queue_free()
		return
	_build_styles()
	_build_screen_finish()
	_style_new_controls()

func _process(delta: float) -> void:
	scan_elapsed += delta
	if scan_elapsed < 0.75:
		return
	scan_elapsed = 0.0
	_style_new_controls()

func _build_styles() -> void:
	panel_style = _flat_style(
		Color(0.055, 0.064, 0.060, 0.90),
		Color(0.30, 0.32, 0.27, 0.92),
		2,
		5
	)
	panel_emphasis_style = _flat_style(
		Color(0.085, 0.078, 0.058, 0.94),
		Color(0.66, 0.54, 0.27, 0.95),
		2,
		4
	)
	button_normal_style = _flat_style(
		Color(0.13, 0.145, 0.13, 0.98),
		Color(0.37, 0.39, 0.32, 1.0),
		2,
		4
	)
	button_hover_style = _flat_style(
		Color(0.24, 0.225, 0.17, 0.98),
		Color(0.78, 0.64, 0.30, 1.0),
		2,
		4
	)
	button_pressed_style = _flat_style(
		Color(0.34, 0.29, 0.17, 1.0),
		Color(0.92, 0.76, 0.36, 1.0),
		2,
		4
	)
	line_edit_style = _flat_style(
		Color(0.035, 0.042, 0.040, 0.98),
		Color(0.42, 0.43, 0.34, 1.0),
		2,
		3
	)
	bar_background_style = _flat_style(
		Color(0.025, 0.03, 0.028, 0.92),
		Color(0.22, 0.24, 0.21, 0.95),
		1,
		3
	)
	bar_health_style = _flat_style(Color(0.56, 0.12, 0.085, 0.98), Color(0.82, 0.28, 0.16, 1.0), 1, 3)
	bar_stamina_style = _flat_style(Color(0.64, 0.50, 0.12, 0.98), Color(0.90, 0.73, 0.27, 1.0), 1, 3)
	bar_objective_style = _flat_style(Color(0.18, 0.39, 0.58, 0.98), Color(0.35, 0.67, 0.86, 1.0), 1, 3)

func _flat_style(
	background: Color,
	border: Color,
	border_width: int,
	radius: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	return style

func _build_screen_finish() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PeriodScreenFinishLayer"
	layer.layer = 90
	add_child(layer)
	var finish := ColorRect.new()
	finish.name = "PeriodScreenFinish"
	finish.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	finish.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
	vec2 centered = SCREEN_UV * 2.0 - 1.0;
	float edge = smoothstep(0.54, 1.28, length(centered * vec2(0.82, 1.0)));
	float grain = hash(floor(SCREEN_UV * vec2(640.0, 360.0)) + floor(TIME * 12.0));
	float alpha = edge * 0.18 + (grain - 0.5) * 0.018;
	COLOR = vec4(0.035, 0.030, 0.022, clamp(alpha, 0.0, 0.21));
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	finish.material = material
	layer.add_child(finish)

func _style_new_controls() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	for node_value in scene_root.find_children("*", "Control", true, false):
		var control := node_value as Control
		if control == null or control.has_meta(STYLE_META):
			continue
		if control.name == "PeriodScreenFinish":
			control.set_meta(STYLE_META, true)
			continue
		_style_control(control)
		control.set_meta(STYLE_META, true)

func _style_control(control: Control) -> void:
	var lower_name := control.name.to_lower()
	if control is Panel or control is PanelContainer:
		var panel := control as Control
		var selected_style := panel_emphasis_style if _is_emphasis_panel(lower_name) else panel_style
		panel.add_theme_stylebox_override("panel", selected_style)
	elif control is Button:
		var button := control as Button
		button.add_theme_stylebox_override("normal", button_normal_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_stylebox_override("pressed", button_pressed_style)
		button.add_theme_stylebox_override("focus", button_hover_style)
		button.add_theme_color_override("font_color", Color(0.88, 0.86, 0.76))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.50))
		button.add_theme_font_size_override("font_size", 17)
	elif control is LineEdit:
		var edit := control as LineEdit
		edit.add_theme_stylebox_override("normal", line_edit_style)
		edit.add_theme_stylebox_override("focus", button_hover_style)
		edit.add_theme_color_override("font_color", Color(0.90, 0.88, 0.78))
		edit.add_theme_color_override("caret_color", Color(0.95, 0.72, 0.28))
	elif control is ProgressBar:
		_style_progress_bar(control as ProgressBar, lower_name)
	elif control is Label:
		var label := control as Label
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		if _is_title_label(lower_name):
			label.add_theme_color_override("font_color", Color(0.92, 0.79, 0.43))
			label.add_theme_font_size_override("font_size", maxi(label.get_theme_font_size("font_size"), 20))
	elif control is MarginContainer:
		control.add_theme_constant_override("margin_left", 6)
		control.add_theme_constant_override("margin_right", 6)
		control.add_theme_constant_override("margin_top", 5)
		control.add_theme_constant_override("margin_bottom", 5)

func _style_progress_bar(bar: ProgressBar, lower_name: String) -> void:
	bar.add_theme_stylebox_override("background", bar_background_style)
	var fill := bar_objective_style
	if "health" in lower_name or "hp" in lower_name:
		fill = bar_health_style
	elif "stamina" in lower_name or "ability" in lower_name:
		fill = bar_stamina_style
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_color_override("font_color", Color(0.94, 0.92, 0.83))
	bar.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.018))
	bar.add_theme_constant_override("outline_size", 2)

func _is_emphasis_panel(lower_name: String) -> bool:
	return (
		"objective" in lower_name
		or "spawn" in lower_name
		or "score" in lower_name
		or "round" in lower_name
		or "progression" in lower_name
	)

func _is_title_label(lower_name: String) -> bool:
	return (
		"title" in lower_name
		or "objective" in lower_name
		or "winner" in lower_name
		or "round" in lower_name
		or "operations" in lower_name
	)

