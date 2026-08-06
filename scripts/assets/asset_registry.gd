extends RefCounted
class_name ExternalAssetRegistry

const CHARACTER_ALLIED := (
	"res://assets/external/characters/allied_soldier.glb"
)
const CHARACTER_AXIS := (
	"res://assets/external/characters/axis_soldier.glb"
)

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
	return report
