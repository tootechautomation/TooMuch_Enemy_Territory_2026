extends Node
class_name WetSurfaceResponse

const UPDATE_INTERVAL := 0.10

var world_root: Node
var weather_system: Node
var wet_surfaces: Array[Dictionary] = []
var current_wetness := 0.0
var update_accumulator := 0.0

func build(root: Node, weather: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	world_root = root
	weather_system = weather
	call_deferred("_collect_world_surfaces")

func _process(delta: float) -> void:
	if world_root == null:
		return
	update_accumulator += delta
	if update_accumulator < UPDATE_INTERVAL:
		return
	var step := update_accumulator
	update_accumulator = 0.0

	var weather_intensity := 0.0
	if weather_system != null:
		weather_intensity = clampf(
			float(weather_system.get("current_intensity")),
			0.0,
			1.0
		)
	var target_wetness := smoothstep(
		0.20,
		0.78,
		weather_intensity
	)
	current_wetness = move_toward(
		current_wetness,
		target_wetness,
		step * (0.32 if target_wetness > current_wetness else 0.09)
	)
	_apply_wetness(current_wetness)

func _collect_world_surfaces() -> void:
	if world_root == null:
		return
	wet_surfaces.clear()
	for node_value in world_root.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var identity := _hierarchy_identity(mesh_instance)
		if not _is_weather_exposed(identity):
			continue
		if mesh_instance.material_override is StandardMaterial3D:
			var override_source := (
				mesh_instance.material_override as StandardMaterial3D
			)
			var override_material := (
				override_source.duplicate() as StandardMaterial3D
			)
			if _register_material(override_material):
				mesh_instance.material_override = override_material
			continue

		for surface_index in range(
			mesh_instance.mesh.get_surface_count()
		):
			var source := mesh_instance.get_active_material(
				surface_index
			)
			if not source is StandardMaterial3D:
				continue
			var material := (
				(source as StandardMaterial3D).duplicate()
				as StandardMaterial3D
			)
			if _register_material(material):
				mesh_instance.set_surface_override_material(
					surface_index,
					material
				)
	print(
		"Wet surface response registered %d materials"
		% wet_surfaces.size()
	)

func _register_material(material: StandardMaterial3D) -> bool:
	if material == null:
		return false
	if material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return false
	if material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
		return false
	wet_surfaces.append({
		"material": material,
		"base_color": material.albedo_color,
		"base_roughness": material.roughness
	})
	return true

func _apply_wetness(wetness: float) -> void:
	for surface in wet_surfaces:
		var material := surface.get("material") as StandardMaterial3D
		if material == null:
			continue
		var base_color: Color = surface.get(
			"base_color",
			Color.WHITE
		)
		var base_roughness := float(
			surface.get("base_roughness", 0.8)
		)
		var wet_color := base_color.darkened(0.18)
		material.albedo_color = base_color.lerp(
			wet_color,
			wetness
		)
		var wet_roughness := clampf(
			base_roughness * 0.38,
			0.16,
			0.46
		)
		material.roughness = lerpf(
			base_roughness,
			wet_roughness,
			wetness
		)

func _hierarchy_identity(node: Node) -> String:
	var names: Array[String] = []
	var current := node
	var depth := 0
	while current != null and depth < 7:
		names.append(str(current.name).to_lower())
		current = current.get_parent()
		depth += 1
	return " ".join(names)

func _is_weather_exposed(identity: String) -> bool:
	for excluded in [
		"player",
		"character",
		"weapon",
		"marker",
		"beacon",
		"spawnzone",
		"particle",
		"cloud",
		"mist",
		"rain",
		"river",
		"water"
	]:
		if excluded in identity:
			return false
	for exposed in [
		"ground",
		"road",
		"lane",
		"street",
		"cobble",
		"gravel",
		"mud",
		"rubble",
		"brick",
		"wall",
		"building",
		"house",
		"warehouse",
		"church",
		"bunker",
		"fort",
		"roof",
		"plaster",
		"concrete",
		"rail",
		"track",
		"train",
		"crate",
		"barrel",
		"cover",
		"fence",
		"tower",
		"trench",
		"platform",
		"sandbag",
		"halftrack",
		"artillery"
	]:
		if exposed in identity:
			return true
	return false
