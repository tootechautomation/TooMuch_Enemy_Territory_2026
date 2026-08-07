extends Node
class_name CombatCameraFeedback

var feedback_material: ShaderMaterial
var previous_health := -1
var damage_flash := 0.0
var recovery_flash := 0.0
var target_health_ratio := 1.0
var target_suppression := 0.0
var target_heavy_fire := 0.0
var target_downed := 0.0
var current_health_ratio := 1.0
var current_suppression := 0.0
var current_heavy_fire := 0.0
var current_downed := 0.0

func initialize() -> void:
	if DisplayServer.get_name() == "headless":
		queue_free()
		return
	var layer := CanvasLayer.new()
	layer.name = "CombatFeedbackLayer"
	layer.layer = 80
	add_child(layer)
	var overlay := ColorRect.new()
	overlay.name = "CombatFeedbackOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_material = ShaderMaterial.new()
	feedback_material.shader = _feedback_shader()
	overlay.material = feedback_material
	layer.add_child(overlay)

func update_state(
	delta: float,
	health: int,
	maximum_health: int,
	suppression_ms: int,
	heavy_fire_ms: int,
	is_downed: bool,
	is_alive: bool
) -> void:
	var safe_maximum := maxi(1, maximum_health)
	target_health_ratio = clampf(float(health) / float(safe_maximum), 0.0, 1.0)
	target_suppression = clampf(float(suppression_ms) / 1400.0, 0.0, 1.0)
	target_heavy_fire = clampf(float(heavy_fire_ms) / 2200.0, 0.0, 1.0)
	target_downed = 1.0 if is_downed or not is_alive else 0.0
	if previous_health >= 0:
		if health < previous_health:
			damage_flash = clampf(damage_flash + float(previous_health - health) / 42.0, 0.0, 1.0)
		elif health > previous_health:
			recovery_flash = clampf(recovery_flash + float(health - previous_health) / 55.0, 0.0, 0.72)
	previous_health = health
	damage_flash = move_toward(damage_flash, 0.0, delta * 1.85)
	recovery_flash = move_toward(recovery_flash, 0.0, delta * 1.20)

func _process(delta: float) -> void:
	if feedback_material == null:
		return
	current_health_ratio = lerpf(current_health_ratio, target_health_ratio, 1.0 - exp(-8.0 * delta))
	current_suppression = lerpf(current_suppression, target_suppression, 1.0 - exp(-11.0 * delta))
	current_heavy_fire = lerpf(current_heavy_fire, target_heavy_fire, 1.0 - exp(-8.0 * delta))
	current_downed = lerpf(current_downed, target_downed, 1.0 - exp(-7.0 * delta))
	feedback_material.set_shader_parameter("health_ratio", current_health_ratio)
	feedback_material.set_shader_parameter("suppression", current_suppression)
	feedback_material.set_shader_parameter("heavy_fire", current_heavy_fire)
	feedback_material.set_shader_parameter("downed", current_downed)
	feedback_material.set_shader_parameter("damage_flash", damage_flash)
	feedback_material.set_shader_parameter("recovery_flash", recovery_flash)

func _feedback_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float health_ratio = 1.0;
uniform float suppression = 0.0;
uniform float heavy_fire = 0.0;
uniform float downed = 0.0;
uniform float damage_flash = 0.0;
uniform float recovery_flash = 0.0;

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv * 2.0 - 1.0;
	float radial = length(centered * vec2(0.82, 1.0));
	float edge = smoothstep(0.42, 1.18, radial);
	float low_health = clamp(1.0 - health_ratio * 1.45, 0.0, 1.0);
	float pulse = 0.72 + 0.28 * sin(TIME * 4.6);
	float pressure = max(suppression, heavy_fire * 0.72);
	float aberration = (damage_flash * 0.0028 + pressure * 0.0014) * edge;
	vec4 center_sample = textureLod(screen_texture, uv, pressure * 1.7 + downed * 1.2);
	float red_channel = textureLod(screen_texture, uv + vec2(aberration, 0.0), pressure * 1.7).r;
	float blue_channel = textureLod(screen_texture, uv - vec2(aberration, 0.0), pressure * 1.7).b;
	vec3 scene = vec3(red_channel, center_sample.g, blue_channel);
	float luminance = dot(scene, vec3(0.299, 0.587, 0.114));
	float desaturation = clamp(pressure * 0.42 + low_health * 0.36 + downed * 0.76, 0.0, 0.92);
	scene = mix(scene, vec3(luminance), desaturation);
	float grain = noise(floor(uv * vec2(640.0, 360.0)) + floor(TIME * 18.0)) - 0.5;
	scene += grain * pressure * 0.045;
	vec3 damage_tint = vec3(0.42, 0.018, 0.012) * edge * (damage_flash * 0.68 + low_health * pulse * 0.40);
	vec3 suppression_tint = vec3(0.12, 0.095, 0.055) * edge * pressure * 0.22;
	vec3 recovery_tint = vec3(0.02, 0.20, 0.09) * edge * recovery_flash * 0.24;
	scene += damage_tint + suppression_tint + recovery_tint;
	float tunnel = edge * (low_health * 0.34 + downed * 0.64 + pressure * 0.12);
	scene *= 1.0 - tunnel;
	COLOR = vec4(scene, 1.0);
}
"""
	return shader

