extends Node
class_name ClientPerformanceGovernor

var world_root: Node
var quality_manager: Node
var sample_accumulator := 0.0
var low_fps_seconds := 0.0
var recovery_seconds := 0.0
var adaptive_assist_enabled := true

const SAMPLE_INTERVAL := 1.0
const LOW_FPS_THRESHOLD := 38.0
const RECOVERY_FPS_THRESHOLD := 57.0
const LOW_FPS_TRIGGER_SECONDS := 6.0
const RECOVERY_TRIGGER_SECONDS := 18.0

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	_apply_frame_pacing()


func on_quality_changed() -> void:
	_apply_frame_pacing()
	_apply_process_budgets()


func _process(delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if world_root == null:
		return

	sample_accumulator += delta
	if sample_accumulator < SAMPLE_INTERVAL:
		return
	sample_accumulator = 0.0

	_apply_process_budgets()

	if not adaptive_assist_enabled or quality_manager == null:
		return

	var fps: float = Engine.get_frames_per_second()
	var preset: int = int(quality_manager.get("current_preset"))

	# Only auto-assist downward. Never automatically upgrade graphics.
	if fps < LOW_FPS_THRESHOLD:
		low_fps_seconds += SAMPLE_INTERVAL
		recovery_seconds = 0.0
	else:
		low_fps_seconds = maxf(0.0, low_fps_seconds - SAMPLE_INTERVAL)

	if fps >= RECOVERY_FPS_THRESHOLD:
		recovery_seconds += SAMPLE_INTERVAL
	else:
		recovery_seconds = 0.0

	if low_fps_seconds >= LOW_FPS_TRIGGER_SECONDS:
		if preset > 0:
			quality_manager.call("set_quality", preset - 1)
		low_fps_seconds = 0.0
		recovery_seconds = 0.0


func _apply_frame_pacing() -> void:
	if quality_manager == null:
		return

	var preset: int = int(quality_manager.get("current_preset"))

	match preset:
		0:
			# Integrated graphics / office laptop target.
			Engine.max_fps = 60
		1:
			# Avoid wasting laptop power/thermals rendering 200+ FPS.
			Engine.max_fps = 90
		_:
			# High remains effectively unrestricted for gaming hardware.
			Engine.max_fps = 165


func _apply_process_budgets() -> void:
	if world_root == null or quality_manager == null:
		return

	var preset: int = int(quality_manager.get("current_preset"))

	for value: Node in world_root.find_children("*", "GPUParticles3D", true):
		var particles := value as GPUParticles3D
		if particles == null:
			continue

		var key := particles.name.to_lower()

		# These effects are purely decorative. Low mode keeps important smoke,
		# but suspends processing of minor effects when they aren't emitting.
		if preset == 0 and (
			"dust" in key
			or "ember" in key
			or "drip" in key
			or "splash" in key
			or "haze" in key
		):
			particles.process_mode = (
				Node.PROCESS_MODE_INHERIT
				if particles.emitting
				else Node.PROCESS_MODE_DISABLED
			)
		else:
			particles.process_mode = Node.PROCESS_MODE_INHERIT

	# Visual-only animated passes can be completely idle on Low.
	var optional_nodes := [
		"EnvironmentalMotionController",
		"RainRippleController"
	]
	for node_name: String in optional_nodes:
		for candidate: Node in world_root.find_children(
			node_name,
			"",
			true
		):
			candidate.process_mode = (
				Node.PROCESS_MODE_DISABLED
				if preset == 0
				else Node.PROCESS_MODE_INHERIT
			)

	# Local cosmetic casing simulation budget.
	for feedback: Node in world_root.find_children(
		"WeaponHandlingFeedback",
		"",
		true
	):
		feedback.process_mode = Node.PROCESS_MODE_INHERIT


func set_adaptive_assist(enabled: bool) -> void:
	adaptive_assist_enabled = enabled
