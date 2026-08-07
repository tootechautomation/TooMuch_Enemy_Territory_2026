extends RefCounted
class_name BattleDamageDetailPass

# v8.80 — visual-only battle-damage detail.
# Adds impact scars, chipped masonry, broken glass remnants and localized debris.
# No gameplay collision, weapon, objective or networking changes.

static func apply(root: Node) -> void:
	if root == null or root.has_node("BattleDamageDetailPass_v880"):
		return

	var holder := Node3D.new()
	holder.name = "BattleDamageDetailPass_v880"
	root.add_child(holder)

	var soot := _mat(Color(0.020,0.019,0.017),0.96)
	var dark := _mat(Color(0.035,0.032,0.028),0.97)
	var brick := _mat(Color(0.30,0.11,0.055),0.97)
	var plaster := _mat(Color(0.45,0.41,0.35),0.99)
	var concrete := _mat(Color(0.24,0.24,0.22),0.99)
	var metal := _mat(Color(0.07,0.075,0.073),0.48,0.68)
	var glass := _glass()
	var rubble := _mat(Color(0.16,0.15,0.135),0.99)

	_build_bullet_clusters(holder, soot, dark)
	_build_shell_scorch(holder, soot, concrete)
	_build_chipped_facades(holder, brick, plaster, concrete)
	_build_broken_window_remnants(holder, glass, metal, soot)
	_build_damage_debris(holder, rubble, brick, metal)
	_build_damaged_cover(holder, dark, metal, brick)


static func _build_bullet_clusters(
	parent: Node3D,
	soot: Material,
	dark: Material
) -> void:
	var clusters: Array[Vector3] = [
		Vector3(-14.6,1.8,-10.38),
		Vector3(-12.7,2.0,8.62),
		Vector3(10.9,1.9,9.32),
		Vector3(16.4,2.0,-8.58),
		Vector3(12.8,1.5,-2.58),
		Vector3(0.4,1.5,-8.8)
	]

	for c: int in range(clusters.size()):
		var base := clusters[c]
		for i: int in range(7):
			var angle := deg_to_rad(float(i*47+c*19))
			var radius := 0.10 + 0.055*float(i%4)
			var p := base + Vector3(
				cos(angle)*radius,
				sin(angle)*radius,
				0.0
			)

			_cyl(parent,"BulletScar",
				p,
				0.030+0.006*float(i%3),
				0.010,
				soot,
				90.0)

			if i % 2 == 0:
				_cyl(parent,"BulletChip",
					p+Vector3(0,0,-0.012),
					0.050+0.006*float(i%2),
					0.008,
					dark,
					90.0)


static func _build_shell_scorch(
	parent: Node3D,
	soot: Material,
	concrete: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-7.0,1.0,-12.3),
		Vector3(8.0,1.2,12.2),
		Vector3(18.0,1.0,4.2)
	]

	for i: int in range(points.size()):
		var p := points[i]

		_box(parent,"ShellScorch",
			p,
			Vector3(1.05,1.25,0.025),
			soot,
			float(-8+i*11))

		for chip: int in range(5):
			var angle := deg_to_rad(float(chip*72+i*13))
			_box(parent,"ShellChip",
				p+Vector3(
					cos(angle)*(0.58+0.08*float(chip%2)),
					sin(angle)*(0.48+0.06*float(chip%3)),
					-0.015
				),
				Vector3(0.18,0.14,0.06),
				concrete,
				float(chip*17))


static func _build_chipped_facades(
	parent: Node3D,
	brick: Material,
	plaster: Material,
	concrete: Material
) -> void:
	var sites: Array[Vector3] = [
		Vector3(-15.2,2.6,-10.30),
		Vector3(-11.6,2.4,8.55),
		Vector3(11.6,2.5,9.24),
		Vector3(17.1,2.4,-8.48)
	]

	for s: int in range(sites.size()):
		var base := sites[s]

		# Exposed brick patch.
		_box(parent,"ExposedMasonry",
			base,
			Vector3(0.95,0.65,0.035),
			brick,
			float(-5+s*6))

		# Thin plaster lips around the exposed patch.
		_box(parent,"PlasterLipTop",
			base+Vector3(0,0.39,-0.015),
			Vector3(1.15,0.11,0.04),
			plaster,
			float(-5+s*6))

		_box(parent,"PlasterLipSide",
			base+Vector3(-0.54,0.02,-0.015),
			Vector3(0.11,0.70,0.04),
			plaster,
			float(-5+s*6))

		# Small projecting broken masonry chunks.
		for i: int in range(4):
			_box(parent,"FacadeChip",
				base+Vector3(
					-0.36+i*0.24,
					-0.26+0.13*float(i%3),
					-0.07
				),
				Vector3(0.14,0.12,0.12),
				concrete,
				float(i*13))


static func _build_broken_window_remnants(
	parent: Node3D,
	glass: Material,
	metal: Material,
	soot: Material
) -> void:
	var windows: Array[Vector3] = [
		Vector3(-14.7,3.8,-10.24),
		Vector3(-12.0,1.8,8.52),
		Vector3(10.0,1.8,9.22),
		Vector3(16.5,1.8,-8.52)
	]

	for w: int in range(windows.size()):
		var base := windows[w]

		# Remaining frame.
		for x: float in [-0.48,0.48]:
			_box(parent,"BrokenWindowFrame",
				base+Vector3(x,0,-0.04),
				Vector3(0.06,1.02,0.08),
				metal)

		for y: float in [-0.48,0.48]:
			_box(parent,"BrokenWindowFrame",
				base+Vector3(0,y,-0.04),
				Vector3(1.02,0.06,0.08),
				metal)

		# Jagged glass shards.
		for i: int in range(5):
			var shard := _box(parent,"WindowGlassShard",
				base+Vector3(
					-0.38+i*0.19,
					-0.22+0.09*float(i%3),
					-0.08
				),
				Vector3(0.10,0.32+0.04*float(i%2),0.018),
				glass,
				float(-18+i*9))
			shard.rotation.z = deg_to_rad(float(-16+i*7))

		_box(parent,"WindowBlastSoot",
			base+Vector3(0,0.62,0.01),
			Vector3(0.75,0.18,0.022),
			soot)


static func _build_damage_debris(
	parent: Node3D,
	rubble: Material,
	brick: Material,
	metal: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-14.5,0.07,-9.8),
		Vector3(-12.5,0.07,9.0),
		Vector3(11.0,0.07,9.5),
		Vector3(16.5,0.07,-8.0)
	]

	for c: int in range(centers.size()):
		var base := centers[c]

		for i: int in range(10):
			var angle := deg_to_rad(float(i*37+c*15))
			var radius := 0.25+0.09*float(i%5)

			_box(parent,"DamageRubble",
				base+Vector3(
					cos(angle)*radius,
					0.02*float(i%3),
					sin(angle)*radius
				),
				Vector3(
					0.12+0.03*float(i%3),
					0.08+0.025*float(i%2),
					0.15+0.03*float((i+1)%3)
				),
				brick if i%3==0 else rubble,
				float(i*19))

		if c % 2 == 0:
			var scrap := _box(parent,"DamageMetal",
				base+Vector3(0.55,0.25,0.20),
				Vector3(0.06,0.75,0.08),
				metal)
			scrap.rotation.z = deg_to_rad(58.0)


static func _build_damaged_cover(
	parent: Node3D,
	dark: Material,
	metal: Material,
	brick: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-5.5,0.7,-6.0),
		Vector3(6.0,0.7,6.5),
		Vector3(11.5,0.7,-10.0)
	]

	for p_i: int in range(points.size()):
		var base := points[p_i]

		# Scorch/impact marks across combat cover.
		for i: int in range(4):
			_cyl(parent,"CoverImpact",
				base+Vector3(-0.45+i*0.30,0.18*float(i%2),-0.14),
				0.035+0.006*float(i%2),
				0.012,
				dark,
				90.0)

		# Small embedded fragments.
		for i: int in range(3):
			_box(parent,"CoverFragment",
				base+Vector3(-0.30+i*0.32,-0.45,0.20),
				Vector3(0.13,0.10,0.16),
				brick if i%2==0 else metal,
				float(i*21))


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


static func _glass() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14,0.19,0.20,0.30)
	mat.roughness = 0.16
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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
	material: Material,
	rotate_x: float = 0.0
) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mi.mesh = mesh
	mi.position = position
	mi.rotation.x = deg_to_rad(rotate_x)
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
