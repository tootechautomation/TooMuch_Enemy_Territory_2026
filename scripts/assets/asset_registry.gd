extends RefCounted

const TEAM_ALLIES := 0
const TEAM_AXIS := 1
const SLOT_PRIMARY := 0
const SLOT_PISTOL := 1

const AXIS_MP40 := "res://assets/external/weapons/mp40/MP40.fbx"
const AXIS_P38 := "res://assets/external/weapons/p38/P38.fbx"

static func weapon_scene(team: int, slot: int) -> PackedScene:
	var path := ""
	if team == TEAM_AXIS and slot == SLOT_PRIMARY:
		path = AXIS_MP40
	elif team == TEAM_AXIS and slot == SLOT_PISTOL:
		path = AXIS_P38
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as PackedScene

static func available_character(_team: int) -> PackedScene:
	return null

static func character_config(_team: int) -> Dictionary:
	return {}

# Backward-compatible registry API used by the long-running v13-v22 codebase.
# v22.2 accidentally replaced the registry with a weapon-only subset; these methods
# restore the original call surface while leaving unavailable overlay assets on their
# established fallback paths.

static func grenade_scene(team: int) -> PackedScene:
	# Allied MK2 is loaded directly by grenade.gd. Axis Model 24 remains supplied
	# by the complete base project when present.
	var candidates: Array[String] = []
	if team == TEAM_AXIS:
		candidates = [
			"res://assets/external/weapons/model24_grenade.glb",
			"res://assets/external/weapons/model_24_grenade.glb",
			"res://assets/models/model24_grenade.glb"
		]
	else:
		candidates = [
			"res://assets/external/weapons/mk2_grenade.glb"
		]
	for path: String in candidates:
		if ResourceLoader.exists(path):
			return load(path) as PackedScene
	return null

static func environment_scene(asset_id: String) -> PackedScene:
	var candidates: Dictionary = {
		"city_ruins_environment": "res://assets/maps/ruined_city/city_ruins_environment.glb",
		"ww2_low_poly_city_scene": "res://assets/maps/ruined_city/ww2_low_poly_city_scene.glb",
		"mothecombe_pillbox": "res://assets/maps/ruined_city/mothecombe_pillbox.glb"
	}
	var path := str(candidates.get(asset_id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as PackedScene

static func environment_config(_asset_id: String) -> Dictionary:
	return {}

static func availability_report() -> Dictionary:
	return {
		"axis_mp40": ResourceLoader.exists(AXIS_MP40),
		"axis_p38": ResourceLoader.exists(AXIS_P38),
		"allied_mk2": ResourceLoader.exists(
			"res://assets/external/weapons/mk2_grenade.glb"
		)
	}

