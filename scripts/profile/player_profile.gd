extends RefCounted
class_name PlayerProfile

const PROFILE_PATH := "user://frontline_profile.cfg"
const PROFILE_VERSION := 1

const DEFAULTS := {
	"player_name": "Soldier",
	"preferred_team": 0,
	"preferred_class": 0,
	"mouse_sensitivity": 0.0025,
	"field_of_view": 75.0,
	"hud_scale": 1.0,
	"master_volume": 0.85,
	"effects_volume": 0.90,
	"music_volume": 0.65,
	"last_server": "127.0.0.1",
	"last_port": 27960
}

var values: Dictionary = DEFAULTS.duplicate(true)

func load_profile() -> Dictionary:
	var config := ConfigFile.new()
	var error: Error = config.load(PROFILE_PATH)
	if error != OK:
		values = DEFAULTS.duplicate(true)
		save_profile()
		return values.duplicate(true)

	values = DEFAULTS.duplicate(true)
	for key in DEFAULTS:
		values[key] = config.get_value(
			"profile",
			key,
			DEFAULTS[key]
		)

	_sanitize_values()
	return values.duplicate(true)

func save_profile() -> Error:
	_sanitize_values()
	var config := ConfigFile.new()
	config.set_value("meta", "version", PROFILE_VERSION)
	for key in values:
		config.set_value("profile", key, values[key])
	return config.save(PROFILE_PATH)

func update(new_values: Dictionary) -> Dictionary:
	for key in new_values:
		if DEFAULTS.has(key):
			values[key] = new_values[key]
	_sanitize_values()
	save_profile()
	return values.duplicate(true)

func get_values() -> Dictionary:
	return values.duplicate(true)

func _sanitize_values() -> void:
	values["player_name"] = sanitize_player_name(
		str(values.get("player_name", "Soldier"))
	)
	values["preferred_team"] = clampi(
		int(values.get("preferred_team", 0)),
		0,
		1
	)
	values["preferred_class"] = clampi(
		int(values.get("preferred_class", 0)),
		0,
		4
	)
	values["mouse_sensitivity"] = clampf(
		float(values.get("mouse_sensitivity", 0.0025)),
		0.0005,
		0.0100
	)
	values["field_of_view"] = clampf(
		float(values.get("field_of_view", 75.0)),
		60.0,
		110.0
	)
	values["hud_scale"] = clampf(
		float(values.get("hud_scale", 1.0)),
		0.70,
		1.40
	)
	for volume_key in [
		"master_volume",
		"effects_volume",
		"music_volume"
	]:
		values[volume_key] = clampf(
			float(values.get(volume_key, DEFAULTS[volume_key])),
			0.0,
			1.0
		)
	values["last_server"] = str(
		values.get("last_server", "127.0.0.1")
	).strip_edges().substr(0, 128)
	values["last_port"] = clampi(
		int(values.get("last_port", 27960)),
		1,
		65535
	)

static func sanitize_player_name(raw_name: String) -> String:
	var cleaned := raw_name.strip_edges()
	var result := ""
	for character in cleaned:
		var code: int = character.unicode_at(0)
		var allowed := (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 90)
			or (code >= 97 and code <= 122)
			or character in [" ", "_", "-", ".", "[", "]"]
		)
		if allowed:
			result += character
		if result.length() >= 20:
			break

	result = result.strip_edges()
	if result.length() < 2:
		return "Soldier"
	return result
