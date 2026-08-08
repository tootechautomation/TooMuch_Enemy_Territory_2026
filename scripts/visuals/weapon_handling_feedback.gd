extends Node
class_name WeaponHandlingFeedback

var player: Node
var active_casings: Array[Node3D] = []
var max_casings: int = 14

func initialize(owner_player: Node) -> void:
	player = owner_player


func eject_casing(
	camera: Camera3D,
	is_pistol: bool
) -> void:
	if camera == null or DisplayServer.get_name() == "headless":
		return

	var casing := MeshInstance3D.new()
	casing.name = "LocalShellCasing"

	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.018 if is_pistol else 0.022
	mesh.bottom_radius = 0.018 if is_pistol else 0.022
	mesh.height = 0.085 if is_pistol else 0.105
	mesh.radial_segments = 8
	casing.mesh = mesh

	var brass := StandardMaterial3D.new()
	brass.albedo_color = Color(0.54, 0.39, 0.12)
	brass.metallic = 0.78
	brass.roughness = 0.34
	casing.material_override = brass
	casing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var right: Vector3 = camera.global_transform.basis.x
	var up: Vector3 = camera.global_transform.basis.y
	var forward: Vector3 = -camera.global_transform.basis.z

	casing.global_position = (
		camera.global_position
		+ right * (0.22 if is_pistol else 0.30)
		- up * 0.18
		+ forward * 0.48
	)

	var world_root := player.get_tree().current_scene
	if world_root == null:
		return
	world_root.add_child(casing)

	var velocity := (
		right * (1.7 if is_pistol else 2.1)
		+ up * 0.9
		+ forward * 0.30
	)
	casing.set_meta("feedback_velocity", velocity)
	casing.set_meta("feedback_spin", Vector3(
		5.0,
		8.0 if is_pistol else 11.0,
		6.0
	))
	casing.set_meta("feedback_age", 0.0)

	active_casings.append(casing)
	while active_casings.size() > max_casings:
		var oldest: Node3D = active_casings.pop_front()
		if oldest != null and is_instance_valid(oldest):
			oldest.queue_free()


func _process(delta: float) -> void:
	if active_casings.is_empty():
		return

	var gravity := 8.5
	for index in range(active_casings.size() - 1, -1, -1):
		var casing: Node3D = active_casings[index]
		if casing == null or not is_instance_valid(casing):
			active_casings.remove_at(index)
			continue

		var age: float = float(casing.get_meta("feedback_age", 0.0)) + delta
		casing.set_meta("feedback_age", age)

		var velocity: Vector3 = casing.get_meta(
			"feedback_velocity",
			Vector3.ZERO
		)
		velocity.y -= gravity * delta
		casing.set_meta("feedback_velocity", velocity)
		casing.global_position += velocity * delta

		var spin: Vector3 = casing.get_meta(
			"feedback_spin",
			Vector3.ZERO
		)
		casing.rotation += spin * delta

		# Ground approximation. Casings are cosmetic and intentionally have no
		# collision body/physics cost.
		if casing.global_position.y < 0.055:
			var p := casing.global_position
			p.y = 0.055
			casing.global_position = p
			velocity *= 0.28
			velocity.y = absf(velocity.y) * 0.18
			casing.set_meta("feedback_velocity", velocity)
			casing.set_meta("feedback_spin", spin * 0.45)

		var cleanup_age: float = 3.0 if max_casings <= 4 else 4.0 if max_casings <= 8 else 5.0
		if age >= cleanup_age:
			active_casings.remove_at(index)
			casing.queue_free()
