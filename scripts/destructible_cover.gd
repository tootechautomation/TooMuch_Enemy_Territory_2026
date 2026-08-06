extends StaticBody3D


var cover_id := 0
var health := 260
var maximum_health := 260
var original_size := Vector3(3.0, 1.8, 0.7)
var body_mesh: MeshInstance3D
var collision_shape: CollisionShape3D
var health_label: Label3D
var current_damage_state := -1
var debris_spawned := false

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

func configure(
	new_id: int,
	spawn_position: Vector3,
	spawn_rotation_y: float,
	size: Vector3,
	new_health: int
) -> void:
	cover_id = new_id
	global_position = spawn_position
	rotation.y = spawn_rotation_y
	original_size = size
	health = new_health
	maximum_health = new_health
	_build_visuals()
	_apply_damage_state(true)

func _build_visuals() -> void:
	collision_shape = CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = original_size
	collision_shape.shape = shape
	collision_shape.position.y = original_size.y * 0.5
	add_child(collision_shape)

	body_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = original_size
	body_mesh.mesh = box
	body_mesh.position.y = original_size.y * 0.5
	var material := StandardMaterial3D.new()
	var optional_texture: Texture2D = _load_optional_texture(
		"res://assets/textures/concrete_damage.png"
	)
	if optional_texture != null:
		material.albedo_texture = optional_texture
	material.albedo_color = Color(0.80, 0.76, 0.68)
	material.roughness = 0.96
	body_mesh.material_override = material
	add_child(body_mesh)

	health_label = Label3D.new()
	health_label.position = Vector3(0.0, original_size.y + 0.45, 0.0)
	health_label.font_size = 14
	health_label.outline_size = 4
	health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	health_label.fixed_size = false
	add_child(health_label)

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0 or health <= 0:
		return

	health = maxi(0, health - amount)
	sync_cover_health.rpc(health)

@rpc("authority", "call_local", "reliable")
func sync_cover_health(new_health: int) -> void:
	health = new_health
	_apply_damage_state(false)

func reset_cover() -> void:
	health = maximum_health
	debris_spawned = false
	for child in get_children():
		if child.name.begins_with("Debris"):
			child.queue_free()
	sync_cover_health.rpc(health)

func _apply_damage_state(force: bool) -> void:
	var state := 0
	if health <= 0:
		state = 3
	elif health <= maximum_health * 0.33:
		state = 2
	elif health <= maximum_health * 0.66:
		state = 1

	if not force and state == current_damage_state:
		_update_label()
		return

	current_damage_state = state

	if state == 3:
		body_mesh.visible = false
		collision_shape.set_deferred("disabled", true)
		health_label.visible = false
		if not debris_spawned:
			debris_spawned = true
			_spawn_debris()
		return

	body_mesh.visible = true
	collision_shape.set_deferred("disabled", false)
	health_label.visible = true

	var scale_y := 1.0
	var damage_color := Color(0.34, 0.31, 0.25)
	if state == 1:
		scale_y = 0.82
		damage_color = Color(0.30, 0.25, 0.19)
	elif state == 2:
		scale_y = 0.56
		damage_color = Color(0.23, 0.18, 0.14)

	body_mesh.scale = Vector3(1.0, scale_y, 1.0)
	body_mesh.position.y = original_size.y * scale_y * 0.5
	collision_shape.scale = Vector3(1.0, scale_y, 1.0)
	collision_shape.position.y = original_size.y * scale_y * 0.5

	var material: StandardMaterial3D = (
		body_mesh.material_override as StandardMaterial3D
	)
	if material != null:
		material.albedo_color = damage_color

	_update_label()

func _update_label() -> void:
	if health_label == null:
		return
	health_label.text = "%d/%d" % [health, maximum_health]
	health_label.modulate = (
		Color(0.36, 1.0, 0.42)
		if health > maximum_health * 0.5
		else Color(1.0, 0.42, 0.12)
	)

func _spawn_debris() -> void:
	if DisplayServer.get_name() == "headless":
		return
	for index in range(8):
		var debris := MeshInstance3D.new()
		debris.name = "Debris_%d" % index
		var box := BoxMesh.new()
		box.size = Vector3(randf_range(0.18,0.52),randf_range(0.12,0.38),randf_range(0.16,0.46))
		debris.mesh = box
		debris.position = Vector3(randf_range(-original_size.x*0.45,original_size.x*0.45),randf_range(0.05,0.45),randf_range(-original_size.z,original_size.z))
		debris.rotation_degrees = Vector3(randf_range(0.0,180.0),randf_range(0.0,180.0),randf_range(0.0,180.0))
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(randf_range(0.22,0.34),randf_range(0.20,0.30),randf_range(0.17,0.26))
		material.roughness = 0.98
		debris.material_override = material
		add_child(debris)
