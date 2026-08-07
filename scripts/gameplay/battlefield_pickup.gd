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

	var label := Label3D.new()
	label.name = "PickupLabel"
	label.position = Vector3(0.0, 0.48, 0.0)
	label.text = (
		"[INTERACT] TAKE %s" % display_name()
		if pickup_kind == "weapon"
		else "[INTERACT] TAKE AMMO"
	)
	label.font_size = 26
	label.outline_size = 8
	label.modulate = Color(0.94, 0.91, 0.78)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	add_child(label)


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

				# Preserve the proven first-person asset direction rules.
				if (
					"m1a1_thompson" in selected_path
					or "tt_pistol" in selected_path
				):
					forward_yaw = 180.0

				model.rotation_degrees = (
					auto_rotation
					+ Vector3(0.0, forward_yaw, 0.0)
					+ Vector3(0.0, 0.0, 90.0)
				)
				model.position.y = 0.18
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
