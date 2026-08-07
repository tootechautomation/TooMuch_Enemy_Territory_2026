extends StaticBody3D


var constructible_id := 0
var owner_id := 0
var team := 0
var health := 180
var maximum_health := 180
var main_node: Node
var health_label: Label3D

func _load_optional_texture(path: String) -> Texture2D:
	if DisplayServer.get_name() == "headless":
		return null
	if not ResourceLoader.exists(path):
		push_warning("Optional texture not found: %s" % path)
		return null

	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D

	push_warning("Optional texture failed to load: %s" % path)
	return null

func configure(new_id: int, new_owner_id: int, new_team: int, spawn_position: Vector3, spawn_rotation_y: float, new_health: int) -> void:
	constructible_id = new_id
	owner_id = new_owner_id
	team = new_team
	health = new_health
	maximum_health = new_health
	main_node = get_parent()
	global_position = spawn_position
	rotation.y = spawn_rotation_y
	set_meta("constructible_id", constructible_id)
	_build_visuals()
	_update_health_label()

func _build_visuals() -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.6, 1.55, 0.48)
	collision.shape = shape
	collision.position.y = 0.78
	add_child(collision)

	var body_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(3.6, 1.55, 0.48)
	body_mesh.mesh = box
	body_mesh.position.y = 0.78
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.34, 0.72) if team == 0 else Color(0.72, 0.20, 0.16)
	material.roughness = 0.88
	body_mesh.material_override = material
	add_child(body_mesh)

	for offset_x in [-1.45, 0.0, 1.45]:
		var brace := MeshInstance3D.new()
		var brace_mesh := BoxMesh.new()
		brace_mesh.size = Vector3(0.18, 1.85, 0.72)
		brace.mesh = brace_mesh
		brace.position = Vector3(offset_x, 0.88, 0.0)
		var brace_material := StandardMaterial3D.new()
		brace_material.albedo_color = Color(0.18, 0.16, 0.13)
		brace.material_override = brace_material
		add_child(brace)

	health_label = Label3D.new()
	health_label.position = Vector3(0.0, 2.05, 0.0)
	health_label.font_size = 24
	health_label.outline_size = 8
	health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	health_label.fixed_size = true
	add_child(health_label)

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or amount <= 0 or health <= 0:
		return
	health = maxi(0, health - amount)
	_update_health_label_rpc.rpc(health)
	if health <= 0 and main_node != null:
		main_node.call("server_destroy_constructible", constructible_id, attacker_id)

@rpc("authority", "call_local", "reliable")
func _update_health_label_rpc(new_health: int) -> void:
	health = new_health
	_update_health_label()

func _update_health_label() -> void:
	if health_label == null:
		return
	health_label.text = "BARRICADE %d/%d" % [health, maximum_health]
	health_label.modulate = Color(0.30, 1.0, 0.38) if health > maximum_health * 0.5 else Color(1.0, 0.42, 0.12)
