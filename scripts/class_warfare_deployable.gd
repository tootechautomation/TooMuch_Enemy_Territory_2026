extends StaticBody3D
class_name ClassWarfareDeployable

# Frontline: Objective v14 class-support deployable.
# type 0 = medic aid station, type 1 = field ops ammunition crate.
var deployable_id: int = 0
var owner_id: int = 0
var team: int = 0
var support_type: int = 0
var health: int = 120
var maximum_health: int = 120
var remaining_seconds: float = 45.0
var frontline_bonus: bool = false
var label: Label3D
var health_label: Label3D

func configure(
	id_value: int,
	owner_value: int,
	team_value: int,
	type_value: int,
	position_value: Vector3,
	yaw_value: float,
	health_value: int,
	duration_value: float,
	frontline_value: bool
) -> void:
	deployable_id = id_value
	owner_id = owner_value
	team = team_value
	support_type = type_value
	health = health_value
	maximum_health = health_value
	remaining_seconds = duration_value
	frontline_bonus = frontline_value
	global_position = position_value
	rotation.y = yaw_value
	collision_layer = 1
	collision_mask = 1
	_build_visuals()
	set_process(multiplayer.is_server())

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	remaining_seconds = maxf(0.0, remaining_seconds - delta)
	if remaining_seconds <= 0.0:
		var main: Node = get_parent()
		if main != null and main.has_method("server_destroy_class_support"):
			main.call("server_destroy_class_support", deployable_id, 0)

func _build_visuals() -> void:
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.45, 0.72, 0.92)
	mesh_instance.mesh = box
	mesh_instance.position.y = 0.36
	var material := StandardMaterial3D.new()
	material.albedo_color = (
		Color(0.20, 0.42, 0.23)
		if support_type == 0
		else Color(0.34, 0.29, 0.17)
	)
	material.roughness = 0.92
	mesh_instance.material_override = material
	add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.45, 0.72, 0.92)
	collision.shape = shape
	collision.position.y = 0.36
	add_child(collision)

	label = Label3D.new()
	label.text = "AID STATION" if support_type == 0 else "AMMO CRATE"
	label.position = Vector3(0.0, 1.10, 0.0)
	label.font_size = 18
	label.outline_size = 5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.55, 0.82, 1.0) if team == 0 else Color(1.0, 0.48, 0.42)
	add_child(label)

	health_label = Label3D.new()
	health_label.position = Vector3(0.0, 0.88, 0.0)
	health_label.font_size = 13
	health_label.outline_size = 4
	health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(health_label)
	_update_health_label()

func _update_health_label() -> void:
	if health_label == null:
		return
	health_label.text = "%d/%d%s" % [
		health,
		maximum_health,
		" · FRONTLINE" if frontline_bonus else ""
	]

func server_take_damage(amount: int, attacker_id: int) -> void:
	if not multiplayer.is_server() or amount <= 0:
		return
	var main: Node = get_parent()
	if main != null and main.get("players") is Dictionary:
		var roster: Dictionary = main.get("players")
		if roster.has(attacker_id):
			var attacker: Node = roster[attacker_id] as Node
			if attacker != null and int(attacker.get("team")) == team:
				return
	health = maxi(0, health - amount)
	_update_health_label_rpc.rpc(health)
	if health <= 0 and main != null and main.has_method("server_destroy_class_support"):
		main.call("server_destroy_class_support", deployable_id, attacker_id)

@rpc("authority", "call_local", "reliable")
func _update_health_label_rpc(new_health: int) -> void:
	health = new_health
	_update_health_label()
