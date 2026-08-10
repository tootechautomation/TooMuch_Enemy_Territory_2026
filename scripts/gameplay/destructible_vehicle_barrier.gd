extends StaticBody3D
class_name VehicleDestructibleBarrier

var barrier_id := -1
var max_health := 220
var health := 220
var destroyed := false
var original_position := Vector3.ZERO
var original_rotation_y := 0.0
var collision_shape: CollisionShape3D
var visual_mesh: MeshInstance3D
var barrier_kind := "WOOD"
var damaged_visual_applied := false

func _finite_barrier_vector(
	value: Vector3,
	fallback: Vector3 = Vector3.ZERO
) -> Vector3:
	if (
		is_nan(value.x) or is_inf(value.x)
		or is_nan(value.y) or is_inf(value.y)
		or is_nan(value.z) or is_inf(value.z)
	):
		return fallback
	return value


func _finite_barrier_float(
	value: float,
	fallback: float = 0.0
) -> float:
	if is_nan(value) or is_inf(value):
		return fallback
	return value


func configure(
	new_id: int,
	position: Vector3,
	yaw: float,
	size: Vector3,
	new_health: int = 220,
	new_kind: String = "WOOD"
) -> void:
	barrier_id = new_id
	max_health = maxi(1, new_health)
	health = max_health
	barrier_kind = new_kind.to_upper()
	original_position = _finite_barrier_vector(position, Vector3.ZERO)
	original_rotation_y = _finite_barrier_float(yaw, 0.0)
	global_position = original_position
	rotation.y = original_rotation_y

	collision_shape = CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	add_child(collision_shape)

	if DisplayServer.get_name() != "headless":
		visual_mesh = MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = size
		visual_mesh.mesh = mesh

		var material := StandardMaterial3D.new()
		match barrier_kind:
			"BRICK":
				material.albedo_color = Color(0.42, 0.19, 0.12)
			"SANDBAG":
				material.albedo_color = Color(0.39, 0.35, 0.25)
			"CONCRETE":
				material.albedo_color = Color(0.36, 0.37, 0.36)
			_:
				material.albedo_color = Color(0.34, 0.28, 0.20)
		material.roughness = 0.96
		visual_mesh.material_override = material
		add_child(visual_mesh)


func server_apply_damage(amount: int) -> bool:
	if not multiplayer.is_server() or destroyed:
		return false

	health = maxi(0, health - maxi(0, amount))

	if (
		not damaged_visual_applied
		and health > 0
		and health <= int(round(max_health * 0.50))
	):
		damaged_visual_applied = true
		if visual_mesh != null:
			visual_mesh.rotation_degrees = Vector3(0.0, 0.0, 3.5)
			visual_mesh.scale = Vector3(0.97, 0.94, 0.97)

	if health <= 0:
		destroyed = true
		return true

	return false


func set_destroyed_visual() -> void:
	destroyed = true
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if visual_mesh != null:
		visual_mesh.visible = false


func reset_barrier() -> void:
	destroyed = false
	damaged_visual_applied = false
	health = max_health
	global_position = original_position
	rotation.y = original_rotation_y
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	if visual_mesh != null:
		visual_mesh.visible = true
		visual_mesh.rotation_degrees = Vector3.ZERO
		visual_mesh.scale = Vector3.ONE
