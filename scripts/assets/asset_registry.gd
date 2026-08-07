extends RefCounted
class_name ExternalAssetRegistry

const BUNDLED_CHARACTER_SCENE: PackedScene = preload(
	"res://assets/models/cc_by/cesium_man/CesiumMan.glb"
)

const CHARACTER_ALLIED_CANDIDATES: Array[String] = [
	# CGTrader: Private Military Contractor (preferred Allied model)
	"res://assets/external/characters/private_military_contractor.glb",
	"res://assets/external/characters/private_military_contractor.fbx",
	"res://assets/external/characters/private_military_contractor.obj",
	"res://assets/external/characters/allied_soldier.glb",
	"res://assets/external/characters/modular_military_2_allied.glb",
	"res://assets/external/characters/modular_military_2_allied.fbx",
	"res://assets/external/characters/modular_military_2_allied.blend",
	"res://assets/models/cc_by/cesium_man/CesiumMan.glb"
]
const CHARACTER_AXIS_CANDIDATES: Array[String] = [
	# CGTrader: Survival Character (preferred Axis model)
	"res://assets/external/characters/survival_character.glb",
	"res://assets/external/characters/survival_character.fbx",
	"res://assets/external/characters/survival_character.obj",
	"res://assets/external/characters/axis_soldier.glb",
	"res://assets/external/characters/modular_military_2_axis.glb",
	"res://assets/external/characters/modular_military_2_axis.fbx",
	"res://assets/external/characters/modular_military_2_axis.blend",
	"res://assets/models/cc_by/cesium_man/CesiumMan.glb"
]

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

const WEAPON_CANDIDATES := {
	"allied_primary": [
		"res://assets/external/weapons/m1a1_thompson.glb",
		"res://assets/external/weapons/m1a1_thompson.fbx",
		"res://assets/external/weapons/m1a1_thompson.obj",
		"res://assets/external/weapons/allied_rifle.glb"
	],
	"axis_primary": [
		"res://assets/external/weapons/mp40.glb",
		"res://assets/external/weapons/mp40.fbx",
		"res://assets/external/weapons/mp40.obj",
		"res://assets/external/weapons/axis_rifle.glb"
	],
	"allied_pistol": [
		"res://assets/external/weapons/tt_pistol.glb",
		"res://assets/external/weapons/tt_pistol.fbx",
		"res://assets/external/weapons/tt_pistol.obj",
		"res://assets/external/weapons/service_pistol.glb"
	],
	"axis_pistol": [
		"res://assets/external/weapons/walther_p38.glb",
		"res://assets/external/weapons/walther_p38.fbx",
		"res://assets/external/weapons/walther_p38.obj",
		"res://assets/external/weapons/service_pistol.glb"
	],
	"axis_grenade": [
		"res://assets/external/weapons/model24_grenade.glb",
		"res://assets/external/weapons/model24_grenade.fbx",
		"res://assets/external/weapons/model24_grenade.obj"
	]
}

const ENVIRONMENT_CONFIG := {
	"village_house_a": {
		"target_height": 10.0,
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
		"target_height": 10.0,
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
		"target_height": 8.0,
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
		"target_height": 9.0,
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
		"target_height": 2.2,
		"offset": Vector3.ZERO,
		"rotation_y": 0.0,
		"scale": Vector3.ONE,
		"generate_collision": true,
		"hide_fallback": [
			"RailFenceA"
		]
	},
	"military_crate": {
		"target_height": 0.8,
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
	# Godot imports OBJ as a Mesh resource rather than a scene. Wrap it so the
	# same external-asset pipeline can consume GLB, FBX, or OBJ downloads.
	if loaded is Mesh:
		var mesh_root := Node3D.new()
		mesh_root.name = "ImportedOBJ"
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "Mesh"
		mesh_instance.mesh = loaded as Mesh
		mesh_root.add_child(mesh_instance)
		mesh_instance.owner = mesh_root
		var packed := PackedScene.new()
		if packed.pack(mesh_root) == OK:
			mesh_root.free()
			return packed
		mesh_root.free()
	return null

static func first_available_scene(
	candidates: Array[String]
) -> PackedScene:
	for path in candidates:
		var scene := optional_scene(path)
		if scene != null:
			return scene
	return null

static func first_available_path(
	candidates: Array[String]
) -> String:
	for path in candidates:
		if ResourceLoader.exists(path):
			return path
	return ""

static func available_character(team_id: int) -> PackedScene:
	var selected := first_available_scene(
		CHARACTER_ALLIED_CANDIDATES
		if team_id == 0
		else CHARACTER_AXIS_CANDIDATES
	)
	if selected != null:
		return selected
	return BUNDLED_CHARACTER_SCENE

static func environment_scene(asset_id: String) -> PackedScene:
	if not ENVIRONMENT_PATHS.has(asset_id):
		return null
	return optional_scene(str(ENVIRONMENT_PATHS[asset_id]))

static func availability_report() -> Dictionary:
	var report := {
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
	for asset_id in ENVIRONMENT_PATHS:
		report[asset_id] = ResourceLoader.exists(
			str(ENVIRONMENT_PATHS[asset_id])
		)
	for weapon_id in WEAPON_CANDIDATES:
		var weapon_candidates: Array[String] = []
		for candidate in WEAPON_CANDIDATES[weapon_id]:
			weapon_candidates.append(str(candidate))
		var weapon_path := first_available_path(weapon_candidates)
		report["weapon_%s" % weapon_id] = not weapon_path.is_empty()
		report["weapon_%s_path" % weapon_id] = weapon_path
	return report

static func character_config(team_id: int) -> Dictionary:
	return Dictionary(
		CHARACTER_CONFIG.get(team_id, CHARACTER_CONFIG[0])
	)

static func _weapon_candidates(asset_id: String) -> Array[String]:
	var result: Array[String] = []
	if not WEAPON_CANDIDATES.has(asset_id):
		return result
	for candidate in WEAPON_CANDIDATES[asset_id]:
		result.append(str(candidate))
	return result

static func weapon_scene(
	team_id: int,
	weapon_index: int
) -> PackedScene:
	var asset_id := ""
	if weapon_index == 1:
		asset_id = "allied_pistol" if team_id == 0 else "axis_pistol"
	else:
		asset_id = "allied_primary" if team_id == 0 else "axis_primary"
	return first_available_scene(_weapon_candidates(asset_id))

static func grenade_scene(team_id: int) -> PackedScene:
	if team_id != 1:
		return null
	return first_available_scene(_weapon_candidates("axis_grenade"))

static func environment_config(asset_id: String) -> Dictionary:
	return Dictionary(
		ENVIRONMENT_CONFIG.get(asset_id, {})
	)

static func lod_config(asset_id: String) -> Dictionary:
	if asset_id in ["warehouse", "village_house_a", "village_house_b"]:
		return {
			"near": 40.0,
			"medium": 85.0,
			"far": 150.0
		}
	return {
		"near": 30.0,
		"medium": 65.0,
		"far": 110.0
	}
