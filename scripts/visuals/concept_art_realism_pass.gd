extends Node3D
class_name ConceptArtRealismPass

const BUILD_SEED := 8432026

var _materials: Dictionary = {}
var _rng := RandomNumberGenerator.new()

func build(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_rng.seed = BUILD_SEED
	_upgrade_world_environment(root)
	_upgrade_world_lighting(root)
	_upgrade_structural_materials(root)
	_build_wall_age_detail()
	_build_ground_detail()
	_build_period_prop_clusters()
	_build_fortification_detail()
	_build_practical_lights()

func _safe_set(object: Object, property_name: StringName, value: Variant) -> void:
	if object == null:
		return
	for property_info in object.get_property_list():
		if StringName(property_info.get("name", "")) == property_name:
			object.set(property_name, value)
			return

func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _pbr_material(
	key: String,
	stem: String,
	tint: Color,
	uv_scale: float,
	roughness_value: float,
	metallic_value: float = 0.0
) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D

	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = roughness_value
	material.metallic = metallic_value
	material.uv1_scale = Vector3(uv_scale, uv_scale, uv_scale)
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true

	var root_path := "res://assets/pbr/%s" % stem
	var albedo_path := root_path + "_albedo.png"
	var normal_path := root_path + "_normal.png"
	var roughness_path := root_path + "_roughness.png"
	if stem == "brick":
		albedo_path = "res://assets/cc0/ambientcg/Bricks097/Bricks097_Color.jpg"
		normal_path = "res://assets/cc0/ambientcg/Bricks097/Bricks097_NormalGL.jpg"
		roughness_path = "res://assets/cc0/ambientcg/Bricks097/Bricks097_Roughness.jpg"

	var albedo := _load_texture(albedo_path)
	var normal := _load_texture(normal_path)
	var roughness_map := _load_texture(roughness_path)
	if albedo != null:
		material.albedo_texture = albedo
	if normal != null:
		material.normal_enabled = true
		material.normal_texture = normal
		material.normal_scale = 1.0
	if roughness_map != null:
		material.roughness_texture = roughness_map
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

	_materials[key] = material
	return material

func _plain_material(
	key: String,
	color: Color,
	roughness_value: float,
	metallic_value: float = 0.0,
	transparent: bool = false
) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness_value
	material.metallic = metallic_value
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_materials[key] = material
	return material

func _upgrade_world_environment(root: Node) -> void:
	for node_value in root.find_children("*", "WorldEnvironment", true):
		var world_environment := node_value as WorldEnvironment
		if world_environment == null or world_environment.environment == null:
			continue
		var environment := world_environment.environment

		# Filmic, lower-saturation battlefield response similar to the target art.
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		environment.tonemap_exposure = 0.92
		environment.tonemap_white = 1.35
		environment.adjustment_enabled = true
		environment.adjustment_brightness = 0.97
		environment.adjustment_contrast = 1.18
		environment.adjustment_saturation = 0.78

		# Ground contact and material depth are the biggest difference between the
		# prototype presentation and the target look.
		environment.ssao_enabled = true
		environment.ssao_radius = 2.2
		environment.ssao_intensity = 2.45
		environment.ssil_enabled = true
		environment.ssil_radius = 3.5
		environment.ssil_intensity = 1.15
		environment.ssr_enabled = true
		environment.ssr_max_steps = 64
		environment.glow_enabled = true
		environment.glow_intensity = 0.22

		# Cool overcast haze with a shallow ground layer. Use safe setters for
		# properties that differ between Godot minor versions/renderers.
		environment.fog_enabled = true
		environment.fog_light_color = Color(0.45, 0.50, 0.54)
		environment.fog_light_energy = 0.62
		environment.fog_density = 0.0068
		environment.fog_height = 1.5
		environment.fog_height_density = 0.045
		_safe_set(environment, &"volumetric_fog_enabled", true)
		_safe_set(environment, &"volumetric_fog_density", 0.018)
		_safe_set(environment, &"volumetric_fog_length", 72.0)
		_safe_set(environment, &"volumetric_fog_detail_spread", 2.0)
		_safe_set(environment, &"volumetric_fog_ambient_inject", 0.65)

func _upgrade_world_lighting(root: Node) -> void:
	var directional_found := false
	for node_value in root.find_children("*", "DirectionalLight3D", true):
		var light := node_value as DirectionalLight3D
		if light == null:
			continue
		directional_found = true
		light.light_color = Color(0.86, 0.90, 0.97)
		light.light_energy = 1.05
		light.shadow_enabled = true
		light.directional_shadow_max_distance = 145.0
		light.directional_shadow_fade_start = 0.82
		light.shadow_bias = 0.045
		light.shadow_normal_bias = 0.75
		_safe_set(light, &"directional_shadow_blend_splits", true)
		_safe_set(light, &"light_angular_distance", 0.6)

	if not directional_found:
		var sun := DirectionalLight3D.new()
		sun.name = "RealismOvercastKey"
		sun.rotation_degrees = Vector3(-48.0, -24.0, 0.0)
		sun.light_color = Color(0.86, 0.90, 0.97)
		sun.light_energy = 1.05
		sun.shadow_enabled = true
		sun.directional_shadow_max_distance = 145.0
		add_child(sun)

func _structural_category(mesh_instance: MeshInstance3D) -> String:
	var lower := (
		mesh_instance.name.to_lower()
		+ " "
		+ str(mesh_instance.get_path()).to_lower()
	)
	if (
		"weapon" in lower
		or "character" in lower
		or "player" in lower
		or "decal" in lower
		or "glass" in lower
		or "foliage" in lower
		or "particle" in lower
	):
		return ""
	if "brick" in lower or "townhouse" in lower or "chimney" in lower:
		return "brick"
	if "bunker" in lower or "concrete" in lower or "fort" in lower:
		return "concrete"
	if "plaster" in lower or "facade" in lower:
		return "plaster"
	if "stone" in lower or "foundation" in lower or "curb" in lower:
		return "stone"
	if "wood" in lower or "crate" in lower or "shutter" in lower or "door" in lower:
		return "wood"
	if "metal" in lower or "barrel" in lower or "rail" in lower or "gutter" in lower:
		return "metal"
	if "mud" in lower or "ground" in lower or "terrain" in lower:
		return "mud"
	if "road" in lower or "street" in lower or "cobble" in lower:
		return "road"
	if "wall" in lower or "building" in lower or "warehouse" in lower:
		return "plaster"
	return ""

func _material_for_category(category: String) -> StandardMaterial3D:
	match category:
		"brick":
			return _pbr_material(
				"real_brick", "brick", Color(0.72, 0.67, 0.62), 2.7, 0.91
			)
		"concrete":
			return _pbr_material(
				"real_concrete", "concrete", Color(0.66, 0.67, 0.65), 3.2, 0.90
			)
		"plaster":
			return _pbr_material(
				"real_plaster", "damaged_plaster", Color(0.80, 0.77, 0.68), 2.4, 0.94
			)
		"stone":
			return _pbr_material(
				"real_stone", "limestone_blocks", Color(0.74, 0.72, 0.65), 2.3, 0.93
			)
		"wood":
			return _pbr_material(
				"real_wood", "wood", Color(0.56, 0.43, 0.31), 2.1, 0.78
			)
		"metal":
			return _pbr_material(
				"real_metal", "rusted_metal", Color(0.66, 0.66, 0.63), 3.1, 0.58, 0.52
			)
		"road":
			return _pbr_material(
				"real_road", "cobblestone", Color(0.55, 0.56, 0.54), 3.7, 0.84
			)
		"mud":
			return _pbr_material(
				"real_mud", "mud", Color(0.48, 0.40, 0.31), 3.8, 0.72
			)
	return null

func _upgrade_structural_materials(root: Node) -> void:
	var changed := 0
	for node_value in root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var category := _structural_category(mesh_instance)
		if category.is_empty():
			continue
		var material := _material_for_category(category)
		if material == null:
			continue
		mesh_instance.material_override = material
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		changed += 1
	print("Concept realism material upgrade: %d meshes" % changed)

func _box(
	parent: Node3D,
	item_name: String,
	position_value: Vector3,
	size_value: Vector3,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = item_name
	item.position = position_value
	item.rotation_degrees = rotation_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	item.mesh = mesh
	item.material_override = material
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(item)
	return item

func _cylinder(
	parent: Node3D,
	item_name: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3 = Vector3.ZERO,
	segments: int = 18
) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = item_name
	item.position = position_value
	item.rotation_degrees = rotation_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	item.mesh = mesh
	item.material_override = material
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(item)
	return item

func _build_wall_age_detail() -> void:
	var damp := _plain_material(
		"damp_wall", Color(0.055, 0.060, 0.057, 0.44), 0.62, 0.0, true
	)
	var soot := _plain_material(
		"wall_soot", Color(0.018, 0.018, 0.017, 0.50), 0.98, 0.0, true
	)
	var brick := _material_for_category("brick")

	# Thin overlays add the dark wet/grimy lower wall band visible in the target
	# without changing collision or creating large blocking volumes.
	for data in [
		[Vector3(-51.0,0.55,-30.36),Vector3(12.0,1.05,0.035),Vector3.ZERO],
		[Vector3(-51.5,0.50,-11.40),Vector3(11.5,0.95,0.035),Vector3.ZERO],
		[Vector3(45.0,0.55,-21.86),Vector3(13.0,1.05,0.035),Vector3.ZERO],
		[Vector3(46.0,0.55,20.10),Vector3(12.5,1.0,0.035),Vector3.ZERO]
	]:
		_box(self, "WetWallStain", Vector3(data[0]), Vector3(data[1]), damp, Vector3(data[2]))

	for data in [
		[Vector3(-48.8,3.15,-30.33),Vector3(1.6,2.4,0.025),9.0],
		[Vector3(43.8,3.45,-21.83),Vector3(1.8,2.8,0.025),-7.0],
		[Vector3(-50.3,4.15,30.08),Vector3(1.3,2.0,0.025),13.0]
	]:
		_box(
			self,
			"BlastSoot",
			Vector3(data[0]),
			Vector3(data[1]),
			soot,
			Vector3(0.0, 0.0, float(data[2]))
		)

	# Small exposed masonry patches break up broad flat plaster surfaces.
	for data in [
		[Vector3(-49.5,2.6,-30.31),Vector3(1.4,0.82,0.04)],
		[Vector3(-52.0,4.4,-11.36),Vector3(1.1,1.3,0.04)],
		[Vector3(44.3,2.2,-21.80),Vector3(1.5,0.75,0.04)]
	]:
		_box(self, "ExposedMasonry", Vector3(data[0]), Vector3(data[1]), brick)

func _build_ground_detail() -> void:
	var wet_mud := _plain_material(
		"wet_mud_overlay", Color(0.055, 0.047, 0.038, 0.38), 0.22, 0.0, true
	)
	var puddle := _plain_material(
		"deep_puddle", Color(0.025, 0.040, 0.050, 0.58), 0.055, 0.0, true
	)
	var gravel := _material_for_category("road")

	for data in [
		[Vector3(-17.0,0.024,-9.0),Vector3(8.0,0.012,2.3),-11.0],
		[Vector3(14.0,0.024,8.0),Vector3(7.0,0.012,2.0),7.0],
		[Vector3(-4.0,0.024,29.0),Vector3(9.5,0.012,2.5),16.0],
		[Vector3(24.0,0.024,-25.0),Vector3(6.5,0.012,1.8),-15.0]
	]:
		_box(
			self, "WetMudPatch", Vector3(data[0]), Vector3(data[1]), wet_mud,
			Vector3(0.0,float(data[2]),0.0)
		)

	for data in [
		[Vector3(-12.0,0.034,-7.0),Vector3(3.4,0.010,1.25),-8.0],
		[Vector3(19.0,0.034,5.0),Vector3(2.9,0.010,1.0),12.0],
		[Vector3(2.0,0.034,26.0),Vector3(3.8,0.010,1.15),6.0]
	]:
		_box(
			self, "ReflectivePuddle", Vector3(data[0]), Vector3(data[1]), puddle,
			Vector3(0.0,float(data[2]),0.0)
		)

	# Scattered gravel chunks give the road a less planar silhouette.
	for index in range(85):
		var p := Vector3(
			_rng.randf_range(-45.0,45.0),
			_rng.randf_range(0.025,0.07),
			_rng.randf_range(-38.0,38.0)
		)
		var size := Vector3(
			_rng.randf_range(0.04,0.14),
			_rng.randf_range(0.025,0.08),
			_rng.randf_range(0.04,0.14)
		)
		_box(
			self, "RoadAggregate", p, size, gravel,
			Vector3(
				_rng.randf_range(-18.0,18.0),
				_rng.randf_range(0.0,180.0),
				_rng.randf_range(-18.0,18.0)
			)
		)

func _build_period_prop_clusters() -> void:
	var wood := _material_for_category("wood")
	var metal := _material_for_category("metal")
	var cloth := _pbr_material(
		"real_sandbag", "compacted_gravel", Color(0.52,0.45,0.31), 4.8, 0.96
	)

	for center in [
		Vector3(-31.0,0.0,-14.0),
		Vector3(23.0,0.0,-19.0),
		Vector3(37.0,0.0,14.0),
		Vector3(-36.0,0.0,24.0)
	]:
		var root := Node3D.new()
		root.name = "RealismSupplyCluster"
		root.position = center
		root.rotation_degrees.y = _rng.randf_range(-14.0,14.0)
		add_child(root)
		for crate_index in range(3):
			var x := float(crate_index % 2) * 0.82
			var y := 0.36 + float(crate_index / 2) * 0.72
			_box(root,"DetailedWoodCrate",Vector3(x,y,0.0),Vector3(0.72,0.68,0.72),wood)
			_box(root,"CrateCrossBraceA",Vector3(x,y,-0.372),Vector3(0.065,0.73,0.035),wood,Vector3(0.0,0.0,43.0))
			_box(root,"CrateCrossBraceB",Vector3(x,y,-0.374),Vector3(0.065,0.73,0.035),wood,Vector3(0.0,0.0,-43.0))
		for barrel_index in range(2):
			var barrel_x := -0.65 - float(barrel_index) * 0.54
			_cylinder(root,"SteelDrum",Vector3(barrel_x,0.48,0.12),0.25,0.96,metal)
			_cylinder(root,"DrumBandTop",Vector3(barrel_x,0.76,0.12),0.258,0.035,metal)
			_cylinder(root,"DrumBandBottom",Vector3(barrel_x,0.20,0.12),0.258,0.035,metal)

	# Additional sandbag positions with less box-like silhouettes.
	for data in [
		[Vector3(-18.0,0.0,-9.0),0.0,7],
		[Vector3(11.0,0.0,7.0),22.0,7],
		[Vector3(35.0,0.0,17.0),-35.0,8]
	]:
		var wall := Node3D.new()
		wall.name = "RealismSandbagWall"
		wall.position = Vector3(data[0])
		wall.rotation_degrees.y = float(data[1])
		add_child(wall)
		for row in range(2):
			var count: int = int(data[2]) - row
			for index in range(count):
				var bag := MeshInstance3D.new()
				bag.name = "ClothSandbag"
				var mesh := CapsuleMesh.new()
				mesh.radius = 0.18
				mesh.height = 0.58
				mesh.radial_segments = 18
				mesh.rings = 8
				bag.mesh = mesh
				bag.scale = Vector3(1.0,1.0,0.72)
				bag.rotation_degrees = Vector3(0.0,_rng.randf_range(-5.0,5.0),90.0)
				bag.position = Vector3(
					(float(index)-float(count-1)*0.5)*0.52 + (0.25 if row else 0.0),
					0.18 + float(row)*0.25,
					0.0
				)
				bag.material_override = cloth
				wall.add_child(bag)

func _build_fortification_detail() -> void:
	var concrete := _material_for_category("concrete")
	var rust := _material_for_category("metal")
	var dark := _plain_material("fort_dark",Color(0.055,0.057,0.055),0.90)
	for position_value in [
		Vector3(-12.0,0.0,-31.0),
		Vector3(13.0,0.0,31.0)
	]:
		var root := Node3D.new()
		root.name = "FortificationDetail"
		root.position = position_value
		add_child(root)
		_box(root,"ConcreteFooting",Vector3(0.0,0.28,0.0),Vector3(3.2,0.56,1.0),concrete)
		for index in range(4):
			_cylinder(root,"RustAnchor",Vector3(-1.15+float(index)*0.75,0.60,-0.46),0.035,0.18,rust,Vector3(90.0,0.0,0.0),12)
		_box(root,"DarkFiringSlot",Vector3(0.0,1.05,-0.515),Vector3(1.55,0.28,0.03),dark)

func _build_practical_lights() -> void:
	var iron := _material_for_category("metal")
	var glass := _plain_material(
		"warm_glass", Color(1.0,0.70,0.37,0.84), 0.16, 0.0, true
	)
	glass.emission_enabled = true
	glass.emission = Color(1.0,0.43,0.12)
	glass.emission_energy_multiplier = 1.4

	for position_value in [
		Vector3(-33.5,0.0,-29.0),
		Vector3(33.5,0.0,-28.0),
		Vector3(-33.5,0.0,26.0),
		Vector3(33.5,0.0,27.0)
	]:
		var root := Node3D.new()
		root.name = "RealismPracticalLamp"
		root.position = position_value
		add_child(root)
		_cylinder(root,"LampPost",Vector3(0.0,2.1,0.0),0.055,4.2,iron)
		_box(root,"LampHead",Vector3(0.25,4.08,0.0),Vector3(0.36,0.30,0.28),glass)
		var light := OmniLight3D.new()
		light.name = "WarmPracticalLight"
		light.position = Vector3(0.25,4.02,0.0)
		light.light_color = Color(1.0,0.58,0.26)
		light.light_energy = 1.15
		light.omni_range = 8.0
		light.shadow_enabled = true
		root.add_child(light)
