extends RefCounted
class_name InputBindingManager

const SUPPORTED_ACTIONS := {
	"move_forward": {"label": "Move forward", "default": KEY_W},
	"move_back": {"label": "Move backward", "default": KEY_S},
	"move_left": {"label": "Move left", "default": KEY_A},
	"move_right": {"label": "Move right", "default": KEY_D},
	"jump": {"label": "Jump", "default": KEY_SPACE},
	"sprint": {"label": "Sprint", "default": KEY_SHIFT},
	"crouch": {"label": "Crouch", "default": KEY_C},
	"reload": {"label": "Reload", "default": KEY_R},
	"interact": {"label": "Interact", "default": KEY_E},
	"ability": {"label": "Class ability", "default": KEY_Q},
	"throw_grenade": {"label": "Throw grenade", "default": KEY_G},
	"tactical_map": {"label": "Tactical map", "default": KEY_K},
	"scoreboard": {"label": "Scoreboard", "default": KEY_TAB},
	"spawn_menu": {"label": "Team/class menu", "default": KEY_M},
	"profile_settings": {"label": "Player settings", "default": KEY_F8}
}

static func default_bindings() -> Dictionary:
	var result := {}
	for action_id in SUPPORTED_ACTIONS:
		result[action_id] = int(
			SUPPORTED_ACTIONS[action_id]["default"]
		)
	return result

static func sanitize_bindings(raw_bindings: Variant) -> Dictionary:
	var result := default_bindings()
	if raw_bindings is Dictionary:
		for action_id in SUPPORTED_ACTIONS:
			if raw_bindings.has(action_id):
				var key_code := int(raw_bindings[action_id])
				if key_code > 0:
					result[action_id] = key_code
	return result

static func apply_bindings(bindings: Dictionary) -> void:
	var safe_bindings := sanitize_bindings(bindings)
	for action_id in SUPPORTED_ACTIONS:
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)

		var non_keyboard_events: Array[InputEvent] = []
		for event_value in InputMap.action_get_events(action_id):
			if not event_value is InputEventKey:
				non_keyboard_events.append(event_value)

		InputMap.action_erase_events(action_id)
		for event_value in non_keyboard_events:
			InputMap.action_add_event(action_id, event_value)

		var key_event := InputEventKey.new()
		key_event.physical_keycode = int(safe_bindings[action_id])
		InputMap.action_add_event(action_id, key_event)

static func key_name(key_code: int) -> String:
	return (
		OS.get_keycode_string(key_code)
		if key_code > 0
		else "Unbound"
	)

static func action_label(action_id: String) -> String:
	return str(
		SUPPORTED_ACTIONS.get(
			action_id,
			{"label": action_id}
		)["label"]
	)
