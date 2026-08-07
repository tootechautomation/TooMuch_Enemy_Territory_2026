extends RefCounted
class_name EnvironmentalAnimationPass

# v8.76 — lightweight environmental motion pass.
# Adds subtle animated world details while preserving gameplay.

static func apply(root: Node) -> void:
	if root == null or root.has_node("EnvironmentalAnimationPass_v876"):
		return

	var holder := Node3D.new()
	holder.name = "EnvironmentalAnimationPass_v876"
	root.add_child(holder)

	var cloth := _mat(Color(0.19,0.18,0.12),0.98)
	var dark_cloth := _mat(Color(0.10,0.105,0.075),0.99)
	var metal := _mat(Color(0.075,0.08,0.078),0.48,0.68)
	var paper := _mat(Color(0.52,0.47,0.34),0.99)
	var warm := _emissive(Color(1.0,0.34,0.07))

	_build_hanging_cloth(holder, cloth, dark_cloth)
	_build_loose_papers(holder, paper)
	_build_swinging_cables(holder, metal)
	_build_fire_glow_markers(holder, warm)
	_attach_animator(holder)


static func _build_hanging_cloth(
	parent: Node3D,
	cloth: Material,
	dark_cloth: Material
) -> void:
	var locations: Array[Vector3] = [
		Vector3(-3.0,2.2,-8.7),
		Vector3(2.6,2.25,8.8),
		Vector3(13.2,2.0,1.7),
		Vector3(-14.0,2.3,9.8)
	]
	for i: int in range(locations.size()):
		var strip := _box(parent,"AnimatedCloth_%d" % i,
			locations[i],
			Vector3(1.25,1.15,0.055),
			cloth if i%2==0 else dark_cloth,
			float(-6+i*4))
		strip.set_meta("motion_type","cloth")
		strip.set_meta("motion_phase",float(i)*0.9)
		strip.set_meta("base_rotation_z",strip.rotation.z)


static func _build_loose_papers(parent: Node3D, paper: Material) -> void:
	var centers: Array[Vector3] = [
		Vector3(-0.8,0.08,-8.4),
		Vector3(1.0,0.08,8.5),
		Vector3(12.5,0.08,0.8)
	]
	var idx := 0
	for c: int in range(centers.size()):
		for i: int in range(4):
			var p := _box(parent,"LoosePaper_%d" % idx,
				centers[c]+Vector3(-0.45+i*0.28,0.02,0.12*float(i%2)),
				Vector3(0.22,0.018,0.16),paper,float(i*17+c*9))
			p.set_meta("motion_type","paper")
			p.set_meta("motion_phase",float(idx)*0.55)
			p.set_meta("base_y",p.position.y)
			idx += 1


static func _build_swinging_cables(parent: Node3D, metal: Material) -> void:
	var points: Array[Vector3] = [
		Vector3(-12.0,4.6,-8.5),
		Vector3(10.5,4.8,10.2),
		Vector3(15.5,4.5,-6.8)
	]
	for i: int in range(points.size()):
		var cable := _box(parent,"SwingCable_%d" % i,
			points[i],Vector3(0.035,1.8,0.035),metal)
		cable.set_meta("motion_type","cable")
		cable.set_meta("motion_phase",float(i)*1.1)
		cable.set_meta("base_rotation_z",cable.rotation.z)


static func _build_fire_glow_markers(parent: Node3D, warm: Material) -> void:
	var points: Array[Vector3] = [
		Vector3(-11.0,1.03,-5.5),
		Vector3(16.0,1.03,8.0)
	]
	for i: int in range(points.size()):
		var glow := _box(parent,"AnimatedFireCore_%d" % i,
			points[i],Vector3(0.18,0.28,0.18),warm,float(i*13))
		glow.set_meta("motion_type","fire")
		glow.set_meta("motion_phase",float(i)*1.7)
		glow.set_meta("base_scale",glow.scale)


static func _attach_animator(parent: Node3D) -> void:
	var animator := Node.new()
	animator.name = "EnvironmentalMotionController"
	animator.set_script(_motion_script())
	parent.add_child(animator)


static func _motion_script() -> Script:
	var script := GDScript.new()
	script.source_code = """
extends Node
var t := 0.0

func _process(delta: float) -> void:
	t += delta
	var holder := get_parent()
	if holder == null:
		return
	for child in holder.get_children():
		if not child is Node3D:
			continue
		if not child.has_meta("motion_type"):
			continue
		var kind := str(child.get_meta("motion_type"))
		var phase := float(child.get_meta("motion_phase",0.0))

		if kind == "cloth":
			var base_z := float(child.get_meta("base_rotation_z",0.0))
			child.rotation.z = base_z + sin(t*1.15+phase)*0.025
			child.rotation.y += sin(t*0.65+phase)*0.00035

		elif kind == "paper":
			var base_y := float(child.get_meta("base_y",child.position.y))
			child.position.y = base_y + max(0.0,sin(t*1.7+phase))*0.008
			child.rotation.y += sin(t*0.8+phase)*0.0007

		elif kind == "cable":
			var base_z := float(child.get_meta("base_rotation_z",0.0))
			child.rotation.z = base_z + sin(t*0.75+phase)*0.018

		elif kind == "fire":
			var base_scale: Vector3 = child.get_meta("base_scale",Vector3.ONE)
			var pulse := 1.0 + sin(t*7.0+phase)*0.08
			child.scale = base_scale * Vector3(0.92+0.08*pulse,pulse,0.92+0.08*pulse)
"""
	script.reload()
	return script


static func _mat(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat


static func _emissive(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.2
	return mat


static func _box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	material: Material,
	yaw: float = 0.0
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = position
	mi.rotation.y = deg_to_rad(yaw)
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
