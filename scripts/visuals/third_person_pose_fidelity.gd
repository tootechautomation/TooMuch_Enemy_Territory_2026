extends RefCounted
class_name ThirdPersonPoseFidelity

static func apply(
	character_visual: Node3D,
	delta: float,
	animation_time: float,
	speed_ratio: float,
	stride: float,
	moving: bool,
	crouching: bool,
	aiming: bool,
	reloading: bool,
	alive: bool,
	downed: bool
) -> void:
	if character_visual == null:
		return
	var soldier := _find(character_visual, "ArticulatedSoldier")
	if soldier == null:
		return

	var torso := _find(soldier, "TorsoJoint")
	var head := _find(soldier, "HeadJoint")
	var arm_l := _find(soldier, "LeftShoulderJoint")
	var arm_r := _find(soldier, "RightShoulderJoint")
	var leg_l := _find(soldier, "LeftHipJoint")
	var leg_r := _find(soldier, "RightHipJoint")
	var knee_l := _find(leg_l, "KneeJoint")
	var knee_r := _find(leg_r, "KneeJoint")
	var weapon := _find(soldier, "FallbackWeapon")
	var actor: Node = character_visual.get_parent()
	var weapon_profile := 0
	if actor != null:
		weapon_profile = int(actor.get("player_class"))

	var alpha_fast := 1.0 - exp(-14.0 * delta)
	var alpha_body := 1.0 - exp(-9.0 * delta)
	var breath := sin(animation_time * 1.65)
	var opposite_stride := -stride
	var locomotion_amount := lerpf(0.12, 0.58, speed_ratio) if moving else 0.0
	var knee_amount := absf(stride) * lerpf(0.08, 0.38, speed_ratio) if moving else 0.0

	if not alive or downed:
		_pose_incapacitated(soldier, torso, head, arm_l, arm_r, leg_l, leg_r, delta)
		return

	soldier.rotation.z = lerpf(soldier.rotation.z, 0.0, alpha_body)
	soldier.position.y = lerpf(soldier.position.y, -0.04, alpha_body)

	var torso_target := Vector3.ZERO
	torso_target.x = 0.15 if crouching else (-0.10 * speed_ratio if moving else breath * 0.012)
	torso_target.y = -stride * 0.035 * speed_ratio
	torso_target.z = stride * 0.025 * speed_ratio
	if aiming:
		torso_target.y -= 0.10
	if reloading:
		torso_target.y += 0.12
		torso_target.z -= 0.08
	_lerp_rotation(torso, torso_target, alpha_body)

	var head_target := Vector3.ZERO
	head_target.x = -0.10 if crouching else breath * 0.008
	head_target.y = sin(animation_time * 0.58) * 0.035 if not moving and not aiming else 0.0
	head_target.z = -torso_target.z * 0.45
	_lerp_rotation(head, head_target, alpha_body)

	var left_arm_target := Vector3(
		-0.82 + opposite_stride * locomotion_amount * 0.10,
		0.18,
		0.22
	)
	var right_arm_target := Vector3(
		-0.72 + stride * locomotion_amount * 0.08,
		-0.12,
		-0.16
	)
	match weapon_profile:
		0:
			left_arm_target += Vector3(-0.10, 0.05, 0.06)
			right_arm_target += Vector3(-0.06, -0.02, -0.03)
		1:
			left_arm_target += Vector3(0.12, -0.08, -0.08)
			right_arm_target += Vector3(0.08, 0.02, 0.04)
		2:
			left_arm_target += Vector3(0.06, -0.03, -0.04)
		4:
			left_arm_target += Vector3(-0.08, 0.03, 0.05)
		_:
			pass
	if reloading:
		var reload_work := sin(animation_time * 5.2)
		left_arm_target = Vector3(-1.18 + reload_work * 0.10, 0.38, 0.42)
		right_arm_target = Vector3(-0.62, -0.30, -0.22)
	elif aiming:
		left_arm_target += Vector3(-0.20, 0.04, 0.08)
		right_arm_target += Vector3(-0.16, -0.02, -0.04)
	elif crouching:
		left_arm_target.x -= 0.24
		right_arm_target.x -= 0.18
	_lerp_rotation(arm_l, left_arm_target, alpha_fast)
	_lerp_rotation(arm_r, right_arm_target, alpha_fast)

	var left_leg_target := Vector3(stride * locomotion_amount, 0.0, 0.025)
	var right_leg_target := Vector3(opposite_stride * locomotion_amount, 0.0, -0.025)
	if crouching:
		left_leg_target.x -= 0.44
		right_leg_target.x -= 0.44
		left_leg_target.z += 0.08
		right_leg_target.z -= 0.08
	_lerp_rotation(leg_l, left_leg_target, alpha_fast)
	_lerp_rotation(leg_r, right_leg_target, alpha_fast)
	_lerp_rotation(knee_l, Vector3(knee_amount + (0.42 if crouching else 0.0), 0.0, 0.0), alpha_fast)
	_lerp_rotation(knee_r, Vector3(knee_amount + (0.42 if crouching else 0.0), 0.0, 0.0), alpha_fast)

	if weapon != null:
		var weapon_rotation := Vector3(-0.10, 0.0, 0.0)
		var weapon_position := Vector3(0.05, 0.03, -0.42)
		if aiming:
			weapon_rotation = Vector3(-0.28, -0.03, 0.02)
			weapon_position = Vector3(0.02, 0.10, -0.50)
		elif reloading:
			weapon_rotation = Vector3(0.24, 0.28, -0.18)
			weapon_position = Vector3(0.14, -0.05, -0.36)
		elif moving:
			weapon_rotation.z = stride * 0.025 * speed_ratio
		weapon.rotation = weapon.rotation.lerp(weapon_rotation, alpha_fast)
		weapon.position = weapon.position.lerp(weapon_position, alpha_fast)

static func _pose_incapacitated(
	soldier: Node3D,
	torso: Node3D,
	head: Node3D,
	arm_l: Node3D,
	arm_r: Node3D,
	leg_l: Node3D,
	leg_r: Node3D,
	delta: float
) -> void:
	var alpha := 1.0 - exp(-7.0 * delta)
	soldier.rotation.z = lerpf(soldier.rotation.z, 1.34, alpha)
	soldier.position.y = lerpf(soldier.position.y, -0.72, alpha)
	_lerp_rotation(torso, Vector3(0.22, 0.0, -0.16), alpha)
	_lerp_rotation(head, Vector3(-0.18, 0.12, 0.10), alpha)
	_lerp_rotation(arm_l, Vector3(-0.55, 0.18, 0.52), alpha)
	_lerp_rotation(arm_r, Vector3(0.48, -0.14, -0.35), alpha)
	_lerp_rotation(leg_l, Vector3(0.20, 0.0, 0.16), alpha)
	_lerp_rotation(leg_r, Vector3(-0.32, 0.0, -0.12), alpha)

static func _find(root: Node, node_name: String) -> Node3D:
	if root == null:
		return null
	if root.name == node_name and root is Node3D:
		return root as Node3D
	return root.find_child(node_name, true, false) as Node3D

static func _lerp_rotation(node: Node3D, target: Vector3, alpha: float) -> void:
	if node == null:
		return
	node.rotation = node.rotation.lerp(target, alpha)
