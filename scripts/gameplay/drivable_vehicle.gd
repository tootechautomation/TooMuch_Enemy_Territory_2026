extends CharacterBody3D
class_name DrivableVehicle

enum VehicleType { JEEP, TANK, AIRCRAFT }

var vehicle_id := -1
var vehicle_type := VehicleType.JEEP
var team_id := 0
var driver_peer_id := 0
var health := 500
var max_health := 500

var throttle_input := 0.0
var steering_input := 0.0
var pitch_input := 0.0
var target_position := Vector3.ZERO
var target_yaw := 0.0
var target_pitch := 0.0
var aircraft_pitch := 0.0
var aircraft_roll := 0.0

var visual_root: Node3D

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

func display_name() -> String:
	match vehicle_type:
		VehicleType.JEEP: return "JEEP"
		VehicleType.TANK: return "TANK"
		VehicleType.AIRCRAFT: return "FIGHTER"
	return "VEHICLE"

func can_enter(peer_id: int, player_position: Vector3) -> bool:
	return driver_peer_id == 0 and global_position.distance_to(player_position) <= 5.5

func server_enter(peer_id: int) -> bool:
	if not multiplayer.is_server() or driver_peer_id != 0:
		return false
	driver_peer_id = peer_id
	return true

func server_exit(peer_id: int) -> bool:
	if not multiplayer.is_server() or driver_peer_id != peer_id:
		return false
	driver_peer_id = 0
	throttle_input = 0.0
	steering_input = 0.0
	pitch_input = 0.0
	return true

func server_set_input(
	peer_id: int,
	throttle: float,
	steering: float,
	pitch: float
) -> void:
	if not multiplayer.is_server() or driver_peer_id != peer_id:
		return
	throttle_input = clampf(throttle, -1.0, 1.0)
	steering_input = clampf(steering, -1.0, 1.0)
	pitch_input = clampf(pitch, -1.0, 1.0)

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

func _server_simulate(delta: float) -> void:
	if health <= 0:
		return

	if driver_peer_id == 0:
		throttle_input = 0.0
		steering_input = 0.0
		pitch_input = 0.0

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
			candidates = [
				"res://assets/external/vehicles/willys_jeep.glb",
				"res://assets/external/vehicles/jeep_willys.glb"
			]
		VehicleType.TANK:
			candidates = [
				"res://assets/external/vehicles/m4_sherman.glb",
				"res://assets/external/vehicles/sherman.glb"
			]
		VehicleType.AIRCRAFT:
			candidates = [
				"res://assets/external/vehicles/spitfire.glb",
				"res://assets/external/vehicles/bf109.glb"
			]
	for path: String in candidates:
		if ResourceLoader.exists(path):
			var resource := load(path)
			if resource is PackedScene:
				var node := (resource as PackedScene).instantiate()
				if node is Node3D:
					(node as Node3D).name = "ExternalVehicleModel"
					visual_root.add_child(node)
					return true
	return false

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
