extends RefCounted
class_name WWIIMaterialLibrary

var cache: Dictionary = {}

func material_for(category: String) -> StandardMaterial3D:
	if cache.has(category):
		return cache[category]

	var material := StandardMaterial3D.new()
	material.roughness = 0.90

	match category:
		"brick":
			_configure(
				material,
				Color(0.42, 0.16, 0.09),
				0.96,
				0.0,
				101,
				Color(0.18, 0.045, 0.025),
				Color(0.58, 0.23, 0.13),
				Vector3(3.2, 3.2, 3.2)
			)
		"plaster":
			_configure(
				material,
				Color(0.67, 0.64, 0.56),
				0.98,
				0.0,
				202,
				Color(0.39, 0.37, 0.32),
				Color(0.81, 0.78, 0.69),
				Vector3(2.7, 2.7, 2.7)
			)
		"concrete":
			_configure(
				material,
				Color(0.38, 0.39, 0.37),
				0.96,
				0.0,
				303,
				Color(0.22, 0.23, 0.22),
				Color(0.55, 0.55, 0.51),
				Vector3(4.0, 4.0, 4.0)
			)
		"stone":
			_configure(
				material,
				Color(0.44, 0.41, 0.35),
				0.98,
				0.0,
				404,
				Color(0.24, 0.22, 0.19),
				Color(0.61, 0.57, 0.49),
				Vector3(3.2, 3.2, 3.2)
			)
		"wood":
			_configure(
				material,
				Color(0.24, 0.12, 0.052),
				0.84,
				0.0,
				505,
				Color(0.09, 0.035, 0.015),
				Color(0.40, 0.20, 0.075),
				Vector3(1.2, 5.0, 1.2)
			)
		"metal":
			_configure(
				material,
				Color(0.11, 0.12, 0.115),
				0.48,
				0.72,
				606,
				Color(0.045, 0.05, 0.048),
				Color(0.20, 0.21, 0.20),
				Vector3(4.0, 4.0, 4.0)
			)
		"road":
			_configure(
				material,
				Color(0.19, 0.18, 0.16),
				0.99,
				0.0,
				707,
				Color(0.075, 0.068, 0.058),
				Color(0.33, 0.31, 0.27),
				Vector3(6.0, 6.0, 6.0)
			)
		"mud":
			_configure(
				material,
				Color(0.20, 0.145, 0.085),
				0.92,
				0.0,
				808,
				Color(0.075, 0.045, 0.020),
				Color(0.34, 0.24, 0.12),
				Vector3(4.5, 4.5, 4.5)
			)
		"sandbag":
			_configure(
				material,
				Color(0.40, 0.34, 0.22),
				1.0,
				0.0,
				909,
				Color(0.21, 0.17, 0.10),
				Color(0.56, 0.48, 0.32),
				Vector3(5.0, 5.0, 5.0)
			)
		"roof":
			_configure(
				material,
				Color(0.105, 0.115, 0.12),
				0.92,
				0.0,
				111,
				Color(0.045, 0.050, 0.055),
				Color(0.20, 0.21, 0.22),
				Vector3(3.0, 3.0, 3.0)
			)
		_:
			material.albedo_color = Color(0.42, 0.40, 0.36)

	cache[category] = material
	return material

func apply_to_world(root: Node) -> Dictionary:
	var report := {}
	for category in [
		"brick",
		"plaster",
		"concrete",
		"stone",
		"wood",
		"metal",
		"road",
		"mud",
		"sandbag",
		"roof"
	]:
		report[category] = 0

	for node_value in root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null:
			continue
		if mesh_instance.name.begins_with("External"):
			continue

		var category := _category_for_name(
			mesh_instance.name.to_lower()
		)
		if category.is_empty():
			continue

		mesh_instance.material_override = material_for(category)
		report[category] = int(report[category]) + 1

	return report

func _configure(
	material: StandardMaterial3D,
	base_color: Color,
	roughness_value: float,
	metallic_value: float,
	seed_value: int,
	dark_color: Color,
	light_color: Color,
	uv_scale: Vector3
) -> void:
	material.albedo_color = base_color
	material.roughness = roughness_value
	material.metallic = metallic_value
	material.albedo_texture = _noise_texture(
		seed_value,
		dark_color,
		light_color
	)
	material.uv1_scale = uv_scale

	var pbr_stem := ""
	match seed_value:
		101:
			pbr_stem = "brick"
		202:
			pbr_stem = "damaged_plaster"
		303:
			pbr_stem = "concrete"
		404:
			pbr_stem = "limestone_blocks"
		505:
			pbr_stem = "wood"
		606:
			pbr_stem = "rusted_metal"
		707:
			pbr_stem = "cobblestone"
		808:
			pbr_stem = "mud"
		909:
			pbr_stem = "compacted_gravel"
		111:
			pbr_stem = "slate_roof"

	if not pbr_stem.is_empty():
		_apply_pbr_textures(material, pbr_stem)

func _apply_pbr_textures(
	material: StandardMaterial3D,
	stem: String
) -> void:
	var root_path := "res://assets/pbr/%s" % stem
	var albedo := _load_texture(root_path + "_albedo.png")
	var normal := _load_texture(root_path + "_normal.png")
	var roughness_map := _load_texture(root_path + "_roughness.png")

	if albedo != null:
		material.albedo_texture = albedo
		material.albedo_color = Color(0.92, 0.92, 0.92, 1.0)
	if normal != null:
		material.normal_enabled = true
		material.normal_texture = normal
		material.normal_scale = 0.82
	if roughness_map != null:
		material.roughness_texture = roughness_map
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _category_for_name(lower_name: String) -> String:
	if (
		"brick" in lower_name
		or "townhouse" in lower_name
		or "warehouse" in lower_name
	):
		return "brick"
	if (
		"plaster" in lower_name
		or "facade" in lower_name
		or "wall" in lower_name
	):
		return "plaster"
	if (
		"concrete" in lower_name
		or "bunker" in lower_name
		or "tunnel" in lower_name
	):
		return "concrete"
	if (
		"stone" in lower_name
		or "church" in lower_name
		or "rubble" in lower_name
	):
		return "stone"
	if (
		"wood" in lower_name
		or "crate" in lower_name
		or "fence" in lower_name
		or "shutter" in lower_name
		or "door" in lower_name
	):
		return "wood"
	if (
		"metal" in lower_name
		or "barrel" in lower_name
		or "lamp" in lower_name
		or "rail" in lower_name
	):
		return "metal"
	if (
		"road" in lower_name
		or "street" in lower_name
		or "cobble" in lower_name
	):
		return "road"
	if (
		"mud" in lower_name
		or "ground" in lower_name
		or "terrain" in lower_name
	):
		return "mud"
	if "sandbag" in lower_name:
		return "sandbag"
	if "roof" in lower_name or "slate" in lower_name:
		return "roof"
	return ""

func _noise_texture(
	seed_value: int,
	dark_color: Color,
	light_color: Color
) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.055
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.52

	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([
		0.0,
		0.38,
		0.66,
		1.0
	])
	gradient.colors = PackedColorArray([
		dark_color.darkened(0.12),
		dark_color,
		light_color,
		light_color.lightened(0.08)
	])

	var texture := NoiseTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.seamless = true
	texture.normalize = true
	texture.noise = noise
	texture.color_ramp = gradient
	return texture
