extends RefCounted
class_name HumanoidAnimationController

const STATE_CANDIDATES := {
	"idle": [&"idle", &"Idle", &"rifle_idle", &"Idle_Rifle"],
	"walk": [&"walk", &"Walk", &"rifle_walk", &"Walk_Rifle"],
	"run": [&"run", &"Run", &"sprint", &"Sprint", &"Run_Rifle"],
	"crouch_idle": [&"crouch_idle", &"Crouch_Idle", &"crouch"],
	"crouch_walk": [&"crouch_walk", &"Crouch_Walk"],
	"reload": [&"reload", &"Reload", &"rifle_reload", &"Reload_Rifle"],
	"fire": [&"fire", &"Fire", &"shoot", &"Shoot", &"rifle_fire"],
	"grenade": [&"grenade", &"throw", &"Throw_Grenade"],
	"downed": [&"downed", &"Downed", &"death", &"Death"],
	"revive": [&"revive", &"Revive"],
	"build": [&"build", &"Build", &"repair", &"Repair"]
}

var player: AnimationPlayer
var current_state := ""
var current_animation: StringName = &""

func configure(animation_player: AnimationPlayer) -> void:
	player = animation_player
	current_state = ""
	current_animation = &""

func _find_animation(state: String) -> StringName:
	if player == null or not STATE_CANDIDATES.has(state):
		return &""
	for candidate in STATE_CANDIDATES[state]:
		if player.has_animation(candidate):
			return candidate
	return &""

func _find_single_authored_animation() -> StringName:
	if player == null:
		return &""
	var authored: Array[StringName] = []
	for animation_name in player.get_animation_list():
		var lower := str(animation_name).to_lower()
		if lower == "reset" or lower.ends_with("/reset"):
			continue
		authored.append(animation_name)
	if authored.size() == 1:
		return authored[0]
	return &""

func set_state(state: String, blend_time: float = 0.16) -> StringName:
	if player == null:
		return &""
	if state == current_state and current_animation != &"":
		return current_animation

	var animation := _find_animation(state)
	if animation == &"":
		animation = _find_animation("idle")
	if animation == &"":
		animation = _find_single_authored_animation()
	if animation == &"":
		return &""

	if player.current_animation != str(animation):
		player.play(animation, blend_time)

	current_state = state
	current_animation = animation
	return animation

func resolve_state(
	alive: bool,
	downed: bool,
	reloading: bool,
	crouching: bool,
	speed: float,
	firing: bool,
	using_tool: bool
) -> String:
	if not alive or downed:
		return "downed"
	if using_tool:
		return "build"
	if reloading:
		return "reload"
	if firing:
		return "fire"
	if crouching:
		return "crouch_walk" if speed > 0.25 else "crouch_idle"
	if speed > 5.4:
		return "run"
	if speed > 0.25:
		return "walk"
	return "idle"
