extends RefCounted
class_name SquadCoordinator

const SQUAD_SIZE := 4

static func squad_id(peer_id: int) -> int:
	return int(posmod(peer_id, 8) / SQUAD_SIZE)

static func formation_offset(
	peer_id: int,
	squad_role: int,
	leader_forward: Vector3
) -> Vector3:
	squad_role = clampi(squad_role, 0, SQUAD_SIZE - 1)
	var forward: Vector3 = leader_forward
	forward.y = 0.0
	if forward.length() <= 0.01:
		forward = Vector3.FORWARD
	forward = forward.normalized()

	var right: Vector3 = Vector3(-forward.z, 0.0, forward.x)
	var row: int = int(squad_role / 2)
	var side: float = -1.0 if squad_role % 2 == 0 else 1.0
	var spread: float = 2.2 + float(row) * 0.8
	var trailing: float = 2.8 + float(row) * 2.0

	return right * side * spread - forward * trailing

static func order_name(
	team_id: int,
	objective_stage: int,
	dynamite_armed: bool,
	command_post_control: int
) -> String:
	if objective_stage == 0:
		return (
			"BUILD AND SECURE BRIDGE"
			if team_id == 0
			else "HOLD BRIDGE APPROACHES"
		)

	if command_post_control != team_id:
		return "CAPTURE COMMAND POST"

	if dynamite_armed:
		return (
			"PROTECT DYNAMITE"
			if team_id == 0
			else "DEFUSE DYNAMITE"
		)

	return (
		"BREACH BUNKER"
		if team_id == 0
		else "DEFEND BUNKER"
	)

static func target_score(
	observer: Node3D,
	candidate: Node3D,
	claimed_count: int
) -> float:
	if observer == null or candidate == null:
		return -INF

	var distance: float = observer.global_position.distance_to(
		candidate.global_position
	)
	var health_value: float = float(candidate.get("health"))
	var score: float = 120.0 - distance * 2.0
	score += maxf(0.0, 55.0 - health_value) * 0.35
	score -= float(claimed_count) * 24.0
	return score
