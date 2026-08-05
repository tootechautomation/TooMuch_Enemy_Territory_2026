extends Node3D

var beacon_id := 0
var owner_id := 0
var team := 0
var lifetime_remaining := 18.0
var pulse_accumulator := 0.0
var radius := 24.0
var main_node: Node
var beacon_light: OmniLight3D

func configure(new_id: int, new_owner_id: int, new_team: int, spawn_position: Vector3, duration: float, new_radius: float) -> void:
	beacon_id = new_id
	owner_id = new_owner_id
	team = new_team
	global_position = spawn_position
	lifetime_remaining = duration
	radius = new_radius
	main_node = get_parent()
	_build_visuals()

func _build_visuals() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var body := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.18
	cylinder.bottom_radius = 0.24
	cylinder.height = 0.70
	body.mesh = cylinder
	body.position.y = 0.35
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.10, 0.65, 0.80) if team == 0 else Color(0.85, 0.22, 0.16)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.45
	body.material_override = material
	add_child(body)

	var label := Label3D.new()
	label.text = "SENSOR"
	label.position = Vector3(0.0, 1.15, 0.0)
	label.font_size = 22
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.fixed_size = true
	label.modulate = material.albedo_color.lightened(0.25)
	add_child(label)

	beacon_light = OmniLight3D.new()
	beacon_light.position = Vector3(0.0, 0.75, 0.0)
	beacon_light.omni_range = 5.0
	beacon_light.light_energy = 1.8
	beacon_light.light_color = material.albedo_color
	add_child(beacon_light)

func _process(delta: float) -> void:
	lifetime_remaining = maxf(0.0, lifetime_remaining - delta)
	pulse_accumulator += delta
	if beacon_light != null:
		beacon_light.light_energy = 1.4 + sin(Time.get_ticks_msec() * 0.012) * 0.7
	if multiplayer.is_server():
		if pulse_accumulator >= 1.25:
			pulse_accumulator = 0.0
			if main_node != null:
				main_node.call("server_sensor_beacon_pulse", self)
		if lifetime_remaining <= 0.0:
			set_process(false)

			if main_node != null:
				main_node.call(
					"server_remove_sensor_beacon",
					beacon_id
				)
			elif not is_queued_for_deletion():
				queue_free()
