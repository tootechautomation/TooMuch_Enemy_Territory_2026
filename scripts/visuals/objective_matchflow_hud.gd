extends CanvasLayer
class_name ObjectiveMatchflowHUD

var world_root: Node
var quality_manager: Node

var panel: PanelContainer
var objective_label: Label
var detail_label: Label
var tickets_label: Label
var wave_label: Label
var event_label: Label

var refresh_accumulator := 0.0
var last_summary := ""
var event_until_ms := 0

const REFRESH_INTERVAL := 0.15

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	layer = 35
	_build_ui()
	_refresh()


func _process(delta: float) -> void:
	if world_root == null:
		return

	refresh_accumulator += delta
	if refresh_accumulator >= REFRESH_INTERVAL:
		refresh_accumulator = 0.0
		_refresh()

	if event_label != null and event_label.visible:
		if Time.get_ticks_msec() >= event_until_ms:
			event_label.visible = false


func show_event(text: String, duration_seconds: float = 2.4) -> void:
	if event_label == null:
		return
	event_label.text = text
	event_label.visible = true
	event_until_ms = Time.get_ticks_msec() + int(duration_seconds * 1000.0)


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "ObjectiveMatchflowPanel"
	panel.position = Vector2(18, 54)
	panel.custom_minimum_size = Vector2(330, 0)
	add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.040, 0.038, 0.70)
	style.border_color = Color(0.60, 0.55, 0.38, 0.55)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	margin.add_child(stack)

	objective_label = Label.new()
	objective_label.name = "ObjectiveTitle"
	objective_label.add_theme_font_size_override("font_size", 18)
	objective_label.add_theme_constant_override("outline_size", 5)
	objective_label.modulate = Color(0.94, 0.90, 0.72)
	stack.add_child(objective_label)

	detail_label = Label.new()
	detail_label.name = "ObjectiveDetail"
	detail_label.add_theme_font_size_override("font_size", 14)
	detail_label.add_theme_constant_override("outline_size", 4)
	detail_label.modulate = Color(0.88, 0.88, 0.83)
	stack.add_child(detail_label)

	tickets_label = Label.new()
	tickets_label.name = "TicketStatus"
	tickets_label.add_theme_font_size_override("font_size", 14)
	tickets_label.add_theme_constant_override("outline_size", 4)
	tickets_label.modulate = Color(0.82, 0.84, 0.80)
	stack.add_child(tickets_label)

	wave_label = Label.new()
	wave_label.name = "SpawnWaveStatus"
	wave_label.add_theme_font_size_override("font_size", 14)
	wave_label.add_theme_constant_override("outline_size", 4)
	wave_label.modulate = Color(0.82, 0.84, 0.80)
	stack.add_child(wave_label)

	event_label = Label.new()
	event_label.name = "ObjectiveEventBanner"
	event_label.position = Vector2(0, 122)
	event_label.custom_minimum_size = Vector2(330, 36)
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_label.add_theme_font_size_override("font_size", 20)
	event_label.add_theme_constant_override("outline_size", 7)
	event_label.modulate = Color(1.0, 0.78, 0.30)
	event_label.visible = false
	add_child(event_label)


func _refresh() -> void:
	if world_root == null:
		return

	var summary := _objective_summary()
	objective_label.text = summary.get("title", "OBJECTIVE")
	detail_label.text = summary.get("detail", "")
	tickets_label.text = _ticket_text()
	wave_label.text = _wave_text()

	var combined := "%s|%s" % [objective_label.text, detail_label.text]
	if last_summary != "" and combined != last_summary:
		show_event(objective_label.text, 2.0)
	last_summary = combined

	_apply_quality_visibility()


func _objective_summary() -> Dictionary:
	var depot_contested := bool(
		world_root.get("supply_depot_contested")
	)
	var depot_progress := float(
		world_root.get("supply_depot_progress")
	)
	var depot_control := int(
		world_root.get("supply_depot_control")
	)

	var cp_contested := false
	var cp_progress := 0.0
	var cp_control := -1

	if _has_property(world_root, &"command_post_contested"):
		cp_contested = bool(world_root.get("command_post_contested"))
	if _has_property(world_root, &"command_post_progress"):
		cp_progress = float(world_root.get("command_post_progress"))
	if _has_property(world_root, &"command_post_control"):
		cp_control = int(world_root.get("command_post_control"))

	# Contested state always has priority.
	if cp_contested:
		return {
			"title": "COMMAND POST · CONTESTED",
			"detail": "Capture progress %d%%" % int(round(cp_progress * 100.0))
		}

	if depot_contested:
		return {
			"title": "SUPPLY DEPOT · CONTESTED",
			"detail": "Capture progress %d%%" % int(round(depot_progress * 100.0))
		}

	# If either neutral/capturable point is unresolved, show it as the next task.
	if cp_control < 0:
		return {
			"title": "OBJECTIVE · COMMAND POST",
			"detail": "Secure the command position"
		}

	if depot_control < 0:
		return {
			"title": "OBJECTIVE · SUPPLY DEPOT",
			"detail": "Capture the supply position"
		}

	var banner := ""
	if _has_property(world_root, &"mission_banner_text"):
		banner = str(world_root.get("mission_banner_text"))

	if not banner.is_empty():
		return {
			"title": banner.to_upper(),
			"detail": "Maintain pressure on the objective"
		}

	return {
		"title": "OBJECTIVE · HOLD THE LINE",
		"detail": "Defend captured positions and reduce enemy tickets"
	}


func _ticket_text() -> String:
	var allies := _get_int_from_candidates([
		"allied_tickets",
		"team_0_tickets",
		"attackers_tickets"
	], -1)
	var axis := _get_int_from_candidates([
		"axis_tickets",
		"team_1_tickets",
		"defenders_tickets"
	], -1)

	if allies >= 0 and axis >= 0:
		return "TICKETS   ALLIES %d   ·   AXIS %d" % [allies, axis]

	var ticket_variant: Variant = world_root.get("team_tickets")
	if ticket_variant is Dictionary:
		var tickets: Dictionary = ticket_variant
		return "TICKETS   ALLIES %d   ·   AXIS %d" % [
			int(tickets.get(0, 0)),
			int(tickets.get(1, 0))
		]

	return "TICKETS · MATCH ACTIVE"


func _wave_text() -> String:
	var wave_seconds := _find_wave_seconds()
	if wave_seconds >= 0:
		return "NEXT SPAWN WAVE · %ds" % wave_seconds
	return "SPAWN WAVES ACTIVE"


func _find_wave_seconds() -> int:
	for property_name: StringName in [
		&"spawn_wave_remaining",
		&"spawn_wave_seconds_remaining",
		&"next_spawn_wave_seconds"
	]:
		if _has_property(world_root, property_name):
			return maxi(0, int(ceil(float(world_root.get(property_name)))))

	# Fallback: derive from the global wave cadence. This does not alter spawning;
	# it only gives the player a useful approximate visual countdown.
	var cadence := 10.0
	if _has_property(world_root, &"SPAWN_WAVE_SECONDS"):
		cadence = maxf(1.0, float(world_root.get("SPAWN_WAVE_SECONDS")))

	var seconds := float(Time.get_ticks_msec()) / 1000.0
	var remaining := cadence - fmod(seconds, cadence)
	return maxi(0, int(ceil(remaining)))


func _apply_quality_visibility() -> void:
	if quality_manager == null or panel == null:
		return

	var preset := clampi(
		int(quality_manager.get("current_preset")),
		0,
		2
	)

	# The HUD is intentionally cheap. Low only makes it slightly more compact.
	panel.modulate.a = 0.88 if preset == 0 else 1.0


func _get_int_from_candidates(
	names: Array,
	fallback: int
) -> int:
	for value: Variant in names:
		var property_name := StringName(str(value))
		if _has_property(world_root, property_name):
			return int(world_root.get(property_name))
	return fallback


func _has_property(
	object: Object,
	property_name: StringName
) -> bool:
	if object == null:
		return false
	for property_data: Dictionary in object.get_property_list():
		if StringName(property_data.get("name", "")) == property_name:
			return true
	return false
