extends RefCounted
class_name StructureCollisionAuditor

const STRUCTURE_TERMS := [
	"wall", "brick", "building", "house", "apartment",
	"warehouse", "workshop", "barracks", "fort",
	"bunker", "facade", "tunnel", "foundation"
]

const NON_COLLIDING_TERMS := [
	"grime", "scorch", "decal", "dust", "particle",
	"foliage", "windowdetail", "streetdebris",
	"rubblefield", "lampglass", "objectivebeam",
	"muzzle", "weapon", "character"
]

static func audit_and_repair(root: Node) -> Dictionary:
	var report := {
		"scanned_meshes": 0,
		"structural_meshes": 0,
		"already_protected": 0,
		"trimesh_generated": 0,
		"box_fallbacks": 0,
		"failed": 0
	}
	if root == null:
		return report

	for node_value in root.find_children(
		"*",
		"MeshInstance3D",
		true
	):
		var mesh_instance := node_value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		report["scanned_meshes"] += 1
		if not _is_structural_mesh(mesh_instance):
			continue

		report["structural_meshes"] += 1
		if _has_collision(mesh_instance):
			report["already_protected"] += 1
			continue

		var previous_children := mesh_instance.get_child_count()
		mesh_instance.create_trimesh_collision()
		var generated_body := _new_static_body(
			mesh_instance,
			previous_children
		)

		if generated_body != null:
			_configure_body(generated_body)
			report["trimesh_generated"] += 1
			continue

		if _create_box_fallback(mesh_instance) != null:
			report["box_fallbacks"] += 1
		else:
			report["failed"] += 1

	return report

static func _is_structural_mesh(
	mesh_instance: MeshInstance3D
) -> bool:
	if not mesh_instance.visible:
		return false

	var combined := (
		mesh_instance.name.to_lower()
		+ " "
		+ str(mesh_instance.get_path()).to_lower()
	)

	for excluded_term in NON_COLLIDING_TERMS:
		if excluded_term in combined:
			return false

	for structure_term in STRUCTURE_TERMS:
		if structure_term in combined:
			return true
	return false

static func _has_collision(
	mesh_instance: MeshInstance3D
) -> bool:
	var current: Node = mesh_instance
	while current != null:
		if current is StaticBody3D:
			if _body_has_shape(current as StaticBody3D):
				return true
		current = current.get_parent()

	for node_value in mesh_instance.find_children(
		"*",
		"StaticBody3D",
		true
	):
		var body := node_value as StaticBody3D
		if body != null and _body_has_shape(body):
			return true
	return false

static func _body_has_shape(body: StaticBody3D) -> bool:
	for node_value in body.find_children(
		"*",
		"CollisionShape3D",
		true
	):
		var collision := node_value as CollisionShape3D
		if (
			collision != null
			and collision.shape != null
			and not collision.disabled
		):
			return true
	return false

static func _new_static_body(
	mesh_instance: MeshInstance3D,
	previous_child_count: int
) -> StaticBody3D:
	for child_index in range(
		previous_child_count,
		mesh_instance.get_child_count()
	):
		var child := mesh_instance.get_child(child_index)
		if child is StaticBody3D:
			return child as StaticBody3D
	return null

static func _configure_body(body: StaticBody3D) -> void:
	body.name = "%s_AutoCollision" % body.get_parent().name
	body.collision_layer = 1
	body.collision_mask = 1
	body.set_meta("structure_collision_generated", true)

	for node_value in body.find_children(
		"*",
		"CollisionShape3D",
		true
	):
		var collision := node_value as CollisionShape3D
		if collision != null:
			collision.disabled = false

static func _create_box_fallback(
	mesh_instance: MeshInstance3D
) -> StaticBody3D:
	var bounds := mesh_instance.get_aabb()
	if (
		bounds.size.x <= 0.01
		or bounds.size.y <= 0.01
		or bounds.size.z <= 0.01
	):
		return null

	var body := StaticBody3D.new()
	body.name = "%s_BoxCollisionFallback" % mesh_instance.name
	body.collision_layer = 1
	body.collision_mask = 1
	body.set_meta("structure_collision_generated", true)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = bounds.size
	collision.shape = shape
	collision.position = bounds.get_center()
	body.add_child(collision)
	mesh_instance.add_child(body)
	return body
