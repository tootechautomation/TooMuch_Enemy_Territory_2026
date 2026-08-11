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
