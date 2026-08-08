extends Node3D
class_name BattlefieldPickup

const ExternalAssetRegistryScript = preload(
	"res://scripts/assets/asset_registry.gd"
)
const RealAssetAdapterScript = preload(
	"res://scripts/assets/real_asset_adapter.gd"
)

var pickup_id: int = 0
var pickup_kind: String = "weapon"
var slot_index: int = 0
var source_team: int = 0
var weapon_resource_path: String = ""
var magazine_ammo: int = 0
var reserve_ammo: int = 0
var ammo_amount: int = 0
var pickup_label: Label3D
var prompt_refresh_accumulator: float = 0.0

func configure(
	new_id: int,
	new_kind: String,
	new_slot: int,
	new_source_team: int,
	new_resource_path: String,
	new_magazine: int,
	new_reserve: int,
	new_ammo_amount: int,
	spawn_position: Vector3
) -> void:
	pickup_id = new_id
	pickup_kind = new_kind
	slot_index = new_slot
	source_team = new_source_team
	weapon_resource_path = new_resource_path
	magazine_ammo = maxi(0, new_magazine)
	reserve_ammo = maxi(0, new_reserve)
	ammo_amount = maxi(0, new_ammo_amount)
	global_position = spawn_position

	if DisplayServer.get_name() != "headless":
		_build_visual()


func _process(delta: float) -> void:
	if pickup_label == null:
		return

	prompt_refresh_accumulator += delta
	if prompt_refresh_accumulator < 0.18:
		return
	prompt_refresh_accumulator = 0.0

	_update_contextual_prompt()


func _update_contextual_prompt() -> void:
	if pickup_label == null:
		return

	if pickup_kind == "ammo":
		pickup_label.text = "[INTERACT] TAKE AMMO +%d" % ammo_amount
		return

	var main_node: Node = get_parent()
	if main_node == null:
		pickup_label.text = "[INTERACT] TAKE %s" % display_name()
		return

	var players_value: Variant = main_node.get("players")
	if not players_value is Dictionary:
		pickup_label.text = "[INTERACT] TAKE %s" % display_name()
		return

	var local_peer_id: int = multiplayer.get_unique_id()
	var players: Dictionary = players_value
	if not players.has(local_peer_id):
		pickup_label.text = "[INTERACT] TAKE %s" % display_name()
		return

	var local_player: Node = players.get(local_peer_id) as Node
	if local_player == null:
		return

	var slots_value: Variant = local_player.get("weapon_slots")
	if not slots_value is Array:
		pickup_label.text = "[INTERACT] TAKE %s" % display_name()
		return

	var slots: Array = slots_value
	if slot_index < 0 or slot_index >= slots.size():
		pickup_label.text = "[INTERACT] TAKE %s" % display_name()
		return

	var current_weapon: Resource = slots[slot_index] as Resource
	var same_weapon: bool = (
		current_weapon != null
		and current_weapon.resource_path == weapon_resource_path
	)

	if same_weapon:
		var available_rounds: int = (
			maxi(0, magazine_ammo)
			+ maxi(0, reserve_ammo)
		)
		pickup_label.text = (
			"[INTERACT] SCAVENGE %s AMMO +%d"
			% [display_name(), available_rounds]
		)
	else:
		pickup_label.text = (
			"[INTERACT] SWAP %s → %s"
			% [
				"PRIMARY" if slot_index == 0 else "SECONDARY",
				display_name()
			]
		)


func display_name() -> String:
	if pickup_kind == "ammo":
		return "AMMO"

	if slot_index == 1:
		return "TT PISTOL" if source_team == 0 else "P38"

	return "THOMPSON" if source_team == 0 else "MP40"


func _build_visual() -> void:
	for child: Node in get_children():
		child.queue_free()

	if pickup_kind == "ammo":
		_build_ammo_visual()
	else:
		_build_weapon_visual()

	pickup_label = Label3D.new()
	pickup_label.name = "PickupLabel"
	pickup_label.position = Vector3(0.0, 0.48, 0.0)
	pickup_label.text = (
		"[INTERACT] %s" % display_name()
		if pickup_kind == "weapon"
		else "[INTERACT] AMMO +%d" % ammo_amount
	)
	pickup_label.font_size = 26
	pickup_label.outline_size = 8
	pickup_label.modulate = Color(0.94, 0.91, 0.78)
	pickup_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pickup_label.no_depth_test = false
	pickup_label.visibility_range_end = 5.5
	pickup_label.visibility_range_end_margin = 1.5
	pickup_label.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)
	add_child(pickup_label)

	var ring := MeshInstance3D.new()
	ring.name = "PickupGroundRing"
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.42
	ring_mesh.bottom_radius = 0.42
	ring_mesh.height = 0.012
	ring_mesh.radial_segments = 28
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.018, 0.0)
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.78, 0.69, 0.38, 0.12)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visibility_range_end = 8.0
	ring.visibility_range_end_margin = 2.0
	ring.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)
	add_child(ring)

	if pickup_kind == "weapon":
		var marker := MeshInstance3D.new()
		marker.name = "WeaponCategoryMarker"
		var marker_mesh := BoxMesh.new()
		marker_mesh.size = (
			Vector3(0.95, 0.025, 0.10)
			if slot_index == 0
			else Vector3(0.42, 0.025, 0.10)
		)
		marker.mesh = marker_mesh
		marker.position = Vector3(0.0, 0.025, 0.0)
		marker.rotation.y = deg_to_rad(
			float((pickup_id * 29) % 24) - 12.0
		)
		var marker_mat := StandardMaterial3D.new()
		marker_mat.albedo_color = Color(0.76, 0.66, 0.34, 0.10)
		marker_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marker.material_override = marker_mat
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		marker.visibility_range_end = 8.0
		marker.visibility_range_end_margin = 1.5
		marker.visibility_range_fade_mode = (
			GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		)
		add_child(marker)


func _build_weapon_visual() -> void:
	var scene: PackedScene = ExternalAssetRegistryScript.weapon_scene(
		source_team,
		slot_index
	)

	if scene != null:
		var instance: Node = scene.instantiate()
		if instance is Node3D:
			var model := instance as Node3D
			model.name = "DroppedWeaponModel"
			add_child(model)

			var adaptation: Dictionary = RealAssetAdapterScript.adapt_weapon(
				model,
				0.55 if slot_index == 1 else 0.95
			)

			if bool(adaptation.get("valid", false)):
				var auto_rotation := Vector3(
					adaptation.get("orientation_degrees", Vector3.ZERO)
				)
				var selected_path := scene.resource_path.to_lower()
				var forward_yaw := 0.0

				if (
					"m1a1_thompson" in selected_path
					or "tt_pistol" in selected_path
				):
					forward_yaw = 180.0

				var presentation_yaw: float = (
					float((pickup_id * 37) % 26) - 13.0
				)
				var presentation_roll: float = (
					-4.0 if pickup_id % 2 == 0 else 5.0
				)

				model.rotation_degrees = (
					auto_rotation
					+ Vector3(
						0.0,
						forward_yaw + presentation_yaw,
						90.0 + presentation_roll
					)
				)
				model.position.y = (
					0.12 if slot_index == 1 else 0.16
				)
				model.scale *= (
					Vector3.ONE * 0.90
					if slot_index == 1
					else Vector3.ONE
				)
				return

			model.queue_free()

	# Fallback silhouette if an external scene is unavailable.
	var fallback := MeshInstance3D.new()
	fallback.name = "DroppedWeaponFallback"
	var mesh := BoxMesh.new()
	mesh.size = (
		Vector3(0.45, 0.10, 0.18)
		if slot_index == 1
		else Vector3(0.85, 0.12, 0.20)
	)
	fallback.mesh = mesh
	fallback.position.y = 0.16

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.11, 0.11, 0.095)
	mat.metallic = 0.55
	mat.roughness = 0.48
	fallback.material_override = mat
	add_child(fallback)


func _build_ammo_visual() -> void:
	var pouch := MeshInstance3D.new()
	pouch.name = "AmmoPouch"

	var pouch_mesh := BoxMesh.new()
	pouch_mesh.size = Vector3(0.42, 0.22, 0.30)
	pouch.mesh = pouch_mesh
	pouch.position.y = 0.14

	var pouch_mat := StandardMaterial3D.new()
	pouch_mat.albedo_color = Color(0.20, 0.18, 0.10)
	pouch_mat.roughness = 0.92
	pouch.material_override = pouch_mat
	add_child(pouch)

	for i: int in range(3):
		var cartridge := MeshInstance3D.new()
		cartridge.name = "Ammo_%d" % i

		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.025
		mesh.bottom_radius = 0.025
		mesh.height = 0.18
		mesh.radial_segments = 8
		cartridge.mesh = mesh
		cartridge.position = Vector3(-0.10 + 0.10 * i, 0.32, 0.0)
		cartridge.rotation.z = deg_to_rad(90.0)

		var brass := StandardMaterial3D.new()
		brass.albedo_color = Color(0.55, 0.39, 0.12)
		brass.metallic = 0.75
		brass.roughness = 0.38
		cartridge.material_override = brass
		add_child(cartridge)
