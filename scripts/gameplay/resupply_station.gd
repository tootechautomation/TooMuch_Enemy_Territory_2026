extends Node3D
class_name ResupplyStation

var station_id: int = 0
var station_name: String = "AMMO SUPPLY"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func configure(
	new_id: int,
	new_name: String,
	spawn_position: Vector3
) -> void:
	station_id = new_id
	station_name = new_name
	global_position = spawn_position

	if DisplayServer.get_name() != "headless":
		_build_visual()


func _build_visual() -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.19, 0.105, 0.045)
	wood.roughness = 0.94

	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.08, 0.085, 0.08)
	metal.roughness = 0.48
	metal.metallic = 0.62

	var canvas := StandardMaterial3D.new()
	canvas.albedo_color = Color(0.18, 0.18, 0.11)
	canvas.roughness = 0.99

	# Main stacked ammunition crates.
	for row: int in range(2):
		for col: int in range(3):
			_box(
				"SupplyCrate",
				Vector3(
					-0.68 + 0.68 * float(col),
					0.34 + 0.60 * float(row),
					0.0 + 0.10 * float(row % 2)
				),
				Vector3(0.60, 0.55, 0.62),
				wood
			)

	# Metal bands give the pile a more deliberate military-supply read.
	for x: float in [-0.68, 0.0, 0.68]:
		_box(
			"CrateBand",
			Vector3(x, 0.64, -0.33),
			Vector3(0.07, 1.15, 0.035),
			metal
		)

	# Small canvas ammunition satchel on top.
	_box(
		"AmmoSatchel",
		Vector3(0.0, 1.40, 0.02),
		Vector3(0.72, 0.25, 0.42),
		canvas
	)

	var label := Label3D.new()
	label.name = "ResupplyLabel"
	label.position = Vector3(0.0, 1.88, 0.0)
	label.text = "[INTERACT] %s" % station_name
	label.font_size = 28
	label.outline_size = 9
	label.modulate = Color(0.91, 0.86, 0.61)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.visibility_range_end = 8.0
	label.visibility_range_end_margin = 1.5
	label.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)
	add_child(label)

	var glow := OmniLight3D.new()
	glow.name = "SupplyMarkerLight"
	glow.position = Vector3(0.0, 1.55, 0.0)
	glow.light_color = Color(1.0, 0.60, 0.22)
	glow.light_energy = 0.16
	glow.omni_range = 2.5
	glow.shadow_enabled = false
	add_child(glow)


func _box(
	node_name: String,
	position: Vector3,
	size: Vector3,
	material: Material
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = position
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	return mi
