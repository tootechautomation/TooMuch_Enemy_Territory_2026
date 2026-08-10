extends RefCounted
class_name ExternalAssetRegistry

const CHARACTER_ALLIED_CANDIDATES: Array[String] = [
	"res://assets/external/characters/ww2_allied_soldier.glb",
	"res://assets/external/characters/private_military_contractor.glb",
	"res://assets/external/characters/allied_soldier.glb"
]

const CHARACTER_AXIS_CANDIDATES: Array[String] = [
	"res://assets/external/characters/ww2_german_wehrmacht_soldier.glb",
	"res://assets/external/characters/survival_character.glb",
	"res://assets/external/characters/axis_soldier.glb"
]

const CHARACTER_CONFIG := {
	0: {
		"scale": Vector3.ONE,
		"rotation_y": deg_to_rad(180.0),
		"offset": Vector3.ZERO
	},
	1: {
		"scale": Vector3.ONE,
		"rotation_y": deg_to_rad(180.0),
		"offset": Vector3.ZERO
	}
}

const WEAPON_CANDIDATES := {
	"allied_primary": [
		"res://assets/external/weapons/m1a1_thompson.glb",
		"res://assets/external/weapons/allied_rifle.glb"
	],
	"axis_primary": [
		"res://assets/external/weapons/mp40.glb",
		"res://assets/external/weapons/axis_rifle.glb"
	],
	"allied_pistol": [
		"res://assets/external/weapons/tt_pistol.glb",
		"res://assets/external/weapons/service_pistol.glb"
	],
	"axis_pistol": [
		"res://assets/external/weapons/walther_p38.glb",
		"res://assets/external/weapons/service_pistol.glb"
	],
	"allied_grenade": [
		"res://assets/external/weapons/mk2_grenade.glb"
	],
	"axis_grenade": [
		"res://assets/external/weapons/model24_grenade.glb"
	]
}

const ENVIRONMENT_CONFIG := {
	"village_house_a": {
		"target_height": 10.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},
	"village_house_b": {
		"target_height": 10.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},
	"ruined_house": {
		"target_height": 8.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},
	"warehouse": {
		"target_height": 9.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},
	"chainlink_fence": {
		"target_height": 2.2,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},
	"military_crate": {
		"target_height": 0.8,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": []
	},

	# v9.28 user-supplied WWII setpieces.
	"city_ruins": {
		"target_height": 9.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		# Backdrop/setpiece first: no runtime trimesh generation.
		"generate_collision": false,
		"hide_fallback": []
	},
	"ww2_city_backdrop": {
		"target_height": 14.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": false,
		"hide_fallback": []
	},
	"mothecombe_pillbox": {
		"target_height": 5.0,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": false,
		"hide_fallback": []
	},
	"vairogs_vehicle_prop": {
		"target_height": 1.85,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": false,
		"hide_fallback": []
	}
}

const ENVIRONMENT_PATHS := {
	"village_house_a":
		"res://assets/external/environment/village_house_a.glb",
	"village_house_b":
		"res://assets/external/environment/village_house_b.glb",
	"ruined_house":
		"res://assets/external/environment/ruined_house.glb",
	"warehouse":
		"res://assets/external/environment/warehouse.glb",
	"chainlink_fence":
		"res://assets/external/environment/chainlink_fence.glb",
	"military_crate":
		"res://assets/external/props/military_crate.glb",

	"city_ruins":
		"res://assets/external/environment/city_ruins_environment.glb",
	"ww2_city_backdrop":
		"res://assets/external/environment/ww2_low_poly_city_scene.glb",
	"mothecombe_pillbox":
		"res://assets/external/environment/mothecombe_pillbox.glb",
	"vairogs_vehicle_prop":
		"res://assets/external/vehicles/vairogs_v2.glb"
}

static func optional_scene(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		return null
	var loaded: Resource = load(path)
	if loaded is PackedScene:
		return loaded as PackedScene
	return null

static func first_available_scene(
	candidates: Array[String]
) -> PackedScene:
	for path: String in candidates:
		var scene: PackedScene = optional_scene(path)
		if scene != null:
			return scene
	return null

static func first_available_path(
	candidates: Array[String]
) -> String:
	for path: String in candidates:
		if ResourceLoader.exists(path):
			return path
	return ""

static func available_character(team_id: int) -> PackedScene:
	return first_available_scene(
		CHARACTER_ALLIED_CANDIDATES
		if team_id == 0
		else CHARACTER_AXIS_CANDIDATES
	)

static func environment_scene(asset_id: String) -> PackedScene:
	if not ENVIRONMENT_PATHS.has(asset_id):
		return null
	return optional_scene(str(ENVIRONMENT_PATHS[asset_id]))

static func environment_config(asset_id: String) -> Dictionary:
	return Dictionary(
		ENVIRONMENT_CONFIG.get(asset_id, {})
	)

static func character_config(team_id: int) -> Dictionary:
	return Dictionary(
		CHARACTER_CONFIG.get(team_id, CHARACTER_CONFIG[0])
	)

static func _weapon_candidates(asset_id: String) -> Array[String]:
	var result: Array[String] = []
	if not WEAPON_CANDIDATES.has(asset_id):
		return result
	for candidate: Variant in WEAPON_CANDIDATES[asset_id]:
		result.append(str(candidate))
	return result

static func weapon_scene(
	team_id: int,
	weapon_index: int
) -> PackedScene:
	var asset_id: String
	if weapon_index == 1:
		asset_id = (
			"allied_pistol"
			if team_id == 0
			else "axis_pistol"
		)
	else:
		asset_id = (
			"allied_primary"
			if team_id == 0
			else "axis_primary"
		)
	return first_available_scene(_weapon_candidates(asset_id))

static func grenade_scene(team_id: int) -> PackedScene:
	return first_available_scene(
		_weapon_candidates(
			"allied_grenade"
			if team_id == 0
			else "axis_grenade"
		)
	)

static func availability_report() -> Dictionary:
	var report: Dictionary = {
		"allied_character": not first_available_path(
			CHARACTER_ALLIED_CANDIDATES
		).is_empty(),
		"axis_character": not first_available_path(
			CHARACTER_AXIS_CANDIDATES
		).is_empty(),
		"allied_character_path": first_available_path(
			CHARACTER_ALLIED_CANDIDATES
		),
		"axis_character_path": first_available_path(
			CHARACTER_AXIS_CANDIDATES
		)
	}

	for asset_id: Variant in ENVIRONMENT_PATHS:
		report[asset_id] = ResourceLoader.exists(
			str(ENVIRONMENT_PATHS[asset_id])
		)

	for weapon_id: Variant in WEAPON_CANDIDATES:
		var candidates: Array[String] = _weapon_candidates(
			str(weapon_id)
		)
		report["weapon_%s" % str(weapon_id)] = (
			not first_available_path(candidates).is_empty()
		)
		report["weapon_%s_path" % str(weapon_id)] = (
			first_available_path(candidates)
		)

	return report

static func lod_config(asset_id: String) -> Dictionary:
	if asset_id == "ww2_city_backdrop":
		return {"near": 45.0, "medium": 90.0, "far": 175.0}
	if asset_id in ["city_ruins", "mothecombe_pillbox"]:
		return {"near": 35.0, "medium": 75.0, "far": 135.0}
	return {"near": 30.0, "medium": 65.0, "far": 110.0}
