extends CharacterBody3D

const GRAVITY := 18.0
const BOUNCE_FACTOR := 0.42
const POSITION_SYNC_INTERVAL := 0.05

var grenade_id := 0
var owner_id := 0
var owner_team := 0
var fuse_remaining := 3.0
var explosion_radius := 5.5
var maximum_damage := 95
var sync_accumulator := 0.0
var target_position := Vector3.ZERO
var target_velocity := Vector3.ZERO

func configure(
	new_grenade_id: int,
	new_owner_id: int,
	new_owner_team: int,
	spawn_position: Vector3,
	initial_velocity: Vector3,
	fuse_seconds: float
) -> void:
	grenade_id = new_grenade_id
	owner_id = new_owner_id
	owner_team = new_owner_team
	global_position = spawn_position
	target_position = spawn_position
	velocity = initial_velocity
	target_velocity = initial_velocity
	fuse_remaining = fuse_seconds

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_simulate(delta)
	else:
		global_position = global_position.lerp(
			target_position,
			clampf(delta * 18.0, 0.0, 1.0)
		)
		velocity = target_velocity

func _server_simulate(delta: float) -> void:
	fuse_remaining = maxf(0.0, fuse_remaining - delta)
	velocity.y -= GRAVITY * delta

	var collision: KinematicCollision3D = move_and_collide(velocity * delta)
	if collision != null:
		var normal: Vector3 = collision.get_normal()
		velocity = velocity.bounce(normal) * BOUNCE_FACTOR
		if absf(normal.y) > 0.55:
			velocity.x *= 0.78
			velocity.z *= 0.78

	sync_accumulator += delta
	if sync_accumulator >= POSITION_SYNC_INTERVAL:
		sync_accumulator = 0.0
		sync_state.rpc(global_position, velocity, fuse_remaining)

	if fuse_remaining <= 0.0:
		var main: Node = get_parent()
		if main != null and main.has_method("server_explode_grenade"):
			main.call(
				"server_explode_grenade",
				grenade_id,
				global_position,
				owner_id,
				owner_team,
				explosion_radius,
				maximum_damage
			)

@rpc("authority", "call_remote", "unreliable_ordered")
func sync_state(
	server_position: Vector3,
	server_velocity: Vector3,
	server_fuse: float
) -> void:
	if multiplayer.is_server():
		return
	target_position = server_position
	target_velocity = server_velocity
	fuse_remaining = server_fuse
