extends Node3D


func _has_active_multiplayer_peer() -> bool:
	var peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if peer == null:
		return false
	return (
		peer.get_connection_status()
		!= MultiplayerPeer.CONNECTION_DISCONNECTED
	)

func _is_active_server() -> bool:
	if not _has_active_multiplayer_peer():
		return false
	return multiplayer.is_server()
@export var pack_id := 0
@export var team := 0
@export var pack_type := 0 # 0 health, 1 ammo
@export var amount := 35
@export var lifetime_seconds := 25.0

var age := 0.0
var consumed := false

func _ready() -> void:
	_build_visual()

func _process(delta: float) -> void:
	age += delta
	rotate_y(delta * 1.5)
	if _is_active_server() and not consumed:
		for player in get_parent().players.values():
			if player.team == team and player.alive and not player.downed and global_position.distance_to(player.global_position) <= 1.5:
				if pack_type == 0 and player.health < player._class_health(player.player_class):
					player.health = mini(player._class_health(player.player_class), player.health + amount)
					_consume()
					break
				elif pack_type == 1 and player.reserve_ammo < player.weapon.reserve_ammo + 120:
					player.reserve_ammo = mini(player.weapon.reserve_ammo + 120, player.reserve_ammo + amount)
					_consume()
					break
		if age >= lifetime_seconds:
			_consume()

func _consume() -> void:
	if consumed:
		return
	consumed = true
	get_parent().remove_supply_pack.rpc(pack_id)

func _build_visual() -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.65, 0.35, 0.65)
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.75, 0.28) if pack_type == 0 else Color(0.82, 0.66, 0.15)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.25
	mesh_instance.material_override = material
	add_child(mesh_instance)
