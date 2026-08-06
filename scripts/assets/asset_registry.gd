extends RefCounted
class_name ExternalAssetRegistry

const CHARACTER_ALLIED := (
	"res://assets/external/characters/allied_soldier.glb"
)
const CHARACTER_AXIS := (
	"res://assets/external/characters/axis_soldier.glb"
)

const CHARACTER_CONFIG := {
	0: {
		"scale": Vector3.ONE,
		"rotation_y": 0.0,
		"offset": Vector3(0.0, -1.0, 0.0)
	},
	1: {
		"scale": Vector3.ONE,
		"rotation_y": 0.0,
		"offset": Vector3(0.0, -1.0, 0.0)
	}
}

const WEAPON_PATHS := {
	"allied_primary": (
		"res://assets/external/weapons/allied_rifle.glb"
	),
	"axis_primary": (
		"res://assets/external/weapons/axis_rifle.glb"
	),
	"service_pistol": (
		"res://assets/external/weapons/service_pistol.glb"
	)
}

const ENVIRONMENT_CONFIG := {
	"village_house_a": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"TownhouseVisualA",
			"TownhouseAVisual",
			"VisualTownhouseA"
		]
	},
	"village_house_b": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"TownhouseVisualB",
			"TownhouseBVisual",
			"VisualTownhouseB"
		]
	},
	"ruined_house": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"TownhouseVisualC",
			"TownhouseCVisual",
			"VisualTownhouseC"
		]
	},
	"warehouse": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"RailWarehouseVisual",
			"WarehouseVisual"
		]
	},
	"chainlink_fence": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"RailFenceA"
		]
	},
	"military_crate": {
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	}
}

const ENVIRONMENT_PATHS := {
	"village_house_a": (
		"res://assets/external/environment/village_house_a.glb"
	),
	"village_house_b": (
		"res://assets/external/environment/village_house_b.glb"
	),
	"ruined_house": (
		"res://assets/external/environment/ruined_house.glb"
	),
	"warehouse": (
		"res://assets/external/environment/warehouse.glb"
	),
	"chainlink_fence": (
		"res://assets/external/environment/chainlink_fence.glb"
	),
	"military_crate": (
		"res://assets/external/props/military_crate.glb"
	)
}

static func optional_scene(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		return null
	var loaded: Resource = load(path)
	if loaded is PackedScene:
		return loaded as PackedScene
	return null

static func available_character(team_id: int) -> PackedScene:
	return optional_scene(
		CHARACTER_ALLIED
		if team_id == 0
		else CHARACTER_AXIS
	)

static func environment_scene(asset_id: String) -> PackedScene:
	if not ENVIRONMENT_PATHS.has(asset_id):
		return null
	return optional_scene(str(ENVIRONMENT_PATHS[asset_id]))

static func availability_report() -> Dictionary:
	var report := {
		"allied_character": ResourceLoader.exists(
			CHARACTER_ALLIED
		),
		"axis_character": ResourceLoader.exists(
			CHARACTER_AXIS
		)
	}
	for asset_id in ENVIRONMENT_PATHS:
		report[asset_id] = ResourceLoader.exists(
			str(ENVIRONMENT_PATHS[asset_id])
		)
	for weapon_id in WEAPON_PATHS:
		report["weapon_%s" % weapon_id] = ResourceLoader.exists(
			str(WEAPON_PATHS[weapon_id])
		)
	return report

static func character_config(team_id: int) -> Dictionary:
	return Dictionary(
		CHARACTER_CONFIG.get(team_id, CHARACTER_CONFIG[0])
	)

static func weapon_scene(
	team_id: int,
	weapon_index: int
) -> PackedScene:
	if weapon_index == 1:
		return optional_scene(str(WEAPON_PATHS["service_pistol"]))
	return optional_scene(
		str(
			WEAPON_PATHS[
				"allied_primary"
				if team_id == 0
				else "axis_primary"
			]
		)
	)

static func environment_config(asset_id: String) -> Dictionary:
	return Dictionary(
		ENVIRONMENT_CONFIG.get(asset_id, {})
	)
