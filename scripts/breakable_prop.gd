extends StaticBody3D

var prop_id := 0
var prop_kind := "window"
var health := 40
var maximum_health := 40
var broken := false
var visual_mesh: MeshInstance3D
var collision_shape: CollisionShape3D

func configure(
	new_id: int,
	new_kind: String,
	position_value: Vector3,
	size_value: Vector3,
	rotation_y: float
) -> void:
	prop_id = new_id
	prop_kind = new_kind
	global_position = position_value
	rotation.y = rotation_y
	maximum_health = 28 if prop_kind == "window" else 85
	health = maximum_health
	_build_prop(size_value)

func _build_prop(size_value: Vector3) -> void:
	visual_mesh = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_value
	visual_mesh.mesh = mesh
	var material := StandardMaterial3D.new()
	if prop_kind == "window":
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.48, 0.68, 0.76, 0.38)
		material.roughness = 0.16
	else:
		material.albedo_color = Color(0.24, 0.13, 0.065)
		material.roughness = 0.86
	visual_mesh.material_override = material
	add_child(visual_mesh)
	collision_shape = CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision_shape.shape = shape
	add_child(collision_shape)

func server_take_damage(amount: int) -> void:
	if broken or not multiplayer.is_server():
		return
	health = maxi(0, health - amount)
	if health <= 0:
		break_prop.rpc()

@rpc("authority", "call_local", "reliable")
func break_prop() -> void:
	if broken:
		return
	broken = true
	if visual_mesh != null:
		visual_mesh.visible = false
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	_spawn_shards()

func _spawn_shards() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var count := 14 if prop_kind == "window" else 9
	for index in range(count):
		var shard := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = (
			Vector3(randf_range(0.05,0.18),randf_range(0.08,0.28),randf_range(0.015,0.035))
			if prop_kind == "window"
			else Vector3(randf_range(0.10,0.35),randf_range(0.08,0.26),randf_range(0.04,0.10))
		)
		shard.mesh = mesh
		shard.position = Vector3(randf_range(-0.65,0.65),randf_range(-0.55,0.55),randf_range(-0.18,0.18))
		var material := StandardMaterial3D.new()
		if prop_kind == "window":
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color = Color(0.58,0.78,0.86,0.46)
			material.roughness = 0.10
		else:
			material.albedo_color = Color(0.30,0.17,0.08)
			material.roughness = 0.90
		shard.material_override = material
		add_child(shard)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard,"position",shard.position+Vector3(randf_range(-1.6,1.6),randf_range(-0.9,1.2),randf_range(-1.2,1.2)),0.42)
		tween.tween_property(shard,"rotation_degrees",Vector3(randf_range(180.0,540.0),randf_range(180.0,540.0),randf_range(180.0,540.0)),0.42)
		tween.chain().tween_callback(shard.queue_free)
