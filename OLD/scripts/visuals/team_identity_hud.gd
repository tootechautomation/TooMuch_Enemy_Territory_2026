extends Node
class_name TeamIdentityHUD

const ATTACKER_COLOR := Color(0.16, 0.43, 0.92)
const DEFENDER_COLOR := Color(0.88, 0.20, 0.12)

var identity_panel: PanelContainer
var identity_label: Label
var left_edge: ColorRect
var right_edge: ColorRect
var deployment_panel: PanelContainer
var deployment_label: Label
var deployment_tween: Tween
var last_team := -1
var last_stage := -1
var last_deployed := false

func initialize() -> void:
	if DisplayServer.get_name() == "headless":
		queue_free()
		return
	_build_identity_panel()
	_build_edge_accents()
	_build_deployment_announcement()

func update_identity(
	team_id: int,
	class_label: String,
	objective_stage: int,
	has_deployed: bool
) -> void:
	var safe_team := clampi(team_id, 0, 1)
	var safe_stage := maxi(0, objective_stage)
	var changed := safe_team != last_team or safe_stage != last_stage
	var just_deployed := has_deployed and not last_deployed
	var team_changed := safe_team != last_team
	last_team = safe_team
	last_stage = safe_stage
	last_deployed = has_deployed
	if changed:
		_refresh_panel(safe_team, class_label, safe_stage)
	if has_deployed and (just_deployed or team_changed):
		_show_deployment_announcement(safe_team)
	if identity_panel != null:
		identity_panel.visible = has_deployed
	if left_edge != null:
		left_edge.visible = has_deployed
	if right_edge != null:
		right_edge.visible = has_deployed

func _build_identity_panel() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TeamIdentityLayer"
	layer.layer = 42
	add_child(layer)
	identity_panel = PanelContainer.new()
	identity_panel.name = "PersistentTeamIdentityPanel"
	identity_panel.set_meta("frontline_period_ui_styled", true)
	identity_panel.position = Vector2(18.0, 92.0)
	identity_panel.custom_minimum_size = Vector2(265.0, 88.0)
	identity_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity_panel.visible = false
	layer.add_child(identity_panel)
	identity_label = Label.new()
	identity_label.name = "PersistentTeamIdentityLabel"
	identity_label.add_theme_font_size_override("font_size", 17)
	identity_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	identity_label.add_theme_constant_override("shadow_offset_x", 2)
	identity_label.add_theme_constant_override("shadow_offset_y", 2)
	identity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity_panel.add_child(identity_label)

func _build_edge_accents() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TeamEdgeAccentLayer"
	layer.layer = 41
	add_child(layer)
	left_edge = ColorRect.new()
	left_edge.name = "TeamAccentLeft"
	left_edge.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	left_edge.custom_minimum_size.x = 7.0
	left_edge.offset_right = 7.0
	left_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_edge.visible = false
	layer.add_child(left_edge)
	right_edge = ColorRect.new()
	right_edge.name = "TeamAccentRight"
	right_edge.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	right_edge.custom_minimum_size.x = 7.0
	right_edge.offset_left = -7.0
	right_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_edge.visible = false
	layer.add_child(right_edge)

func _build_deployment_announcement() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TeamDeploymentAnnouncementLayer"
	layer.layer = 105
	add_child(layer)
	deployment_panel = PanelContainer.new()
	deployment_panel.name = "TeamDeploymentAnnouncement"
	deployment_panel.set_meta("frontline_period_ui_styled", true)
	deployment_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	deployment_panel.position = Vector2(-260.0, 112.0)
	deployment_panel.custom_minimum_size = Vector2(520.0, 112.0)
	deployment_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deployment_panel.modulate.a = 0.0
	layer.add_child(deployment_panel)
	deployment_label = Label.new()
	deployment_label.name = "TeamDeploymentAnnouncementLabel"
	deployment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deployment_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	deployment_label.add_theme_font_size_override("font_size", 25)
	deployment_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
	deployment_label.add_theme_constant_override("shadow_offset_x", 3)
	deployment_label.add_theme_constant_override("shadow_offset_y", 3)
	deployment_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deployment_panel.add_child(deployment_label)

func _refresh_panel(team_id: int, class_label: String, stage: int) -> void:
	if identity_panel == null or identity_label == null:
		return
	var color := ATTACKER_COLOR if team_id == 0 else DEFENDER_COLOR
	var team_text := "ATTACKERS" if team_id == 0 else "DEFENDERS"
	var order_text := _order_text(team_id, stage)
	identity_label.text = "%s  ◆  %s\n%s\nTEAM COLOR: %s" % [
		team_text,
		class_label.to_upper(),
		order_text,
		"BLUE" if team_id == 0 else "RED"
	]
	identity_label.add_theme_color_override("font_color", color.lightened(0.28))
	identity_panel.add_theme_stylebox_override("panel", _panel_style(color))
	left_edge.color = Color(color.r, color.g, color.b, 0.34)
	right_edge.color = Color(color.r, color.g, color.b, 0.34)

func _order_text(team_id: int, stage: int) -> String:
	if team_id == 0:
		return "ORDER: BUILD THE BRIDGE" if stage == 0 else "ORDER: DESTROY THE BUNKER"
	return "ORDER: STOP THE BRIDGE" if stage == 0 else "ORDER: DEFEND THE BUNKER"

func _show_deployment_announcement(team_id: int) -> void:
	if deployment_panel == null or deployment_label == null:
		return
	var color := ATTACKER_COLOR if team_id == 0 else DEFENDER_COLOR
	deployment_label.text = (
		"YOU ARE AN ATTACKER\nADVANCE · BUILD · DESTROY"
		if team_id == 0
		else "YOU ARE A DEFENDER\nHOLD · DENY · PROTECT"
	)
	deployment_label.add_theme_color_override("font_color", color.lightened(0.28))
	deployment_panel.add_theme_stylebox_override("panel", _panel_style(color))
	if deployment_tween != null and deployment_tween.is_valid():
		deployment_tween.kill()
	deployment_panel.modulate.a = 0.0
	deployment_tween = create_tween()
	deployment_tween.tween_property(deployment_panel, "modulate:a", 1.0, 0.22)
	deployment_tween.tween_interval(2.6)
	deployment_tween.tween_property(deployment_panel, "modulate:a", 0.0, 0.55)

func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.040, 0.038, 0.92)
	style.border_color = Color(color.r, color.g, color.b, 0.96)
	style.border_width_left = 6
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 14.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
