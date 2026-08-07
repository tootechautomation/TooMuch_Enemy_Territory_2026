extends RefCounted
class_name PlayerProfile

const PROFILE_PATH := "user://frontline_profile.cfg"
const PROFILE_VERSION := 4

const DEFAULTS := {
	"player_name": "Soldier",
	"preferred_team": 0,
	"preferred_class": 0,
	"mouse_sensitivity": 0.0025,
	"field_of_view": 75.0,
	"hud_scale": 1.0,
	"master_volume": 0.85,
	"effects_volume": 0.90,
	"music_volume": 0.75,
	"last_server": "127.0.0.1",
	"last_port": 27960,
	"player_id": "",
	"recent_servers": [],
	"favorite_servers": [],
	"server_preferences": {},
	"keybindings": {},
	"match_history": []
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

	var identity := str(values.get("player_id", "")).strip_edges()
	if identity.length() < 16:
		identity = _generate_player_id()
	values["player_id"] = identity.substr(0, 64)

	values["recent_servers"] = _sanitize_server_list(
		values.get("recent_servers", [])
	)
	values["favorite_servers"] = _sanitize_server_list(
		values.get("favorite_servers", [])
	)
	values["server_preferences"] = (
		Dictionary(values.get("server_preferences", {}))
		if values.get("server_preferences", {}) is Dictionary
		else {}
	)
	values["keybindings"] = (
		Dictionary(values.get("keybindings", {}))
		if values.get("keybindings", {}) is Dictionary
		else {}
	)
	values["match_history"] = _sanitize_history(
		values.get("match_history", [])
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

func remember_server(
	address: String,
	port: int,
	favorite: bool = false
) -> Dictionary:
	var safe_address := address.strip_edges().substr(0, 128)
	var safe_port := clampi(port, 1, 65535)
	var entry := {
		"address": safe_address,
		"port": safe_port,
		"label": "%s:%d" % [safe_address, safe_port]
	}

	var recent: Array = Array(values.get("recent_servers", []))
	var rebuilt: Array = [entry]
	for existing_value in recent:
		if not existing_value is Dictionary:
			continue
		var existing: Dictionary = Dictionary(existing_value)
		if (
			str(existing.get("address", "")) == safe_address
			and int(existing.get("port", 0)) == safe_port
		):
			continue
		rebuilt.append(existing)
		if rebuilt.size() >= 10:
			break
	values["recent_servers"] = rebuilt

	if favorite:
		var favorites: Array = Array(
			values.get("favorite_servers", [])
		)
		var found := false
		for existing_value in favorites:
			if not existing_value is Dictionary:
				continue
			var existing: Dictionary = Dictionary(existing_value)
			if (
				str(existing.get("address", "")) == safe_address
				and int(existing.get("port", 0)) == safe_port
			):
				found = true
				break
		if not found:
			favorites.append(entry)
		values["favorite_servers"] = favorites

	save_profile()
	return values.duplicate(true)

func set_server_preference(
	address: String,
	port: int,
	team_id: int,
	class_id: int
) -> Dictionary:
	var preferences: Dictionary = Dictionary(
		values.get("server_preferences", {})
	)
	preferences["%s:%d" % [address, port]] = {
		"team": clampi(team_id, 0, 1),
		"class": clampi(class_id, 0, 4)
	}
	values["server_preferences"] = preferences
	save_profile()
	return values.duplicate(true)

func export_profile(destination_path: String) -> Error:
	return _save_to_path(destination_path)

func import_profile(source_path: String) -> Error:
	var config := ConfigFile.new()
	var error := config.load(source_path)
	if error != OK:
		return error
	var imported := DEFAULTS.duplicate(true)
	for profile_key in DEFAULTS:
		imported[profile_key] = config.get_value(
			"profile",
			profile_key,
			DEFAULTS[profile_key]
		)
	values = imported
	_sanitize_values()
	return save_profile()

func _save_to_path(destination_path: String) -> Error:
	_sanitize_values()
	var config := ConfigFile.new()
	config.set_value("meta", "version", PROFILE_VERSION)
	for profile_key in values:
		config.set_value("profile", profile_key, values[profile_key])
	return config.save(destination_path)

static func _generate_player_id() -> String:
	var crypto := Crypto.new()
	return crypto.generate_random_bytes(16).hex_encode()

static func _sanitize_server_list(raw_value: Variant) -> Array:
	var result: Array = []
	if not raw_value is Array:
		return result
	for raw_entry in raw_value:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = Dictionary(raw_entry)
		var address := str(
			entry.get("address", "")
		).strip_edges().substr(0, 128)
		if address.is_empty():
			continue
		var port := clampi(
			int(entry.get("port", 27960)),
			1,
			65535
		)
		result.append({
			"address": address,
			"port": port,
			"label": str(
				entry.get("label", "%s:%d" % [address, port])
			).substr(0, 160)
		})
		if result.size() >= 20:
			break
	return result

func append_match(summary: Dictionary) -> Dictionary:
	var history: Array = Array(values.get("match_history",[]))
	history.push_front({
		"server": str(summary.get("server","Frontline Server")).substr(0,160),
		"result": str(summary.get("result","Completed")).substr(0,80),
		"won": bool(summary.get("won",false)),
		"kills": maxi(0,int(summary.get("kills",0))),
		"deaths": maxi(0,int(summary.get("deaths",0))),
		"assists": maxi(0,int(summary.get("assists",0))),
		"objective": maxi(0,int(summary.get("objective",0))),
		"xp": maxi(0,int(summary.get("xp",0)))
	})
	while history.size() > 20:
		history.pop_back()
	values["match_history"] = history
	save_profile()
	return values.duplicate(true)

static func _sanitize_history(raw_value: Variant) -> Array:
	var result: Array = []
	if not raw_value is Array:
		return result
	for raw_entry in raw_value:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = Dictionary(raw_entry)
		result.append({
			"server": str(entry.get("server","Frontline Server")).substr(0,160),
			"result": str(entry.get("result","Completed")).substr(0,80),
			"won": bool(entry.get("won",false)),
			"kills": maxi(0,int(entry.get("kills",0))),
			"deaths": maxi(0,int(entry.get("deaths",0))),
			"assists": maxi(0,int(entry.get("assists",0))),
			"objective": maxi(0,int(entry.get("objective",0))),
			"xp": maxi(0,int(entry.get("xp",0)))
		})
		if result.size() >= 20:
			break
	return result
