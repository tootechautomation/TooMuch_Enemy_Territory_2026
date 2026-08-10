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

func configure(
	new_id: int,
	position: Vector3,
	yaw: float,
	size: Vector3,
	new_health: int = 220
) -> void:
	barrier_id = new_id
	max_health = maxi(1, new_health)
	health = max_health
	original_position = position
	original_rotation_y = yaw
	global_position = position
	rotation.y = yaw

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
		material.albedo_color = Color(0.34, 0.28, 0.20)
		material.roughness = 0.96
		visual_mesh.material_override = material
		add_child(visual_mesh)


func server_apply_damage(amount: int) -> bool:
	if not multiplayer.is_server() or destroyed:
		return false

	health = maxi(0, health - maxi(0, amount))
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
	health = max_health
	global_position = original_position
	rotation.y = original_rotation_y
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	if visual_mesh != null:
		visual_mesh.visible = true
