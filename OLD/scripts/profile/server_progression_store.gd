extends RefCounted
class_name ServerProgressionStore

const PATH := "user://frontline_server_progression.cfg"
const EMPTY := {
	"name": "Soldier",
	"matches": 0,
	"wins": 0,
	"losses": 0,
	"kills": 0,
	"deaths": 0,
	"assists": 0,
	"objective": 0,
	"xp": 0,
	"best_round_xp": 0
}

var records: Dictionary = {}

func load_database() -> void:
	records.clear()
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	for section_id in config.get_sections():
		if not section_id.begins_with("player:"):
			continue
		var player_id := section_id.trim_prefix("player:")
		var record := EMPTY.duplicate(true)
		for field_id in EMPTY:
			record[field_id] = config.get_value(
				section_id,
				field_id,
				EMPTY[field_id]
			)
		records[player_id] = _sanitize(record)

func save_database() -> Error:
	var config := ConfigFile.new()
	config.set_value(
		"meta",
		"saved_unix",
		int(Time.get_unix_time_from_system())
	)
	for player_id in records:
		var section_id := "player:%s" % str(player_id)
		var record: Dictionary = _sanitize(
			Dictionary(records[player_id])
		)
		for field_id in record:
			config.set_value(
				section_id,
				field_id,
				record[field_id]
			)
	return config.save(PATH)

func record_for(player_id: String) -> Dictionary:
	var safe_id := _safe_id(player_id)
	if safe_id.is_empty():
		return EMPTY.duplicate(true)
	if not records.has(safe_id):
		records[safe_id] = EMPTY.duplicate(true)
	return Dictionary(records[safe_id]).duplicate(true)

func commit(
	player_id: String,
	display_name: String,
	stats: Dictionary,
	won: bool
) -> Dictionary:
	var safe_id := _safe_id(player_id)
	if safe_id.is_empty():
		return EMPTY.duplicate(true)
	var record: Dictionary = record_for(safe_id)
	record["name"] = display_name.substr(0,20)
	record["matches"] = int(record["matches"]) + 1
	record["wins"] = int(record["wins"]) + (1 if won else 0)
	record["losses"] = int(record["losses"]) + (0 if won else 1)
	record["kills"] += maxi(0,int(stats.get("kills",0)))
	record["deaths"] += maxi(0,int(stats.get("deaths",0)))
	record["assists"] += maxi(0,int(stats.get("assists",0)))
	record["objective"] += maxi(0,int(stats.get("objective",0)))
	var gained_xp := maxi(0,int(stats.get("xp",0)))
	record["xp"] += gained_xp
	record["best_round_xp"] = maxi(
		int(record["best_round_xp"]),
		gained_xp
	)
	records[safe_id] = _sanitize(record)
	save_database()
	return Dictionary(records[safe_id]).duplicate(true)

static func rank_name(xp: int) -> String:
	if xp >= 5000: return "Colonel"
	if xp >= 3000: return "Major"
	if xp >= 1800: return "Captain"
	if xp >= 1000: return "Lieutenant"
	if xp >= 500: return "Sergeant"
	if xp >= 200: return "Corporal"
	return "Recruit"

static func summary(record: Dictionary) -> String:
	var matches := int(record.get("matches",0))
	var wins := int(record.get("wins",0))
	var deaths := int(record.get("deaths",0))
	var win_rate := (
		float(wins) * 100.0 / float(matches)
		if matches > 0 else 0.0
	)
	var kd := (
		float(record.get("kills",0)) / float(deaths)
		if deaths > 0 else float(record.get("kills",0))
	)
	return (
		"%s · %d XP\n"
		+ "Matches %d · Wins %d · Losses %d · Win rate %.1f%%\n"
		+ "Kills %d · Deaths %d · Assists %d · K/D %.2f\n"
		+ "Objective %d · Best round %d XP"
	) % [
		rank_name(int(record.get("xp",0))),
		int(record.get("xp",0)),
		matches,
		wins,
		int(record.get("losses",0)),
		win_rate,
		int(record.get("kills",0)),
		deaths,
		int(record.get("assists",0)),
		kd,
		int(record.get("objective",0)),
		int(record.get("best_round_xp",0))
	]

static func _safe_id(raw_id: String) -> String:
	var safe := ""
	for character in raw_id.strip_edges():
		var code := character.unicode_at(0)
		if (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 70)
			or (code >= 97 and code <= 102)
		):
			safe += character
	return safe.substr(0,64) if safe.length() >= 16 else ""

static func _sanitize(raw: Dictionary) -> Dictionary:
	var result := EMPTY.duplicate(true)
	result["name"] = str(raw.get("name","Soldier")).substr(0,20)
	for field_id in [
		"matches","wins","losses","kills","deaths",
		"assists","objective","xp","best_round_xp"
	]:
		result[field_id] = maxi(0,int(raw.get(field_id,0)))
	return result
