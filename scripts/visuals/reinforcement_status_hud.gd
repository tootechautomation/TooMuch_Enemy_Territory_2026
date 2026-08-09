extends CanvasLayer
class_name ReinforcementStatusHUD

var world_root: Node
var quality_manager: Node

var panel: PanelContainer
var label: Label
var refresh_accumulator := 0.0
var cinema_suppressed := false

const REFRESH_INTERVAL := 0.20

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	layer = 34
	_build_ui()
	_refresh()


func _process(delta: float) -> void:
	if world_root == null or panel == null:
		return

	var show: bool = _should_show()
	panel.visible = show
	if not show:
		return

	refresh_accumulator += delta
	if refresh_accumulator < REFRESH_INTERVAL:
		return
	refresh_accumulator = 0.0

	_refresh()


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "ReinforcementStatusPanel"
	panel.position = Vector2(18, 360)
	panel.custom_minimum_size = Vector2(300, 0)
	add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.035, 0.034, 0.62)
	style.border_color = Color(0.38, 0.42, 0.36, 0.45)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	label = Label.new()
	label.name = "ReinforcementStatusLabel"
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_constant_override("outline_size", 4)
	label.modulate = Color(0.84, 0.86, 0.79)
	margin.add_child(label)


func _refresh() -> void:
	if label == null:
		return

	var seconds := _wave_seconds()
	var local_team := _local_team_name()
	label.text = (
		"REINFORCEMENTS · %s · NEXT WAVE %ds"
		% [local_team, seconds]
	)


func _wave_seconds() -> int:
	var local_team := _local_team_id()

	if (
		local_team >= 0
		and world_root.has_method("team_spawn_wave_remaining")
	):
		return maxi(
			0,
			int(ceil(float(
				world_root.call(
					"team_spawn_wave_remaining",
					local_team
				)
			)))
		)

	for property_name: StringName in [
		&"spawn_wave_remaining",
		&"spawn_wave_seconds_remaining",
		&"next_spawn_wave_seconds"
	]:
		if _has_property(world_root, property_name):
			return maxi(
				0,
				int(ceil(float(world_root.get(property_name))))
			)

	var cadence := 10.0
	if _has_property(world_root, &"SPAWN_WAVE_SECONDS"):
		cadence = maxf(
			1.0,
			float(world_root.get("SPAWN_WAVE_SECONDS"))
		)

	var seconds := float(Time.get_ticks_msec()) / 1000.0
	return maxi(0, int(ceil(cadence - fmod(seconds, cadence))))


func _local_team_id() -> int:
	var players_value: Variant = world_root.get("players")
	if players_value is Dictionary:
		var players: Dictionary = players_value
		var player: Node = players.get(multiplayer.get_unique_id()) as Node
		if player != null:
			return clampi(int(player.get("team")), 0, 1)
	return -1


func _local_team_name() -> String:
	var team_id := _local_team_id()
	if team_id == 0:
		return "ALLIES"
	if team_id == 1:
		return "AXIS"
	return "TEAM"


func _should_show() -> bool:
	if cinema_suppressed:
		return false

	var players_value: Variant = world_root.get("players")
	if not players_value is Dictionary:
		return false

	var players: Dictionary = players_value
	if not players.has(multiplayer.get_unique_id()):
		return false

	# Hide while visible menu controls are present.
	for candidate: Node in world_root.find_children("*", "Control", true):
		if not candidate is CanvasItem:
			continue
		var key := candidate.name.to_lower()
		if (
			("server" in key and ("browser" in key or "connect" in key))
			or "profile" in key
			or "mainmenu" in key
		):
			if (candidate as CanvasItem).visible:
				return false

	return true


func set_cinema_suppressed(suppressed: bool) -> void:
	cinema_suppressed = suppressed
	if panel != null and suppressed:
		panel.visible = false


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
