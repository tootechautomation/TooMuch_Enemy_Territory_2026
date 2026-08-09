extends Node
class_name StructuralCollisionGuard

var world_root: Node
var built_for_ids: Dictionary = {}

func initialize(root: Node) -> void:
	world_root = root
	call_deferred("_audit_structural_collision")


func _audit_structural_collision() -> void:
	if world_root == null:
		return

	for value: Node in world_root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		if not _should_receive_guard(mesh_instance):
			continue

		var id := mesh_instance.get_instance_id()
		if built_for_ids.has(id):
			continue
		if _already_has_collision(mesh_instance):
			built_for_ids[id] = true
			continue

		_add_world_aabb_collider(mesh_instance)
		built_for_ids[id] = true


func _should_receive_guard(mesh_instance: MeshInstance3D) -> bool:
	var key := mesh_instance.name.to_lower()

	# Only high-confidence structural barriers. We deliberately avoid generic
	# "building" meshes because those may contain intentional doors/windows.
	var structural := (
		"wall" in key
		or "brickwall" in key
		or "stonewall" in key
		or "concretewall" in key
		or "perimeter" in key
		or "retaining" in key
		or "fence" in key
		or "barrier" in key
		or "bunkerwall" in key
	)
	if not structural:
		return false

	# Do not seal intended openings.
	if (
		"door" in key
		or "window" in key
		or "opening" in key
		or "gap" in key
		or "gate" in key
		or "arch" in key
		or "rubble" in key
		or "debris" in key
	):
		return false

	# Never create gameplay collision for pickup/player/cosmetic descendants.
	var cursor: Node = mesh_instance
	while cursor != null:
		var ancestor_key := cursor.name.to_lower()
		if (
			"player" in ancestor_key
			or "weapon" in ancestor_key
			or "pickup" in ancestor_key
			or "casualty" in ancestor_key
			or "viewmodel" in ancestor_key
			or "firstperson" in ancestor_key
		):
			return false
		cursor = cursor.get_parent()

	return true


func _already_has_collision(node: Node) -> bool:
	var cursor: Node = node
	while cursor != null:
		if cursor is CollisionObject3D:
			return true
		cursor = cursor.get_parent()

	for child: Node in node.get_children():
		if child is CollisionObject3D or child is CollisionShape3D:
			return true

	return false


func _add_world_aabb_collider(mesh_instance: MeshInstance3D) -> void:
	var local_aabb := mesh_instance.get_aabb()
	if local_aabb.size.length() <= 0.01:
		return

	var world_aabb := _transformed_aabb(
		local_aabb,
		mesh_instance.global_transform
	)

	# Ignore giant floor/sky/whole-map meshes accidentally named as walls.
	if world_aabb.size.x > 75.0 or world_aabb.size.z > 75.0:
		return
	if world_aabb.size.y > 30.0:
		return

	# Thin visual planes get a practical minimum collision thickness.
	var size := world_aabb.size
	size.x = maxf(size.x, 0.16)
	size.y = maxf(size.y, 0.16)
	size.z = maxf(size.z, 0.16)

	var body := StaticBody3D.new()
	body.name = "CollisionGuard_%s" % mesh_instance.name
	body.collision_layer = 1
	body.collision_mask = 1

	var shape_node := CollisionShape3D.new()
	shape_node.name = "CollisionShape"

	var box := BoxShape3D.new()
	box.size = size
	shape_node.shape = box

	body.global_position = world_aabb.get_center()
	world_root.add_child(body)
	body.add_child(shape_node)


func _transformed_aabb(
	local_aabb: AABB,
	transform: Transform3D
) -> AABB:
	var first := true
	var result := AABB()

	for x_index: int in range(2):
		for y_index: int in range(2):
			for z_index: int in range(2):
				var point := local_aabb.position + Vector3(
					local_aabb.size.x * float(x_index),
					local_aabb.size.y * float(y_index),
					local_aabb.size.z * float(z_index)
				)
				var world_point := transform * point

				if first:
					result = AABB(world_point, Vector3.ZERO)
					first = false
				else:
					result = result.expand(world_point)

	return result
