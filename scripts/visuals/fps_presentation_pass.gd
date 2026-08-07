extends Node
class_name FPSPresentationPass

# v8.49.0
# Camera-local FPS presentation enhancements. This pass deliberately does not
# replace weapon gameplay, damage, ammo, or networking.

var root: Node
var camera: Camera3D
var view_root: Node3D
var elapsed: float = 0.0
var previous_camera_position: Vector3 = Vector3.ZERO
var movement_amount: float = 0.0
var recoil_offset: float = 0.0
var recoil_velocity: float = 0.0
var last_fire_down: bool = false

func initialize(game_root: Node) -> void:
	root = game_root
	set_process(true)
	call_deferred("_find_camera_and_build")


func _find_camera_and_build() -> void:
	camera = _find_active_camera(root)
	if camera == null:
		return

	previous_camera_position = camera.global_position
	view_root = Node3D.new()
	view_root.name = "FPSPresentationRig_v849"
	camera.add_child(view_root)
	view_root.position = Vector3.ZERO

	_build_forearms()
	_build_weapon_fill_light()
	_build_viewmodel_shadow_catcher()


func _process(delta: float) -> void:
	if camera == null or not is_instance_valid(camera):
		camera = _find_active_camera(root)
		return
	if view_root == null:
		return

	elapsed += delta
	var displacement: float = camera.global_position.distance_to(previous_camera_position)
	previous_camera_position = camera.global_position
	var speed_signal: float = clampf(displacement / maxf(delta, 0.001), 0.0, 8.0)
	movement_amount = lerpf(movement_amount, clampf(speed_signal / 5.0, 0.0, 1.0), delta * 8.0)

	var bob_x: float = sin(elapsed * 8.4) * 0.008 * movement_amount
	var bob_y: float = absf(cos(elapsed * 8.4)) * 0.010 * movement_amount
	var breathe: float = sin(elapsed * 1.55) * 0.003

	recoil_velocity += (-recoil_offset * 38.0 - recoil_velocity * 10.0) * delta
	recoil_offset += recoil_velocity * delta

	view_root.position = Vector3(bob_x, -bob_y + breathe, recoil_offset)
	view_root.rotation = Vector3(
		deg_to_rad(-recoil_offset * 55.0),
		deg_to_rad(bob_x * 70.0),
		deg_to_rad(-bob_x * 45.0)
	)

	var fire_down: bool = Input.is_action_pressed("fire") if InputMap.has_action("fire") else false
	if fire_down and not last_fire_down:
		_kick_recoil()
		_flash_muzzle()
	last_fire_down = fire_down


func _kick_recoil() -> void:
	recoil_velocity = minf(recoil_velocity + 0.19, 0.42)


func _flash_muzzle() -> void:
	if view_root == null:
		return
	var flash: OmniLight3D = OmniLight3D.new()
	flash.name = "TransientMuzzleFlash"
	flash.position = Vector3(0.32, -0.20, -1.35)
	flash.light_color = Color(1.0, 0.67, 0.28)
	flash.light_energy = 2.4
	flash.omni_range = 4.0
	flash.shadow_enabled = false
	view_root.add_child(flash)

	var timer: SceneTreeTimer = get_tree().create_timer(0.045)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(flash):
			flash.queue_free()
	)


func _build_forearms() -> void:
	var sleeve: StandardMaterial3D = _material(Color(0.16, 0.17, 0.105), 0.94)
	var skin: StandardMaterial3D = _material(Color(0.39, 0.255, 0.18), 0.88)
	var glove: StandardMaterial3D = _material(Color(0.075, 0.072, 0.06), 0.96)

	# Arms are deliberately narrow and angled toward the weapon instead of the
	# old capsule/blob silhouette.
	_add_arm("RightArm", Vector3(0.30, -0.37, -0.62), Vector3(-20, -8, -17), sleeve, skin, glove)
	_add_arm("LeftArm", Vector3(-0.19, -0.38, -0.76), Vector3(-25, 10, 21), sleeve, skin, glove)


func _add_arm(name: String, pos: Vector3, rot_deg: Vector3,
		sleeve: Material, skin: Material, glove: Material) -> void:
	var arm: Node3D = Node3D.new()
	arm.name = name
	arm.position = pos
	arm.rotation_degrees = rot_deg
	view_root.add_child(arm)

	var sleeve_mesh: MeshInstance3D = MeshInstance3D.new()
	var sleeve_shape: CylinderMesh = CylinderMesh.new()
	sleeve_shape.top_radius = 0.055
	sleeve_shape.bottom_radius = 0.078
	sleeve_shape.height = 0.48
	sleeve_shape.radial_segments = 16
	sleeve_mesh.mesh = sleeve_shape
	sleeve_mesh.rotation.x = deg_to_rad(90.0)
	sleeve_mesh.position.z = -0.19
	sleeve_mesh.material_override = sleeve
	sleeve_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	arm.add_child(sleeve_mesh)

	var wrist: MeshInstance3D = MeshInstance3D.new()
	var wrist_shape: CylinderMesh = CylinderMesh.new()
	wrist_shape.top_radius = 0.048
	wrist_shape.bottom_radius = 0.055
	wrist_shape.height = 0.16
	wrist_shape.radial_segments = 16
	wrist.mesh = wrist_shape
	wrist.rotation.x = deg_to_rad(90.0)
	wrist.position.z = -0.50
	wrist.material_override = skin
	arm.add_child(wrist)

	var hand: MeshInstance3D = MeshInstance3D.new()
	var hand_shape: BoxMesh = BoxMesh.new()
	hand_shape.size = Vector3(0.105, 0.085, 0.18)
	hand.mesh = hand_shape
	hand.position = Vector3(0.0, -0.005, -0.64)
	hand.rotation.x = deg_to_rad(-8.0)
	hand.material_override = glove
	arm.add_child(hand)

	# Thumb block helps the silhouette read as a hand at FPS distance.
	var thumb: MeshInstance3D = MeshInstance3D.new()
	var thumb_shape: BoxMesh = BoxMesh.new()
	thumb_shape.size = Vector3(0.045, 0.055, 0.11)
	thumb.mesh = thumb_shape
	thumb.position = Vector3(0.065 if name == "RightArm" else -0.065, 0.01, -0.61)
	thumb.rotation.z = deg_to_rad(-28.0 if name == "RightArm" else 28.0)
	thumb.material_override = glove
	arm.add_child(thumb)


func _build_weapon_fill_light() -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "ViewmodelFill"
	light.position = Vector3(0.0, 0.15, -0.35)
	light.light_color = Color(0.72, 0.78, 0.86)
	light.light_energy = 0.32
	light.omni_range = 2.2
	light.shadow_enabled = false
	view_root.add_child(light)


func _build_viewmodel_shadow_catcher() -> void:
	# Very subtle dark plate below the weapon/arms gives the viewmodel stronger
	# contact shading without changing the world renderer.
	var plate: MeshInstance3D = MeshInstance3D.new()
	plate.name = "ViewmodelContactShade"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.95, 0.42)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.01, 0.01, 0.01, 0.08)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad.material = mat
	plate.mesh = quad
	plate.position = Vector3(0.12, -0.48, -0.95)
	plate.rotation.x = deg_to_rad(-82.0)
	view_root.add_child(plate)


func _find_active_camera(node: Node) -> Camera3D:
	if node is Camera3D:
		var candidate: Camera3D = node as Camera3D
		if candidate.current:
			return candidate
	for child: Node in node.get_children():
		var found: Camera3D = _find_active_camera(child)
		if found != null:
			return found
	return null


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat
