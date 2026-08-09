extends Node
class_name RemotePlayerPresentationLOD

var world_root: Node
var quality_manager: Node
var update_accumulator := 0.0

const UPDATE_INTERVAL := 0.35

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	_apply_all_players()


func on_quality_changed() -> void:
	_apply_all_players()


func _process(delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return

	update_accumulator += delta
	if update_accumulator < UPDATE_INTERVAL:
		return
	update_accumulator = 0.0

	_apply_all_players()


func _apply_all_players() -> void:
	if world_root == null or quality_manager == null:
		return

	var players_value: Variant = world_root.get("players")
	if not players_value is Dictionary:
		return

	var players: Dictionary = players_value
	var local_peer_id: int = multiplayer.get_unique_id()
	var local_player: Node3D = players.get(local_peer_id) as Node3D

	for peer_value: Variant in players:
		var peer_id := int(peer_value)
		var player: Node3D = players.get(peer_id) as Node3D
		if player == null or not is_instance_valid(player):
			continue

		if peer_id == local_peer_id:
			_restore_local_player(player)
			continue

		var distance := 9999.0
		if local_player != null and is_instance_valid(local_player):
			distance = local_player.global_position.distance_to(
				player.global_position
			)

		_apply_remote_player(player, distance)


func _apply_remote_player(player: Node3D, distance: float) -> void:
	var preset := clampi(int(quality_manager.get("current_preset")), 0, 2)

	var near_distance := 18.0 if preset == 0 else 28.0 if preset == 1 else 42.0
	var medium_distance := 38.0 if preset == 0 else 55.0 if preset == 1 else 78.0

	for child: Node in player.find_children("*", "", true):
		if child == null:
			continue

		var key := child.name.to_lower()

		if child is GeometryInstance3D:
			var geometry := child as GeometryInstance3D
			_cache_geometry(geometry)

			if _is_weapon_cosmetic(key):
				geometry.visibility_range_end = medium_distance
				geometry.visibility_range_end_margin = 5.0
				geometry.visibility_range_fade_mode = (
					GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				)

				if preset == 0 or distance > near_distance:
					geometry.cast_shadow = (
						GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					)
				else:
					_restore_shadow(geometry)

			elif _is_small_cosmetic(key):
				geometry.visibility_range_end = near_distance
				geometry.visibility_range_end_margin = 4.0
				geometry.visibility_range_fade_mode = (
					GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				)
				geometry.cast_shadow = (
					GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				)

			else:
				if (
					(preset == 0 and distance > 22.0)
					or (preset == 1 and distance > 38.0)
				):
					geometry.cast_shadow = (
						GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					)
				else:
					_restore_shadow(geometry)

		elif child is Label3D:
			var label := child as Label3D
			_cache_label(label)

			if _is_player_label(key):
				label.visibility_range_end = (
					18.0 if preset == 0
					else 28.0 if preset == 1
					else 42.0
				)
				label.visibility_range_end_margin = 3.0
				label.visibility_range_fade_mode = (
					GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				)


func _restore_local_player(player: Node3D) -> void:
	for child: Node in player.find_children("*", "", true):
		if child is GeometryInstance3D:
			var geometry := child as GeometryInstance3D
			if geometry.has_meta("v892_original_shadow"):
				geometry.cast_shadow = int(
					geometry.get_meta("v892_original_shadow")
				)
			if geometry.has_meta("v892_original_visibility_end"):
				geometry.visibility_range_end = float(
					geometry.get_meta("v892_original_visibility_end")
				)

		elif child is Label3D:
			var label := child as Label3D
			if label.has_meta("v892_original_label_end"):
				label.visibility_range_end = float(
					label.get_meta("v892_original_label_end")
				)


func _cache_geometry(geometry: GeometryInstance3D) -> void:
	if not geometry.has_meta("v892_original_shadow"):
		geometry.set_meta(
			"v892_original_shadow",
			int(geometry.cast_shadow)
		)
	if not geometry.has_meta("v892_original_visibility_end"):
		geometry.set_meta(
			"v892_original_visibility_end",
			geometry.visibility_range_end
		)


func _cache_label(label: Label3D) -> void:
	if not label.has_meta("v892_original_label_end"):
		label.set_meta(
			"v892_original_label_end",
			label.visibility_range_end
		)


func _restore_shadow(geometry: GeometryInstance3D) -> void:
	if geometry.has_meta("v892_original_shadow"):
		geometry.cast_shadow = int(
			geometry.get_meta("v892_original_shadow")
		)


func _is_weapon_cosmetic(key: String) -> bool:
	return (
		"weapon" in key
		or "rifle" in key
		or "pistol" in key
		or "thompson" in key
		or "mp40" in key
		or "p38" in key
		or "tt_" in key
	)


func _is_small_cosmetic(key: String) -> bool:
	return (
		"pouch" in key
		or "strap" in key
		or "helmetdetail" in key
		or "badge" in key
		or "insignia" in key
		or "grenadevisual" in key
		or "attachment" in key
		or "gear" in key
	)


func _is_player_label(key: String) -> bool:
	return (
		"name" in key
		or "label" in key
		or "status" in key
		or "class" in key
		or "team" in key
	)
