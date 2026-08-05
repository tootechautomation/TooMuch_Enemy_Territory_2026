extends Node3D

var attacker_skins: Array[Resource] = []
var defender_skins: Array[Resource] = []

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		set_process(false)
		return

	attacker_skins = _load_skin_resources([
		"res://data/skins/attacker_ranger.tres",
		"res://data/skins/attacker_desert.tres"
	])
	defender_skins = _load_skin_resources([
		"res://data/skins/defender_steel.tres",
		"res://data/skins/defender_winter.tres"
	])
	call_deferred("_build_character")

func _load_skin_resources(paths: Array[String]) -> Array[Resource]:
	var result: Array[Resource] = []
	for path in paths:
		if not ResourceLoader.exists(path):
			continue
		var resource: Resource = load(path)
		if resource != null:
			result.append(resource)
	return result

func _build_character() -> void:
	var player = get_parent()
	var skins: Array[Resource] = (
		attacker_skins if player.team == 0 else defender_skins
	)
	if skins.is_empty():
		return

	var skin: Resource = skins[posmod(player.peer_id, skins.size())]
	var old_body := player.get_node_or_null("Body")
	if old_body:
		old_body.visible = false
	_add_box("Torso", Vector3(0, 0.20, 0), Vector3(0.72, 0.92, 0.38), skin.primary_color)
	_add_box("Vest", Vector3(0, 0.22, -0.22), Vector3(0.78, 0.68, 0.12), skin.secondary_color)
	_add_box("Belt", Vector3(0, -0.25, 0), Vector3(0.78, 0.14, 0.42), skin.accent_color)
	_add_box("LegL", Vector3(-0.20, -0.65, 0), Vector3(0.25, 0.75, 0.28), skin.secondary_color)
	_add_box("LegR", Vector3(0.20, -0.65, 0), Vector3(0.25, 0.75, 0.28), skin.secondary_color)
	_add_box("ArmL", Vector3(-0.48, 0.20, 0), Vector3(0.20, 0.82, 0.24), skin.primary_color)
	_add_box("ArmR", Vector3(0.48, 0.20, 0), Vector3(0.20, 0.82, 0.24), skin.primary_color)
	_add_sphere("Head", Vector3(0, 0.88, 0), Vector3(0.27, 0.31, 0.27), Color(0.56, 0.40, 0.29))
	_add_sphere("Helmet", Vector3(0, 1.02, 0), Vector3(0.34, 0.20, 0.34), skin.helmet_color)
	_add_box("Pack", Vector3(0, 0.20, 0.28), Vector3(0.54, 0.65, 0.18), skin.secondary_color)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _add_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.material_override = _material(color)
	add_child(part)

func _add_sphere(node_name: String, pos: Vector3, scale_value: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = node_name
	part.position = pos
	part.scale = scale_value
	part.mesh = SphereMesh.new()
	part.material_override = _material(color)
	add_child(part)
