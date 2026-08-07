extends RefCounted
class_name RainInteractionPass

# v8.77 — visual-only rain/world interaction pass.
# Adds drips, splash zones, puddle ripples and wet edge breakup without
# changing gameplay collision, weapons, objectives or networking.

static func apply(root: Node) -> void:
	if root == null or root.has_node("RainInteractionPass_v877"):
		return

	var holder := Node3D.new()
	holder.name = "RainInteractionPass_v877"
	root.add_child(holder)

	var wet_concrete := _mat(Color(0.18,0.19,0.18),0.22)
	var wet_road := _mat(Color(0.055,0.060,0.060),0.12)
	var dark_damp := _mat(Color(0.07,0.065,0.055),0.58)
	var metal := _mat(Color(0.07,0.075,0.073),0.34,0.62)

	_build_roof_drips(holder)
	_build_puddle_ripples(holder, wet_road)
	_build_splash_fields(holder)
	_build_wet_curb_edges(holder, wet_concrete, dark_damp)
	_build_downspout_splash(holder, metal, wet_road)
	_attach_ripple_animator(holder)


static func _build_roof_drips(parent: Node3D) -> void:
	var points: Array[Vector3] = [
		Vector3(-14.5,5.0,-10.2),
		Vector3(-13.0,5.0,8.5),
		Vector3(10.8,5.0,9.2),
		Vector3(16.0,5.0,-8.5),
		Vector3(0.0,3.0,7.6),
		Vector3(13.0,2.8,-2.4)
	]

	for i: int in range(points.size()):
		var particles := GPUParticles3D.new()
		particles.name = "RoofDrip_%d" % i
		particles.position = points[i]
		particles.amount = 14
		particles.lifetime = 0.95
		particles.randomness = 0.75
		particles.visibility_aabb = AABB(
			Vector3(-1.0,-4.0,-1.0),
			Vector3(2.0,5.0,2.0)
		)

		var process := ParticleProcessMaterial.new()
		process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		process.emission_box_extents = Vector3(0.85,0.03,0.10)
		process.direction = Vector3(0,-1,0)
		process.spread = 3.5
		process.initial_velocity_min = 2.4
		process.initial_velocity_max = 3.6
		process.gravity = Vector3(0,-4.0,0)
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(0.018,0.18)
		var water := StandardMaterial3D.new()
		water.albedo_color = Color(0.60,0.70,0.76,0.42)
		water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		water.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = water
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_puddle_ripples(
	parent: Node3D,
	wet_road: Material
) -> void:
	var puddles: Array[Vector3] = [
		Vector3(-4.0,0.032,2.5),
		Vector3(3.5,0.032,-1.5),
		Vector3(9.5,0.032,7.0),
		Vector3(-10.5,0.032,7.5),
		Vector3(15.5,0.032,-5.0),
		Vector3(-5.0,0.032,-4.2),
		Vector3(5.0,0.032,4.7)
	]

	for i: int in range(puddles.size()):
		var base := puddles[i]
		_box(parent,"WetPuddleBase_%d" % i,base,
			Vector3(1.65,0.012,0.90),wet_road,float(i*11))

		for ring: int in range(3):
			var ripple := MeshInstance3D.new()
			ripple.name = "RainRipple_%d_%d" % [i,ring]
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.14 + 0.10*float(ring)
			mesh.bottom_radius = 0.14 + 0.10*float(ring)
			mesh.height = 0.008
			mesh.radial_segments = 24
			ripple.mesh = mesh
			ripple.position = base + Vector3(
				-0.35 + 0.32*float(ring),
				0.018,
				0.14*float((ring+i)%2)
			)

			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.55,0.66,0.72,0.16)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ripple.material_override = mat
			ripple.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			ripple.set_meta("rain_ripple",true)
			ripple.set_meta("phase",float(i*3+ring)*0.55)
			ripple.set_meta("base_scale",Vector3.ONE)
			parent.add_child(ripple)


static func _build_splash_fields(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-6.0,0.05,0.0),
		Vector3(6.0,0.05,0.0),
		Vector3(0.0,0.05,7.0),
		Vector3(0.0,0.05,-7.0),
		Vector3(13.0,0.05,0.0)
	]

	for i: int in range(positions.size()):
		var particles := GPUParticles3D.new()
		particles.name = "RainSplashField_%d" % i
		particles.position = positions[i]
		particles.amount = 26
		particles.lifetime = 0.30
		particles.randomness = 1.0
		particles.explosiveness = 0.85
		particles.visibility_aabb = AABB(
			Vector3(-3.5,-0.2,-3.5),
			Vector3(7.0,1.5,7.0)
		)

		var process := ParticleProcessMaterial.new()
		process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		process.emission_box_extents = Vector3(3.0,0.02,3.0)
		process.direction = Vector3(0,1,0)
		process.spread = 42.0
		process.initial_velocity_min = 0.18
		process.initial_velocity_max = 0.52
		process.gravity = Vector3(0,-2.2,0)
		particles.process_material = process

		var quad := QuadMesh.new()
		quad.size = Vector2(0.028,0.075)
		var splash := StandardMaterial3D.new()
		splash.albedo_color = Color(0.66,0.76,0.82,0.34)
		splash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		splash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		splash.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		quad.material = splash
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_wet_curb_edges(
	parent: Node3D,
	wet_concrete: Material,
	dark_damp: Material
) -> void:
	var strips: Array[Dictionary] = [
		{"p":Vector3(-11.5,0.185,-2.22),"s":Vector3(9.3,0.022,0.24),"r":2.0},
		{"p":Vector3(11.5,0.185,2.22),"s":Vector3(9.3,0.022,0.24),"r":-2.0},
		{"p":Vector3(-2.22,0.185,10.8),"s":Vector3(0.24,0.022,7.8),"r":0.0},
		{"p":Vector3(2.22,0.185,-10.8),"s":Vector3(0.24,0.022,7.8),"r":0.0}
	]

	for i: int in range(strips.size()):
		var d: Dictionary = strips[i]
		_box(parent,"WetCurbTop_%d" % i,d["p"],d["s"],wet_concrete,float(d["r"]))
		var p: Vector3 = d["p"]
		_box(parent,"CurbDampLine_%d" % i,
			p+Vector3(0,-0.07,0),
			Vector3(
				float(d["s"].x),
				0.055,
				float(d["s"].z)
			),
			dark_damp,
			float(d["r"])
		)


static func _build_downspout_splash(
	parent: Node3D,
	metal: Material,
	wet_road: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-17.1,0.0,-9.4),
		Vector3(-10.4,0.0,9.6),
		Vector3(8.2,0.0,10.3),
		Vector3(18.6,0.0,-7.4)
	]

	for i: int in range(points.size()):
		var p := points[i]
		_box(parent,"DownspoutLower_%d" % i,p+Vector3(0,0.65,0),
			Vector3(0.08,1.30,0.08),metal)
		_box(parent,"DownspoutWetPatch_%d" % i,p+Vector3(0,0.018,0.25),
			Vector3(0.95,0.010,0.72),wet_road,float(i*14))


static func _attach_ripple_animator(parent: Node3D) -> void:
	var animator := Node.new()
	animator.name = "RainRippleController"
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
		if not child.has_meta("rain_ripple"):
			continue

		var phase := float(child.get_meta("phase",0.0))
		var base_scale: Vector3 = child.get_meta("base_scale",Vector3.ONE)
		var cycle := fmod(t*0.70 + phase, 1.0)

		var scale_amount := lerpf(0.45,1.55,cycle)
		child.scale = base_scale * Vector3(scale_amount,1.0,scale_amount)

		var mesh_instance := child as MeshInstance3D
		if mesh_instance != null and mesh_instance.material_override is StandardMaterial3D:
			var material := mesh_instance.material_override as StandardMaterial3D
			var alpha := (1.0-cycle)*0.18
			var c := material.albedo_color
			c.a = alpha
			material.albedo_color = c
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
