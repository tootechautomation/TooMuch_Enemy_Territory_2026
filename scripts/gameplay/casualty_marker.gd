extends Node3D
class_name CasualtyMarker

var casualty_id: int = 0
var team_id: int = 0
var cleanup_seconds: float = 28.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func configure(
	new_id: int,
	new_team: int,
	spawn_position: Vector3,
	body_yaw: float,
	duration_seconds: float = 28.0
) -> void:
	casualty_id = new_id
	team_id = clampi(new_team, 0, 1)
	cleanup_seconds = maxf(8.0, duration_seconds)
	global_position = spawn_position
	rotation.y = body_yaw

	if DisplayServer.get_name() != "headless":
		_build_visual()


func _build_visual() -> void:
	var uniform := StandardMaterial3D.new()
	uniform.albedo_color = (
		Color(0.23, 0.26, 0.20)
		if team_id == 0
		else Color(0.20, 0.20, 0.18)
	)
	uniform.roughness = 0.96

	var leather := StandardMaterial3D.new()
	leather.albedo_color = Color(0.11, 0.07, 0.04)
	leather.roughness = 0.90

	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.09, 0.095, 0.09)
	metal.roughness = 0.52
	metal.metallic = 0.58

	var disturbed := StandardMaterial3D.new()
	disturbed.albedo_color = Color(0.075, 0.055, 0.038, 0.72)
	disturbed.roughness = 0.96
	disturbed.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# Low-profile body silhouette. It intentionally stays abstract enough to
	# avoid competing with the live character model, while still reading as a
	# casualty at normal combat distance.
	var torso := _box(
		"CasualtyTorso",
		Vector3(0.0, 0.19, 0.0),
		Vector3(0.52, 0.26, 0.92),
		uniform
	)
	torso.rotation.x = deg_to_rad(78.0)
	torso.rotation.z = deg_to_rad(-5.0)

	var hips := _box(
		"CasualtyHips",
		Vector3(0.0, 0.16, 0.55),
		Vector3(0.46, 0.24, 0.46),
		uniform
	)
	hips.rotation.x = deg_to_rad(82.0)

	# Legs.
	for side: float in [-1.0, 1.0]:
		var upper_leg := _box(
			"CasualtyUpperLeg",
			Vector3(side * 0.18, 0.13, 0.88),
			Vector3(0.19, 0.18, 0.72),
			uniform
		)
		upper_leg.rotation.x = deg_to_rad(83.0)
		upper_leg.rotation.y = deg_to_rad(side * 6.0)

		var lower_leg := _box(
			"CasualtyLowerLeg",
			Vector3(side * 0.24, 0.11, 1.42),
			Vector3(0.17, 0.17, 0.62),
			uniform
		)
		lower_leg.rotation.x = deg_to_rad(84.0)
		lower_leg.rotation.y = deg_to_rad(side * 12.0)

	# Arms with slightly different resting pose.
	for side: float in [-1.0, 1.0]:
		var arm := _box(
			"CasualtyArm",
			Vector3(side * 0.42, 0.16, -0.10 + side * 0.05),
			Vector3(0.15, 0.16, 0.72),
			uniform
		)
		arm.rotation.x = deg_to_rad(81.0)
		arm.rotation.y = deg_to_rad(side * 28.0)
		arm.rotation.z = deg_to_rad(side * 6.0)

	# Helmet/head silhouette.
	var head := MeshInstance3D.new()
	head.name = "CasualtyHelmet"
	var sphere := SphereMesh.new()
	sphere.radius = 0.19
	sphere.height = 0.34
	sphere.radial_segments = 14
	sphere.rings = 7
	head.mesh = sphere
	head.position = Vector3(0.0, 0.19, -0.62)
	head.scale = Vector3(1.15, 0.65, 1.0)
	head.material_override = metal
	head.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(head)

	# Belt / small pouch gives the body a less mannequin-like silhouette.
	_box(
		"CasualtyBelt",
		Vector3(0.0, 0.23, 0.34),
		Vector3(0.52, 0.08, 0.14),
		leather
	)
	_box(
		"CasualtyPouch",
		Vector3(0.28, 0.23, 0.34),
		Vector3(0.16, 0.16, 0.14),
		leather
	)

	# Damp/disturbed ground patch underneath the body.
	var patch := MeshInstance3D.new()
	patch.name = "CasualtyGroundDisturbance"
	var patch_mesh := CylinderMesh.new()
	patch_mesh.top_radius = 0.85
	patch_mesh.bottom_radius = 0.85
	patch_mesh.height = 0.010
	patch_mesh.radial_segments = 28
	patch.mesh = patch_mesh
	patch.position = Vector3(0.0, 0.015, 0.35)
	patch.scale = Vector3(1.0, 1.0, 0.58)
	patch.material_override = disturbed
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	patch.visibility_range_end = 28.0
	patch.visibility_range_end_margin = 4.0
	patch.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)
	add_child(patch)

	# Body itself fades at longer ranges before cleanup.
	for child: Node in get_children():
		if child is GeometryInstance3D:
			var geometry := child as GeometryInstance3D
			geometry.visibility_range_end = 46.0
			geometry.visibility_range_end_margin = 7.0
			geometry.visibility_range_fade_mode = (
				GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			)


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
