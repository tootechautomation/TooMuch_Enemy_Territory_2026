extends CharacterBody3D
class_name DrivableVehicle

enum VehicleType { JEEP, TANK, AIRCRAFT }

var vehicle_id := -1
var vehicle_type := VehicleType.JEEP
var team_id := 0
var driver_peer_id := 0
var gunner_peer_id := 0
var health := 500
var max_health := 500

var throttle_input := 0.0
var steering_input := 0.0
var pitch_input := 0.0
var fire_input := false
var destroyed := false
var target_position := Vector3.ZERO
var target_yaw := 0.0
var target_pitch := 0.0
var aircraft_pitch := 0.0
var aircraft_roll := 0.0
var turret_yaw := 0.0
var turret_target_yaw := 0.0

var visual_root: Node3D
var spawn_position_saved := Vector3.ZERO
var spawn_yaw_saved := 0.0

const JEEP_SPEED := 18.0
const TANK_SPEED := 9.0
const AIR_SPEED_MIN := 12.0
const AIR_SPEED_MAX := 42.0

func configure(
	new_id: int,
	new_type: int,
	new_team: int,
	spawn_position: Vector3,
	spawn_yaw: float
) -> void:
	vehicle_id = new_id
	vehicle_type = clampi(new_type, 0, 2)
	team_id = clampi(new_team, 0, 1)
	global_position = spawn_position
	rotation.y = spawn_yaw
	spawn_position_saved = spawn_position
	spawn_yaw_saved = spawn_yaw
	target_position = global_position
	target_yaw = rotation.y

	match vehicle_type:
		VehicleType.JEEP: max_health = 420
		VehicleType.TANK: max_health = 1400
		VehicleType.AIRCRAFT: max_health = 650
	health = max_health

	_build_collision()
	if DisplayServer.get_name() != "headless":
		_build_visual()

func current_speed_kph() -> float:
	return velocity.length() * 3.6


func weapon_origin() -> Vector3:
	var height := 1.25
	var forward_offset := 2.0

	if vehicle_type == VehicleType.TANK:
		height = 1.85
		forward_offset = 3.4
	elif vehicle_type == VehicleType.AIRCRAFT:
		height = 0.35
		forward_offset = 3.8

	var direction := weapon_direction()
	return global_position + Vector3.UP * height + direction * forward_offset


func weapon_direction() -> Vector3:
	if vehicle_type == VehicleType.TANK:
		var turret_basis := Basis(Vector3.UP, rotation.y + turret_yaw)
		return (-turret_basis.z).normalized()

	if vehicle_type == VehicleType.JEEP and gunner_peer_id != 0:
		var gunner_basis := Basis(Vector3.UP, rotation.y + turret_yaw)
		return (-gunner_basis.z).normalized()

	return (-global_transform.basis.z).normalized()


func weapon_damage() -> int:
	if vehicle_type == VehicleType.TANK:
		return 185
	if vehicle_type == VehicleType.AIRCRAFT:
		return 22
	if vehicle_type == VehicleType.JEEP and gunner_peer_id != 0:
		return 18
	return 0


func weapon_range() -> float:
	if vehicle_type == VehicleType.TANK:
		return 120.0
	if vehicle_type == VehicleType.AIRCRAFT:
		return 150.0
	if vehicle_type == VehicleType.JEEP and gunner_peer_id != 0:
		return 95.0
	return 0.0


func weapon_cooldown_ms() -> int:
	if vehicle_type == VehicleType.TANK:
		return 1700
	if vehicle_type == VehicleType.AIRCRAFT:
		return 105
	if vehicle_type == VehicleType.JEEP and gunner_peer_id != 0:
		return 120
	return 999999


func impact_scale() -> float:
	return 1.8 if vehicle_type == VehicleType.TANK else 0.55


func server_apply_damage(amount: int) -> bool:
	if not multiplayer.is_server() or destroyed:
		return false
	health = maxi(0, health - maxi(0, amount))
	if health <= 0:
		destroyed = true
		driver_peer_id = 0
		throttle_input = 0.0
		steering_input = 0.0
		pitch_input = 0.0
		fire_input = false
		velocity = Vector3.ZERO
		return true
	return false


func set_destroyed_visual() -> void:
	destroyed = true
	if visual_root != null:
		visual_root.rotation_degrees.z = 7.0
		visual_root.scale *= 0.98


func display_name() -> String:
	match vehicle_type:
		VehicleType.JEEP: return "JEEP"
		VehicleType.TANK: return "TANK"
		VehicleType.AIRCRAFT: return "FIGHTER"
	return "VEHICLE"

func can_enter(peer_id: int, player_position: Vector3) -> bool:
	if destroyed:
		return false
	if global_position.distance_to(player_position) > 5.5:
		return false
	return driver_peer_id == 0 or _supports_gunner_seat() and gunner_peer_id == 0


func _supports_gunner_seat() -> bool:
	return vehicle_type == VehicleType.JEEP or vehicle_type == VehicleType.TANK


func available_seat_for(peer_id: int) -> int:
	if destroyed:
		return -1
	if driver_peer_id == 0:
		return 0
	if _supports_gunner_seat() and gunner_peer_id == 0:
		return 1
	return -1

func server_enter(peer_id: int) -> int:
	if not multiplayer.is_server() or destroyed:
		return -1

	if driver_peer_id == 0:
		driver_peer_id = peer_id
		return 0

	if _supports_gunner_seat() and gunner_peer_id == 0:
		gunner_peer_id = peer_id
		return 1

	return -1


func server_exit(peer_id: int) -> bool:
	if not multiplayer.is_server():
		return false

	var exited := false
	if driver_peer_id == peer_id:
		driver_peer_id = 0
		exited = true
	if gunner_peer_id == peer_id:
		gunner_peer_id = 0
		exited = true

	if exited:
		throttle_input = 0.0
		steering_input = 0.0
		pitch_input = 0.0
		fire_input = false

	return exited


func peer_seat(peer_id: int) -> int:
	if driver_peer_id == peer_id:
		return 0
	if gunner_peer_id == peer_id:
		return 1
	return -1



func server_set_input(
	peer_id: int,
	throttle: float,
	steering: float,
	pitch: float,
	fire_pressed: bool
) -> void:
	if not multiplayer.is_server() or driver_peer_id != peer_id:
		return
	if destroyed:
		return
	throttle_input = clampf(throttle, -1.0, 1.0)
	steering_input = clampf(steering, -1.0, 1.0)
	pitch_input = clampf(pitch, -1.0, 1.0)
	fire_input = fire_pressed

func server_set_gunner_input(
	peer_id: int,
	yaw_delta: float,
	fire_pressed: bool
) -> void:
	if not multiplayer.is_server():
		return
	if gunner_peer_id != peer_id:
		return
	if destroyed:
		return

	turret_target_yaw += clampf(yaw_delta, -1.0, 1.0) * 0.055
	fire_input = fire_pressed


func seat_position_for(peer_id: int) -> Vector3:
	var seat := peer_seat(peer_id)
	if seat == 1:
		var offset := Vector3(0.0, 1.55, 0.15)
		if vehicle_type == VehicleType.JEEP:
			offset = Vector3(0.0, 1.25, 0.35)
		return global_position + global_transform.basis * offset
	return seat_position()


func weapon_owner_peer() -> int:
	if _supports_gunner_seat() and gunner_peer_id != 0:
		return gunner_peer_id
	return driver_peer_id


func reset_for_respawn() -> void:
	destroyed = false
	health = max_health
	driver_peer_id = 0
	gunner_peer_id = 0
	throttle_input = 0.0
	steering_input = 0.0
	pitch_input = 0.0
	fire_input = false
	velocity = Vector3.ZERO
	global_position = spawn_position_saved
	rotation = Vector3(0.0, spawn_yaw_saved, 0.0)
	target_position = global_position
	target_yaw = rotation.y
	target_pitch = 0.0
	turret_yaw = 0.0
	turret_target_yaw = 0.0

	if visual_root != null:
		visual_root.rotation_degrees = Vector3.ZERO
		visual_root.scale = Vector3.ONE


func seat_position() -> Vector3:
	var up_offset := 1.05
	if vehicle_type == VehicleType.TANK:
		up_offset = 1.35
	elif vehicle_type == VehicleType.AIRCRAFT:
		up_offset = 1.05
	return global_position + Vector3.UP * up_offset


func exit_position() -> Vector3:
	var side_distance := 2.8
	if vehicle_type == VehicleType.TANK:
		side_distance = 3.2
	elif vehicle_type == VehicleType.AIRCRAFT:
		side_distance = 4.8

	var exit_pos := (
		global_position
		+ global_transform.basis.x * side_distance
		+ Vector3.UP * 1.15
	)
	exit_pos.y = maxf(exit_pos.y, 1.15)
	return exit_pos

func camera_anchor() -> Transform3D:
	var offset := Vector3(0.0, 2.7, 6.0)
	if vehicle_type == VehicleType.TANK:
		offset = Vector3(0.0, 3.4, 7.4)
	elif vehicle_type == VehicleType.AIRCRAFT:
		offset = Vector3(0.0, 2.4, 9.0)
	var basis := global_transform.basis
	return Transform3D(
		basis,
		global_position + basis.y * offset.y + basis.z * offset.z
	)

func apply_network_snapshot(
	position: Vector3,
	yaw: float,
	pitch_value: float,
	new_health: int,
	new_driver: int
) -> void:
	target_position = position
	target_yaw = yaw
	target_pitch = pitch_value
	health = new_health
	driver_peer_id = new_driver

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_simulate(delta)
	else:
		global_position = global_position.lerp(
			target_position,
			1.0 - exp(-10.0 * delta)
		)
		rotation.y = lerp_angle(
			rotation.y,
			target_yaw,
			1.0 - exp(-12.0 * delta)
		)
		if vehicle_type == VehicleType.AIRCRAFT:
			rotation.x = lerp_angle(
				rotation.x,
				target_pitch,
				1.0 - exp(-8.0 * delta)
			)
	_animate_vehicle_visuals(delta)

func _update_turret_visual() -> void:
	if visual_root == null:
		return

	for node: Node in visual_root.find_children("*turret*", "", true):
		if node is Node3D:
			(node as Node3D).rotation.y = turret_yaw

	for node: Node in visual_root.find_children("*gun*", "", true):
		if (
			node is Node3D
			and vehicle_type == VehicleType.JEEP
		):
			(node as Node3D).rotation.y = turret_yaw


func _animate_vehicle_visuals(delta: float) -> void:
	if visual_root == null:
		return

	var speed: float = velocity.length()

	if vehicle_type == VehicleType.JEEP:
		for wheel_node: Node in visual_root.find_children("*wheel*", "", true):
			if wheel_node is Node3D:
				(wheel_node as Node3D).rotate_x(speed * delta * 1.8)

	elif vehicle_type == VehicleType.AIRCRAFT:
		for prop_node: Node in visual_root.find_children("*prop*", "", true):
			if prop_node is Node3D:
				(prop_node as Node3D).rotate_z(
					maxf(12.0, speed * 2.4) * delta
				)


func _server_simulate(delta: float) -> void:
	turret_yaw = lerp_angle(
		turret_yaw,
		turret_target_yaw,
		1.0 - exp(-8.0 * delta)
	)
	_update_turret_visual()

	if health <= 0 or destroyed:
		return

	if driver_peer_id == 0:
		throttle_input = 0.0
		steering_input = 0.0
		pitch_input = 0.0
		fire_input = false

		if vehicle_type == VehicleType.AIRCRAFT:
			velocity = Vector3.ZERO
			return

		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		velocity.y = -0.5 if is_on_floor() else velocity.y - 18.0 * delta
		move_and_slide()
		return

	if vehicle_type == VehicleType.AIRCRAFT:
		_simulate_aircraft(delta)
	else:
		var max_speed := JEEP_SPEED if vehicle_type == VehicleType.JEEP else TANK_SPEED
		var accel := 22.0 if vehicle_type == VehicleType.JEEP else 12.0
		var turn_rate := 1.65 if vehicle_type == VehicleType.JEEP else 0.90
		_simulate_ground(delta, max_speed, accel, turn_rate)

func _simulate_ground(
	delta: float,
	max_speed: float,
	accel: float,
	turn_rate: float
) -> void:
	var forward := -global_transform.basis.z
	var current_speed := velocity.dot(forward)
	var desired_speed := throttle_input * max_speed
	current_speed = move_toward(current_speed, desired_speed, accel * delta)

	rotation.y -= steering_input * turn_rate * delta * (
		0.35 + minf(absf(current_speed) / max_speed, 1.0)
	)

	forward = -global_transform.basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	velocity.y = -0.5 if is_on_floor() else velocity.y - 18.0 * delta
	move_and_slide()

func _simulate_aircraft(delta: float) -> void:
	var speed := clampf(
		maxf(velocity.length(), AIR_SPEED_MIN)
		+ throttle_input * 14.0 * delta,
		AIR_SPEED_MIN,
		AIR_SPEED_MAX
	)

	aircraft_pitch = clampf(
		aircraft_pitch + pitch_input * 0.85 * delta,
		-0.75,
		0.75
	)
	aircraft_roll = lerpf(
		aircraft_roll,
		-steering_input * 0.70,
		1.0 - exp(-3.5 * delta)
	)

	rotation.x = aircraft_pitch
	rotation.z = aircraft_roll
	rotation.y -= steering_input * 0.52 * delta

	velocity = -global_transform.basis.z * speed
	if global_position.y < 1.8 and velocity.y < 0.0:
		global_position.y = 1.8
		velocity.y = 0.0
	move_and_slide()

func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	collision.name = "VehicleCollision"
	var box := BoxShape3D.new()

	match vehicle_type:
		VehicleType.JEEP:
			box.size = Vector3(2.0, 1.4, 3.6)
			collision.position.y = 0.72
		VehicleType.TANK:
			box.size = Vector3(3.2, 2.2, 5.7)
			collision.position.y = 1.08
		VehicleType.AIRCRAFT:
			box.size = Vector3(8.2, 1.8, 6.0)
			collision.position.y = 0.92

	collision.shape = box
	add_child(collision)

func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "VehicleVisual"
	add_child(visual_root)
	if _try_external_model():
		return
	match vehicle_type:
		VehicleType.JEEP: _fallback_jeep()
		VehicleType.TANK: _fallback_tank()
		VehicleType.AIRCRAFT: _fallback_aircraft()

func _try_external_model() -> bool:
	var candidates: Array[String] = []

	match vehicle_type:
		VehicleType.JEEP:
			candidates.append(
				"res://assets/external/vehicles/willys_jeep.glb"
			)
			candidates.append(
				"res://assets/external/vehicles/jeep_willys.glb"
			)

		VehicleType.TANK:
			candidates.append(
				"res://assets/external/vehicles/m4_sherman.glb"
			)
			candidates.append(
				"res://assets/external/vehicles/sherman.glb"
			)

		VehicleType.AIRCRAFT:
			# Keep Array[String] strongly typed. Godot 4 can infer a ternary
			# expression containing array literals as generic Array, which then
			# cannot be assigned to Array[String].
			if team_id == 0:
				candidates.append(
					"res://assets/external/vehicles/spitfire.glb"
				)
			else:
				candidates.append(
					"res://assets/external/vehicles/bf109.glb"
				)

	for path: String in candidates:
		if not ResourceLoader.exists(path):
			continue

		var resource: Resource = load(path)
		if not resource is PackedScene:
			continue

		var node: Node = (resource as PackedScene).instantiate()
		if not node is Node3D:
			node.queue_free()
			continue

		var model := node as Node3D
		model.name = "ExternalVehicleModel"
		visual_root.add_child(model)

		_prepare_external_vehicle_model(model, path)
		return true

	return false


func _prepare_external_vehicle_model(
	model: Node3D,
	resource_path: String
) -> void:
	var lower_path := resource_path.to_lower()

	# The uploaded Willys GLB includes a large decorative "ground" mesh.
	# Remove/hide it so only the Jeep itself is used in gameplay.
	for descendant: Node in model.find_children("*", "", true):
		if "ground" in descendant.name.to_lower():
			if descendant is GeometryInstance3D:
				(descendant as GeometryInstance3D).visible = false

	# Asset-specific normalization. These values are tuned to the uploaded GLBs,
	# not generic assumptions about all future models.
	if "willys_jeep" in lower_path:
		# Source scene is imported at a very large authoring scale.
		model.scale = Vector3.ONE * 0.0035
		model.position = Vector3(-0.03, 2.53, 0.0)
		model.rotation_degrees = Vector3.ZERO

	elif "m4_sherman" in lower_path or "sherman" in lower_path:
		model.scale = Vector3.ONE * 0.85
		model.position = Vector3(0.0, 0.03, 0.0)
		model.rotation_degrees = Vector3.ZERO

	elif "spitfire" in lower_path:
		model.scale = Vector3.ONE * 0.75
		model.position = Vector3(0.0, 0.72, -0.15)
		model.rotation_degrees = Vector3.ZERO

	elif "bf109" in lower_path:
		model.scale = Vector3.ONE * 0.82
		model.position = Vector3(0.0, 0.02, 0.0)
		model.rotation_degrees = Vector3.ZERO

	_apply_external_model_performance_settings(model)


func _apply_external_model_performance_settings(model: Node3D) -> void:
	for descendant: Node in model.find_children("*", "", true):
		if descendant is GeometryInstance3D:
			var geometry := descendant as GeometryInstance3D
			geometry.visibility_range_end = (
				85.0
				if vehicle_type == VehicleType.AIRCRAFT
				else 65.0
			)
			geometry.visibility_range_end_margin = 8.0
			geometry.visibility_range_fade_mode = (
				GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			)

			# Vehicle models can be material-heavy; avoid every submesh becoming
			# an expensive long-range dynamic shadow caster.
			if vehicle_type == VehicleType.AIRCRAFT:
				geometry.cast_shadow = (
					GeometryInstance3D.SHADOW_CASTING_SETTING_ON
				)



func _team_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = (
		Color(0.24, 0.29, 0.18)
		if team_id == 0
		else Color(0.25, 0.24, 0.20)
	)
	mat.roughness = 0.86
	mat.metallic = 0.12
	return mat

func _dark_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.07, 0.07, 0.065)
	mat.roughness = 0.72
	mat.metallic = 0.32
	return mat

func _box(
	node_name: String,
	position: Vector3,
	size: Vector3,
	material: Material
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = position
	mi.material_override = material
	visual_root.add_child(mi)
	return mi

func _cyl(
	node_name: String,
	position: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_value: Vector3
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mi.mesh = mesh
	mi.position = position
	mi.rotation_degrees = rotation_value
	mi.material_override = material
	visual_root.add_child(mi)
	return mi

func _fallback_jeep() -> void:
	var body := _team_material()
	var dark := _dark_material()
	_box("JeepBody", Vector3(0,0.58,0), Vector3(1.85,0.55,3.15), body)
	_box("JeepHood", Vector3(0,0.85,-1.0), Vector3(1.70,0.35,1.20), body)
	_box("JeepCab", Vector3(0,1.10,0.55), Vector3(1.55,0.50,1.15), body)
	for x: float in [-0.95,0.95]:
		for z: float in [-1.05,1.05]:
			_cyl("JeepWheel",Vector3(x,0.42,z),0.42,0.24,dark,Vector3(0,0,90))

func _fallback_tank() -> void:
	var body := _team_material()
	var dark := _dark_material()
	_box("TankHull",Vector3(0,0.70,0),Vector3(3.0,1.20,5.0),body)
	_box("TankUpperHull",Vector3(0,1.35,-0.15),Vector3(2.35,0.60,2.65),body)
	_box("TankLeftTrack",Vector3(-1.55,0.40,0),Vector3(0.52,0.75,4.9),dark)
	_box("TankRightTrack",Vector3(1.55,0.40,0),Vector3(0.52,0.75,4.9),dark)
	var turret := _cyl("TankTurret",Vector3(0,1.75,-0.25),0.90,0.65,body,Vector3.ZERO)
	var gun := _cyl("TankCannon",Vector3(0,1.75,-2.0),0.11,3.4,dark,Vector3(90,0,0))

func _fallback_aircraft() -> void:
	var body := _team_material()
	var dark := _dark_material()
	_box("AircraftFuselage",Vector3(0,0,0),Vector3(0.85,0.85,5.5),body)
	_box("AircraftWing",Vector3(0,-0.05,0.25),Vector3(8.0,0.18,1.35),body)
	_box("AircraftTailWing",Vector3(0,0.05,2.20),Vector3(3.0,0.12,0.70),body)
	_box("AircraftTail",Vector3(0,0.65,2.20),Vector3(0.15,1.30,0.80),body)
	_cyl("PropellerHub",Vector3(0,0,-3.0),0.18,0.35,dark,Vector3(90,0,0))
