extends RefCounted
class_name TacticalDirector

static func tactical_anchor(
	bot: Node3D,
	class_id: int,
	squad_role: int,
	objective_stage: int,
	base_goal: Vector3
) -> Vector3:
	if bot == null:
		return Vector3.ZERO

	var bot_team: int = int(bot.get("team"))

	var attacker_bridge_anchors: Array[Vector3] = [
		Vector3(-18.0, 1.0, -15.0),
		Vector3(-12.0, 1.0, 0.0),
		Vector3(-18.0, 1.0, 15.0),
		Vector3(-29.0, 1.0, 10.0)
	]
	var defender_bridge_anchors: Array[Vector3] = [
		Vector3(13.0, 1.0, -14.0),
		Vector3(10.0, 1.0, 1.0),
		Vector3(16.0, 1.0, 15.0),
		Vector3(27.0, 1.0, 9.0)
	]
	var attacker_bunker_anchors: Array[Vector3] = [
		Vector3(15.0, 1.0, -17.0),
		Vector3(22.0, 1.0, 5.0),
		Vector3(20.0, 1.0, 22.0),
		Vector3(8.0, 1.0, 34.0)
	]
	var defender_bunker_anchors: Array[Vector3] = [
		Vector3(31.0, 1.0, 17.0),
		Vector3(25.0, 1.0, 28.0),
		Vector3(38.0, 1.0, 35.0),
		Vector3(43.0, 1.0, 19.0)
	]

	var anchors: Array[Vector3]
	if objective_stage == 0:
		anchors = (
			attacker_bridge_anchors
			if bot_team == 0
			else defender_bridge_anchors
		)
	else:
		anchors = (
			attacker_bunker_anchors
			if bot_team == 0
			else defender_bunker_anchors
		)

	var role_index: int = posmod(squad_role, anchors.size())
	var anchor: Vector3 = anchors[role_index]

	match class_id:
		0:
			return base_goal.lerp(anchor, 0.30)
		1:
			return anchor.lerp(base_goal, 0.45)
		2:
			return base_goal
		3:
			return anchor
		4:
			var scout_index: int = (
				(role_index + 2) % anchors.size()
			)
			return anchors[scout_index]
		_:
			return anchor

static func cover_position(
	bot: Node3D,
	threat_position: Vector3
) -> Vector3:
	if bot == null:
		return Vector3.ZERO

	var world: World3D = bot.get_world_3d()
	if world == null:
		return bot.global_position

	var origin: Vector3 = bot.global_position
	var away: Vector3 = origin - threat_position
	away.y = 0.0
	if away.length() <= 0.01:
		away = Vector3.RIGHT
	away = away.normalized()

	var side_sign: float = (
		-1.0
		if posmod(int(bot.get("peer_id")), 2) == 0
		else 1.0
	)
	var lateral: Vector3 = Vector3(
		-away.z,
		0.0,
		away.x
	) * side_sign

	var candidates: Array[Vector3] = [
		origin + away * 7.0 + lateral * 3.0,
		origin + away * 5.0 - lateral * 4.0,
		origin + lateral * 7.0,
		origin - lateral * 7.0
	]

	var space_state: PhysicsDirectSpaceState3D = (
		world.direct_space_state
	)
	var best_position: Vector3 = origin + away * 5.0
	var best_score: float = -INF

	for candidate in candidates:
		var floor_query := PhysicsRayQueryParameters3D.create(
			candidate + Vector3.UP * 4.0,
			candidate + Vector3.DOWN * 8.0
		)
		floor_query.collision_mask = 1
		floor_query.collide_with_areas = false
		floor_query.collide_with_bodies = true
		var floor_hit: Dictionary = space_state.intersect_ray(
			floor_query
		)
		if floor_hit.is_empty():
			continue

		var floor_position: Vector3 = Vector3(
			floor_hit.get("position", candidate)
		) + Vector3.UP

		var threat_eye: Vector3 = threat_position + Vector3.UP * 1.4
		var cover_eye: Vector3 = floor_position + Vector3.UP * 1.2
		var sight_query := PhysicsRayQueryParameters3D.create(
			threat_eye,
			cover_eye
		)
		sight_query.collision_mask = 1
		sight_query.collide_with_areas = false
		sight_query.collide_with_bodies = true
		var sight_hit: Dictionary = space_state.intersect_ray(
			sight_query
		)

		var distance_from_threat: float = (
			floor_position.distance_to(threat_position)
		)
		var travel_distance: float = (
			floor_position.distance_to(origin)
		)
		var blocked_bonus: float = (
			20.0 if not sight_hit.is_empty() else 0.0
		)
		var score: float = (
			blocked_bonus
			+ distance_from_threat * 0.35
			- travel_distance * 0.20
		)

		if score > best_score:
			best_score = score
			best_position = floor_position

	return best_position
