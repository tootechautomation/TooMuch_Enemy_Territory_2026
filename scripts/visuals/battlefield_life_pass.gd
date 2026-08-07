extends RefCounted
class_name BattlefieldLifePass

# v8.67 — visual-only battlefield life, destruction and silhouette pass.
# Keeps all existing collision/gameplay authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("BattlefieldLifePass_v867"):
		return

	var holder := Node3D.new()
	holder.name = "BattlefieldLifePass_v867"
	root.add_child(holder)

	var brick := _mat(Color(0.24,0.105,0.060),0.96)
	var concrete := _mat(Color(0.25,0.25,0.23),0.98)
	var wood := _mat(Color(0.16,0.085,0.035),0.94)
	var metal := _mat(Color(0.085,0.09,0.085),0.48,0.68)
	var rust := _mat(Color(0.19,0.075,0.028),0.80,0.25)
	var dark := _mat(Color(0.018,0.019,0.018),0.90)
	var earth := _mat(Color(0.085,0.067,0.042),0.99)
	var sand := _mat(Color(0.31,0.275,0.19),0.99)

	_build_destroyed_street(holder, brick, concrete, wood, metal, rust, dark)
	_build_trench_edges(holder, earth, wood, sand)
	_build_utility_lines(holder, wood, metal)
	_build_battlefield_fires(holder, metal, dark)
	_build_rubble_transitions(holder, brick, concrete, wood)
	_build_depth_lights(holder)


static func _build_destroyed_street(
	parent: Node3D,
	brick: Material,
	concrete: Material,
	wood: Material,
	metal: Material,
	rust: Material,
	dark: Material
) -> void:
	var sites: Array[Vector3] = [
		Vector3(-7.5,0.0,-12.0),
		Vector3(8.5,0.0,12.5),
		Vector3(18.0,0.0,4.5)
	]

	for s: int in range(sites.size()):
		var base := sites[s]
		# Collapsed facade fragments.
		for i: int in range(7):
			var piece := _box(parent,"CollapsedWall",
				base + Vector3(-1.8+i*0.55,0.28+0.08*float(i%3),0.0),
				Vector3(0.50,0.45+0.12*float(i%2),0.34),
				brick if i%2==0 else concrete,
				float(-18+i*7))
			piece.rotation.z = deg_to_rad(float(-8+(i%4)*6))

		# Broken timber and steel poking through the pile.
		for i: int in range(4):
			var beam := _box(parent,"CollapsedTimber",
				base + Vector3(-1.2+i*0.75,0.55,0.45),
				Vector3(1.55,0.12,0.14),
				wood,float(i*13-18))
			beam.rotation.z = deg_to_rad(float(-15+i*9))

		for i: int in range(2):
			var bar := _box(parent,"BentSteel",
				base + Vector3(-0.5+i*1.4,0.65,-0.35),
				Vector3(0.07,1.35,0.07),rust)
			bar.rotation.z = deg_to_rad(-38.0 if i==0 else 42.0)

		# Dark gap behind collapse adds depth.
		_box(parent,"CollapseVoid",base+Vector3(0.0,1.05,0.48),
			Vector3(3.2,1.6,0.14),dark)


static func _build_trench_edges(
	parent: Node3D,
	earth: Material,
	wood: Material,
	sand: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-17.0,0.0,3.0),
		Vector3(14.0,0.0,14.5)
	]

	for c: int in range(centers.size()):
		var base := centers[c]
		# Low earth berms imply fighting positions without changing navigation.
		for side: int in [-1,1]:
			for i: int in range(7):
				_box(parent,"EarthBerm",
					base+Vector3(float(side)*1.15,0.20,-2.0+i*0.65),
					Vector3(0.75,0.38,0.62),earth,float(i*4))

		# Timber revetment.
		for i: int in range(5):
			_box(parent,"TrenchTimber",
				base+Vector3(0.0,0.35,-1.7+i*0.82),
				Vector3(2.0,0.10,0.13),wood)

		# Sandbag firing lip.
		for i: int in range(5):
			_box(parent,"TrenchSandbag",
				base+Vector3(-0.95+i*0.47,0.50,-2.25),
				Vector3(0.42,0.18,0.28),sand,float(i*3))


static func _build_utility_lines(
	parent: Node3D,
	wood: Material,
	metal: Material
) -> void:
	var poles: Array[Vector3] = [
		Vector3(-18.0,0.0,-9.0),
		Vector3(-8.0,0.0,-8.0),
		Vector3(3.0,0.0,-7.5),
		Vector3(14.0,0.0,-7.0)
	]

	for i: int in range(poles.size()):
		var p := poles[i]
		_box(parent,"UtilityPole",p+Vector3.UP*2.7,
			Vector3(0.16,5.4,0.16),wood)
		_box(parent,"UtilityCrossarm",p+Vector3(0,4.8,0),
			Vector3(1.5,0.13,0.13),wood)
		for x: float in [-0.55,0.0,0.55]:
			_cyl(parent,"Insulator",p+Vector3(x,4.98,0),
				0.055,0.18,metal)

	# Dark thin cable spans.
	for i: int in range(poles.size()-1):
		var a := poles[i] + Vector3(0,5.0,0)
		var b := poles[i+1] + Vector3(0,5.0,0)
		for offset: float in [-0.55,0.0,0.55]:
			_cable(parent,a+Vector3(offset,0,0),b+Vector3(offset,0,0),metal)


static func _build_battlefield_fires(
	parent: Node3D,
	metal: Material,
	dark: Material
) -> void:
	var positions: Array[Vector3] = [
		Vector3(-11.0,0.0,-5.5),
		Vector3(16.0,0.0,8.0)
	]

	for i: int in range(positions.size()):
		var p := positions[i]
		_cyl(parent,"BurnBarrel",p+Vector3.UP*0.48,0.34,0.95,metal)
		_box(parent,"BarrelDarkTop",p+Vector3(0,0.96,0),
			Vector3(0.54,0.03,0.54),dark)

		var fire := OmniLight3D.new()
		fire.name = "FireGlow_%d" % i
		fire.position = p + Vector3(0,1.15,0)
		fire.light_color = Color(1.0,0.34,0.08)
		fire.light_energy = 0.65
		fire.omni_range = 4.2
		fire.shadow_enabled = true
		parent.add_child(fire)

		var particles := GPUParticles3D.new()
		particles.name = "FireSmoke_%d" % i
		particles.position = p + Vector3(0,1.0,0)
		particles.amount = 14
		particles.lifetime = 3.8
		particles.randomness = 0.7
		particles.visibility_aabb = AABB(Vector3(-2,0,-2),Vector3(4,8,4))
		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.03,1.0,0.02)
		process.spread = 14.0
		process.initial_velocity_min = 0.30
		process.initial_velocity_max = 0.65
		particles.process_material = process
		var quad := QuadMesh.new()
		quad.size = Vector2(0.75,0.75)
		var smoke := StandardMaterial3D.new()
		smoke.albedo_color = Color(0.06,0.055,0.05,0.20)
		smoke.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smoke.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = smoke
		particles.draw_pass_1 = quad
		parent.add_child(particles)


static func _build_rubble_transitions(
	parent: Node3D,
	brick: Material,
	concrete: Material,
	wood: Material
) -> void:
	var edges: Array[Vector3] = [
		Vector3(-3.0,0.0,-13.5),
		Vector3(4.0,0.0,13.8),
		Vector3(19.0,0.0,-1.5)
	]
	for e: int in range(edges.size()):
		var base := edges[e]
		for i: int in range(15):
			var angle := deg_to_rad(float(i*31+e*17))
			var radius := 0.35+0.10*float(i%6)
			_box(parent,"TransitionRubble",
				base+Vector3(cos(angle)*radius,0.06+0.025*float(i%3),sin(angle)*radius),
				Vector3(0.13+0.03*float(i%3),0.10,0.17+0.02*float(i%2)),
				brick if i%3==0 else concrete,float(i*13))
		for i: int in range(2):
			_box(parent,"TransitionBoard",
				base+Vector3(-0.5+i,0.14,0.5),
				Vector3(1.25,0.09,0.11),wood,float(-20+i*37))


static func _build_depth_lights(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-14.0,2.4,-10.0),
		Vector3(11.0,2.5,11.0),
		Vector3(17.0,2.3,-7.0)
	]
	for i: int in range(positions.size()):
		var light := OmniLight3D.new()
		light.name = "DepthPractical_%d" % i
		light.position = positions[i]
		light.light_color = Color(1.0,0.62,0.29)
		light.light_energy = 0.30
		light.omni_range = 4.8
		light.shadow_enabled = true
		parent.add_child(light)


static func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
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


static func _cyl(
	parent: Node3D,
	name: String,
	position: Vector3,
	radius: float,
	height: float,
	material: Material
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mi.mesh = mesh
	mi.position = position
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi


static func _cable(
	parent: Node3D,
	a: Vector3,
	b: Vector3,
	material: Material
) -> void:
	var delta := b-a
	var length := delta.length()
	if length <= 0.01:
		return
	var cable := _cyl(parent,"UtilityCable",(a+b)*0.5,0.018,length,material)
	cable.basis = Basis.looking_at(delta.normalized(),Vector3.UP).rotated(Vector3.RIGHT,PI*0.5)
