extends RefCounted
class_name EnvironmentMaterialUpgradePass

# v8.56 — turns the remaining flat prototype surfaces into a darker,
# rougher, layered battlefield palette without touching collision.

static func apply(root: Node) -> void:
	if root == null or root.has_node("EnvironmentMaterialUpgrade_v856"):
		return

	var marker := Node.new()
	marker.name = "EnvironmentMaterialUpgrade_v856"
	root.add_child(marker)

	for value: Node in root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var key := (mesh_instance.name + " " + str(mesh_instance.get_path())).to_lower()
		_upgrade_mesh(mesh_instance, key)


static func _upgrade_mesh(mesh_instance: MeshInstance3D, key: String) -> void:
	# Do not overwrite imported character/weapon materials.
	if (
		"weapon" in key or "viewmodel" in key or "fps_" in key
		or "character" in key or "soldier" in key or "bot" in key
	):
		return

	var mat := StandardMaterial3D.new()

	if "brick" in key:
		mat.albedo_color = Color(0.25, 0.13, 0.085)
		mat.roughness = 0.93
	elif "concrete" in key or "bunker" in key or "wall" in key:
		mat.albedo_color = Color(0.31, 0.30, 0.275)
		mat.roughness = 0.96
	elif "road" in key or "ground" in key or "yard" in key:
		mat.albedo_color = Color(0.17, 0.16, 0.14)
		mat.roughness = 0.78
	elif "wood" in key or "crate" in key or "plank" in key:
		mat.albedo_color = Color(0.24, 0.145, 0.075)
		mat.roughness = 0.86
	elif "metal" in key or "fence" in key or "rail" in key or "pipe" in key:
		mat.albedo_color = Color(0.12, 0.13, 0.13)
		mat.roughness = 0.57
		mat.metallic = 0.58
	elif "sandbag" in key or "sand" in key:
		mat.albedo_color = Color(0.38, 0.34, 0.23)
		mat.roughness = 0.98
	elif "roof" in key:
		mat.albedo_color = Color(0.105, 0.11, 0.105)
		mat.roughness = 0.76
	else:
		return

	mesh_instance.material_override = mat
