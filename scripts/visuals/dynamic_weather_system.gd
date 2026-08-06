extends Node3D
class_name DynamicWeatherSystem

const RAIN_AUDIO_PATH := "res://audio/weather_rain.wav"

var world_root: Node
var environment: Environment
var battlefield_sun: DirectionalLight3D
var rain_particles: GPUParticles3D
var mist_particles: GPUParticles3D
var rain_audio: AudioStreamPlayer
var lightning_light: OmniLight3D
var cloud_layers: Array[MeshInstance3D] = []
var elapsed := 0.0
var current_intensity := 0.0
var next_lightning_time := 24.0
var lightning_remaining := 0.0
var rng := RandomNumberGenerator.new()

func build(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	world_root = root
	environment = root.get("battlefield_environment") as Environment
	battlefield_sun = root.get("battlefield_sun") as DirectionalLight3D
	rng.seed = 8132026
	_build_cloud_layers()
	_build_rain()
	_build_ground_mist()
	_build_lightning()
	_build_rain_audio()

func _process(delta: float) -> void:
	if world_root == null:
		return
	elapsed += delta
	var broad_front := sin(elapsed * 0.021)
	var passing_cells := sin(elapsed * 0.053 + 1.2)
	var target_intensity := clampf(
		0.44 + broad_front * 0.34 + passing_cells * 0.20,
		0.0,
		1.0
	)
	current_intensity = move_toward(current_intensity, target_intensity, delta * 0.055)
	_update_clouds(delta)
	_update_precipitation()
	_update_environment()
	_update_lightning(delta)

func _build_cloud_layers() -> void:
	for layer_index in range(3):
		var cloud := MeshInstance3D.new()
		cloud.name = "MovingOvercastLayer_%d" % layer_index
		cloud.position = Vector3(-18.0 + layer_index * 19.0, 25.0 + layer_index * 3.5, -12.0 + layer_index * 14.0)
		cloud.rotation_degrees.x = -90.0
		var quad := QuadMesh.new()
		quad.size = Vector2(115.0, 92.0)
		cloud.mesh = quad
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.albedo_color = Color(0.22, 0.25, 0.27, 0.13 + layer_index * 0.035)
		material.albedo_texture = _cloud_texture(940 + layer_index * 113)
		material.uv1_scale = Vector3(2.2 + layer_index * 0.5, 2.2 + layer_index * 0.5, 1.0)
		cloud.material_override = material
		cloud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(cloud)
		cloud_layers.append(cloud)

func _cloud_texture(seed_value: int) -> Texture2D:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.fractal_gain = 0.56
	var texture := NoiseTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.seamless = true
	texture.noise = noise
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.05, 0.065, 0.075, 0.0))
	gradient.set_color(1, Color(0.38, 0.42, 0.44, 0.82))
	texture.color_ramp = gradient
	return texture

func _build_rain() -> void:
	rain_particles = GPUParticles3D.new()
	rain_particles.name = "WindDrivenRain"
	rain_particles.position = Vector3(0.0, 14.0, 0.0)
	rain_particles.amount = 1050
	rain_particles.lifetime = 1.8
	rain_particles.preprocess = 1.8
	rain_particles.visibility_aabb = AABB(Vector3(-75.0, -25.0, -65.0), Vector3(150.0, 55.0, 130.0))
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(61.0, 4.0, 51.0)
	process.direction = Vector3(0.18, -1.0, 0.08)
	process.spread = 4.0
	process.initial_velocity_min = 16.0
	process.initial_velocity_max = 23.0
	process.gravity = Vector3(1.1, -9.8, 0.45)
	process.scale_min = 0.65
	process.scale_max = 1.15
	process.color = Color(0.61, 0.70, 0.76, 0.58)
	rain_particles.process_material = process
	var streak := QuadMesh.new()
	streak.size = Vector2(0.022, 0.72)
	var streak_material := StandardMaterial3D.new()
	streak_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	streak_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	streak_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	streak_material.albedo_color = Color(0.66, 0.75, 0.82, 0.48)
	streak.material = streak_material
	rain_particles.draw_pass_1 = streak
	add_child(rain_particles)

func _build_ground_mist() -> void:
	mist_particles = GPUParticles3D.new()
	mist_particles.name = "WetGroundMist"
	mist_particles.position = Vector3(0.0, 0.45, 0.0)
	mist_particles.amount = 95
	mist_particles.lifetime = 7.0
	mist_particles.preprocess = 7.0
	mist_particles.visibility_aabb = AABB(Vector3(-70.0, -3.0, -60.0), Vector3(140.0, 12.0, 120.0))
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(58.0, 0.25, 48.0)
	process.direction = Vector3(0.8, 0.05, 0.25)
	process.spread = 32.0
	process.initial_velocity_min = 0.10
	process.initial_velocity_max = 0.32
	process.gravity = Vector3.ZERO
	process.scale_min = 0.65
	process.scale_max = 1.8
	process.color = Color(0.54, 0.58, 0.59, 0.12)
	mist_particles.process_material = process
	var mist_quad := QuadMesh.new()
	mist_quad.size = Vector2(2.4, 0.65)
	var mist_material := StandardMaterial3D.new()
	mist_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mist_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mist_material.albedo_color = Color(0.58, 0.62, 0.63, 0.10)
	mist_quad.material = mist_material
	mist_particles.draw_pass_1 = mist_quad
	add_child(mist_particles)

func _build_lightning() -> void:
	lightning_light = OmniLight3D.new()
	lightning_light.name = "DistantLightningFlash"
	lightning_light.position = Vector3(-28.0, 22.0, -36.0)
	lightning_light.light_color = Color(0.68, 0.78, 1.0)
	lightning_light.light_energy = 0.0
	lightning_light.omni_range = 115.0
	lightning_light.shadow_enabled = false
	add_child(lightning_light)

func _build_rain_audio() -> void:
	if not ResourceLoader.exists(RAIN_AUDIO_PATH):
		return
	var resource: Resource = load(RAIN_AUDIO_PATH)
	if not resource is AudioStream:
		return
	var stream := resource as AudioStream
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.data.size() / 2)
	rain_audio = AudioStreamPlayer.new()
	rain_audio.name = "WeatherRainAudio"
	rain_audio.stream = stream
	rain_audio.bus = "SFX"
	rain_audio.volume_db = -60.0
	add_child(rain_audio)
	rain_audio.play()

func _update_clouds(delta: float) -> void:
	for layer_index in range(cloud_layers.size()):
		var cloud := cloud_layers[layer_index]
		cloud.position.x += delta * (0.36 + layer_index * 0.12)
		cloud.position.z += delta * (0.08 + layer_index * 0.025)
		if cloud.position.x > 58.0:
			cloud.position.x = -58.0
		var material := cloud.material_override as StandardMaterial3D
		if material != null:
			material.albedo_color.a = lerpf(0.07, 0.25, current_intensity) + layer_index * 0.018

func _update_precipitation() -> void:
	var rain_weight := smoothstep(0.20, 0.82, current_intensity)
	if rain_particles != null:
		rain_particles.emitting = rain_weight > 0.015
		rain_particles.amount_ratio = rain_weight
	if mist_particles != null:
		mist_particles.emitting = current_intensity > 0.16
		mist_particles.amount_ratio = lerpf(0.12, 1.0, current_intensity)
	if rain_audio != null:
		rain_audio.volume_db = lerpf(-60.0, -18.0, rain_weight)

func _update_environment() -> void:
	if environment != null:
		environment.fog_density = lerpf(0.0065, 0.0145, current_intensity)
		environment.fog_light_color = Color(0.48, 0.52, 0.54).lerp(Color(0.31, 0.35, 0.39), current_intensity)
		environment.ambient_light_energy = lerpf(0.76, 0.55, current_intensity)
	if battlefield_sun != null:
		battlefield_sun.light_energy = lerpf(1.24, 0.68, current_intensity)
		battlefield_sun.light_color = Color(1.0, 0.86, 0.70).lerp(Color(0.70, 0.76, 0.82), current_intensity)

func _update_lightning(delta: float) -> void:
	if lightning_light == null:
		return
	if lightning_remaining > 0.0:
		lightning_remaining -= delta
		lightning_light.light_energy = 5.5 if lightning_remaining > 0.07 else 1.4
		return
	lightning_light.light_energy = move_toward(lightning_light.light_energy, 0.0, delta * 24.0)
	if elapsed >= next_lightning_time:
		next_lightning_time = elapsed + rng.randf_range(18.0, 34.0)
		if current_intensity >= 0.76:
			lightning_remaining = 0.13
			lightning_light.position = Vector3(rng.randf_range(-46.0, 46.0), rng.randf_range(19.0, 28.0), rng.randf_range(-44.0, 44.0))

