extends Node
class_name AdaptiveMusicDirector

const CALM_PATH := "res://audio/score_calm.wav"
const TENSION_PATH := "res://audio/score_tension.wav"
const ASSAULT_PATH := "res://audio/score_assault.wav"

var calm_player: AudioStreamPlayer
var tension_player: AudioStreamPlayer
var assault_player: AudioStreamPlayer
var current_intensity := 0.0
var target_intensity := 0.0
var fade_in_db := -24.0
var restart_check_elapsed := 0.0

func initialize() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	calm_player = _create_player("CalmScore", CALM_PATH)
	tension_player = _create_player("TensionScore", TENSION_PATH)
	assault_player = _create_player("AssaultScore", ASSAULT_PATH)
	if calm_player == null or tension_player == null or assault_player == null:
		queue_free()
		return false
	calm_player.volume_db = -28.0
	tension_player.volume_db = -60.0
	assault_player.volume_db = -60.0
	calm_player.play()
	tension_player.play()
	assault_player.play()
	print("Adaptive music active: calm, tension, and assault stems")
	return true

func set_intensity(value: float) -> void:
	target_intensity = clampf(value, 0.0, 1.0)

func _process(delta: float) -> void:
	if calm_player == null:
		return
	restart_check_elapsed += delta
	if restart_check_elapsed >= 1.0:
		restart_check_elapsed = 0.0
		_ensure_synchronized_playback()
	fade_in_db = move_toward(fade_in_db, 0.0, delta * 12.0)
	current_intensity = move_toward(
		current_intensity,
		target_intensity,
		delta * 0.32
	)
	var calm_weight := 1.0 - smoothstep(0.12, 0.48, current_intensity)
	var tension_weight := (
		smoothstep(0.12, 0.48, current_intensity)
		* (1.0 - smoothstep(0.58, 0.88, current_intensity))
	)
	var assault_weight := smoothstep(0.58, 0.88, current_intensity)
	var combat_duck_db: float = lerpf(
		0.0,
		-2.0,
		smoothstep(0.76, 1.0, current_intensity)
	)
	calm_player.volume_db = _weight_to_db(
		calm_weight,
		-4.0 + fade_in_db + combat_duck_db
	)
	tension_player.volume_db = _weight_to_db(
		tension_weight,
		-3.0 + fade_in_db + combat_duck_db
	)
	assault_player.volume_db = _weight_to_db(
		assault_weight,
		-2.0 + fade_in_db + combat_duck_db
	)

func _ensure_synchronized_playback() -> void:
	var players: Array[AudioStreamPlayer] = [
		calm_player,
		tension_player,
		assault_player
	]
	var reference_position := 0.0
	for player in players:
		if player != null and player.playing:
			reference_position = player.get_playback_position()
			break
	for player in players:
		if player != null and not player.playing:
			player.play(reference_position)

func _create_player(node_name: String, path: String) -> AudioStreamPlayer:
	if not ResourceLoader.exists(path):
		push_warning("Adaptive score stem missing: %s" % path)
		return null
	var resource: Resource = load(path)
	if not resource is AudioStream:
		push_warning("Adaptive score stem is not audio: %s" % path)
		return null
	var stream := resource as AudioStream
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.data.size() / 2)
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.stream = stream
	player.bus = "Music"
	add_child(player)
	return player

func _weight_to_db(weight: float, peak_db: float) -> float:
	if weight <= 0.001:
		return -60.0
	return clampf(linear_to_db(weight) + peak_db, -60.0, peak_db)
