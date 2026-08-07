extends RefCounted
class_name ArchitecturalRealismPass

# v8.65 — visual-only architectural reconstruction and street detail.
# Existing collision/gameplay remains authoritative.

static func apply(root: Node) -> void:
	if root == null or root.has_node("ArchitecturalRealismPass_v865"):
		return

	var holder: Node3D = Node3D.new()
	holder.name = "ArchitecturalRealismPass_v865"
	root.add_child(holder)

	var brick: StandardMaterial3D = _mat(Color(0.255, 0.115, 0.067), 0.95)
	var plaster: StandardMaterial3D = _mat(Color(0.37, 0.35, 0.31), 0.96)
	var concrete: StandardMaterial3D = _mat(Color(0.285, 0.285, 0.265), 0.97)
	var wood: StandardMaterial3D = _mat(Color(0.19, 0.105, 0.045), 0.91)
	var metal: StandardMaterial3D = _mat(Color(0.10, 0.105, 0.10), 0.52, 0.62)
	var dark: StandardMaterial3D = _mat(Color(0.015, 0.017, 0.016), 0.86)
	var glass: StandardMaterial3D = _glass_mat()
	var rubble: StandardMaterial3D = _mat(Color(0.19, 0.18, 0.16), 0.98)

	_build_building_fronts(holder, brick, plaster, concrete, wood, metal, dark, glass)
	_build_damaged_corners(holder, brick, plaster, rubble)
	_build_street_furniture(holder, wood, metal, concrete)
	_build_wet_light_pools(holder)
	_build_rubble_edges(holder, rubble, brick, wood)


static func _build_building_fronts(
	parent: Node3D,
	brick: Material,
	plaster: Material,
	concrete: Material,
	wood: Material,
	metal: Material,
	dark: Material,
	glass: Material
) -> void:
	var centers: Array[Vector3] = [
		Vector3(-14.5, 0.0, -8.8),
		Vector3(-13.0, 0.0, 10.0),
		Vector3(10.8, 0.0, 10.8),
		Vector3(16.0, 0.0, -7.0)
	]
	var yaws: Array[float] = [4.0, -6.0, 5.0, -4.0]

	for b: int in range(centers.size()):
		var building: Node3D = Node3D.new()
		building.name = "ArchitecturalFront_%d" % b
		building.position = centers[b]
		building.rotation.y = deg_to_rad(yaws[b])
		parent.add_child(building)

		var facade: Material = brick if b % 2 == 0 else plaster

		# Ground floor wall strips leave real recessed openings between them.
		_box(building, "GroundLeft", Vector3(-2.35, 1.35, 0.0),
			Vector3(1.7, 2.7, 0.42), facade)
		_box(building, "GroundMid", Vector3(0.25, 1.35, 0.0),
			Vector3(1.15, 2.7, 0.42), facade)
		_box(building, "GroundRight", Vector3(2.25, 1.35, 0.0),
			Vector3(1.45, 2.7, 0.42), facade)

		# Upper floor mass.
		_box(building, "UpperWall", Vector3(0.0, 3.75, 0.0),
			Vector3(6.0, 2.1, 0.42), facade)

		# Deep doorway.
		_box(building, "DoorVoid", Vector3(-1.15, 1.05, -0.24),
			Vector3(1.05, 2.15, 0.18), dark)
		_box(building, "DoorFrameL", Vector3(-1.72, 1.05, -0.31),
			Vector3(0.12, 2.25, 0.20), wood)
		_box(building, "DoorFrameR", Vector3(-0.58, 1.05, -0.31),
			Vector3(0.12, 2.25, 0.20), wood)
		_box(building, "DoorLintel", Vector3(-1.15, 2.20, -0.31),
			Vector3(1.28, 0.16, 0.24), concrete)

		# Recessed windows with glass and mullions.
		var window_xs: Array[float] = [0.95, 2.15]
		for wx: float in window_xs:
			_box(building, "WindowVoid", Vector3(wx, 1.55, -0.24),
				Vector3(0.95, 1.20, 0.18), dark)
			_box(building, "WindowGlass", Vector3(wx, 1.55, -0.34),
				Vector3(0.80, 1.03, 0.035), glass)
			_box(building, "WindowMullionV", Vector3(wx, 1.55, -0.37),
				Vector3(0.055, 1.02, 0.065), metal)
			_box(building, "WindowMullionH", Vector3(wx, 1.55, -0.37),
				Vector3(0.79, 0.055, 0.065), metal)
			_box(building, "WindowSill", Vector3(wx, 0.88, -0.36),
				Vector3(1.08, 0.14, 0.30), concrete)

		# Upper windows.
		for wx: float in [-1.75, 0.0, 1.75]:
			_box(building, "UpperWindowVoid", Vector3(wx, 3.80, -0.24),
				Vector3(0.90, 1.05, 0.18), dark)
			_box(building, "UpperWindowGlass", Vector3(wx, 3.80, -0.34),
				Vector3(0.75, 0.90, 0.035), glass)
			_box(building, "UpperSill", Vector3(wx, 3.17, -0.35),
				Vector3(1.02, 0.12, 0.28), concrete)

		# Projecting cornice and gutter.
		_box(building, "Cornice", Vector3(0.0, 4.95, -0.12),
			Vector3(6.35, 0.20, 0.55), concrete)
		_box(building, "Gutter", Vector3(0.0, 5.06, -0.42),
			Vector3(5.9, 0.08, 0.10), metal)

		for sx: float in [-2.65, 2.65]:
			_box(building, "Downspout", Vector3(sx, 2.45, -0.43),
				Vector3(0.08, 4.9, 0.09), metal)


static func _build_damaged_corners(
	parent: Node3D,
	brick: Material,
	plaster: Material,
	rubble: Material
) -> void:
	var positions: Array[Vector3] = [
		Vector3(-10.0, 0.0, -12.5),
		Vector3(8.5, 0.0, 12.8),
		Vector3(18.5, 0.0, -3.0)
	]

	for index: int in range(positions.size()):
		var damage: Node3D = Node3D.new()
		damage.name = "DamagedCorner_%d" % index
		damage.position = positions[index]
		damage.rotation.y = deg_to_rad(float(index * 21 - 12))
		parent.add_child(damage)

		var mat: Material = brick if index % 2 == 0 else plaster

		_box(damage, "WallA", Vector3(-1.25, 1.65, 0.0),
			Vector3(2.5, 3.3, 0.38), mat)
		_box(damage, "WallB", Vector3(0.0, 1.25, 1.25),
			Vector3(0.38, 2.5, 2.5), mat)

		# Jagged broken-top blocks.
		for i: int in range(5):
			_box(damage, "BrokenTop",
				Vector3(-2.0 + i*0.55, 3.35 + 0.16*float(i%3), 0.0),
				Vector3(0.48, 0.42, 0.38),
				mat,
				float(i*5)
			)

		for i: int in range(8):
			var angle: float = deg_to_rad(float(i*43 + index*17))
			_box(damage, "CornerRubble",
				Vector3(cos(angle)*1.1, 0.10, sin(angle)*0.75),
				Vector3(0.16+0.03*float(i%3),0.10,0.20),
				rubble,
				float(i*19)
			)


static func _build_street_furniture(
	parent: Node3D,
	wood: Material,
	metal: Material,
	concrete: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-5.5,0.0,-4.5),
		Vector3(5.5,0.0,5.0),
		Vector3(12.5,0.0,-5.5),
		Vector3(-12.0,0.0,5.5)
	]

	for p: int in range(points.size()):
		var base: Vector3 = points[p]

		# Lamp pole + hood.
		_box(parent, "StreetPole", base+Vector3.UP*1.45,
			Vector3(0.08,2.9,0.08), metal)
		_box(parent, "LampArm", base+Vector3(0.26,2.78,0),
			Vector3(0.55,0.07,0.08), metal)
		_box(parent, "LampHood", base+Vector3(0.52,2.70,0),
			Vector3(0.30,0.16,0.28), metal)

		# Bench/crate-like street clutter.
		_box(parent, "BenchSeat", base+Vector3(1.1,0.48,0.3),
			Vector3(1.5,0.12,0.42), wood, 8.0)
		for x: float in [0.55, 1.65]:
			_box(parent, "BenchLeg", base+Vector3(x,0.25,0.3),
				Vector3(0.10,0.48,0.10), metal)

		# Concrete curb/broken block.
		_box(parent, "CurbBlock", base+Vector3(-0.85,0.15,0.65),
			Vector3(1.2,0.30,0.36), concrete, -6.0)


static func _build_wet_light_pools(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-5.0, 0.04, -4.2),
		Vector3(5.0, 0.04, 4.7),
		Vector3(12.0, 0.04, -5.2),
		Vector3(-11.5, 0.04, 5.2)
	]

	var wet: StandardMaterial3D = _mat(Color(0.055,0.060,0.060),0.14)

	for i: int in range(positions.size()):
		_box(parent, "LampWetPool", positions[i],
			Vector3(2.4,0.012,1.3), wet, float(i*15))

		var light: OmniLight3D = OmniLight3D.new()
		light.name = "StreetWarm_%d" % i
		light.position = positions[i] + Vector3(0.5,2.65,0.0)
		light.light_color = Color(1.0,0.55,0.22)
		light.light_energy = 0.48
		light.omni_range = 4.6
		light.shadow_enabled = true
		parent.add_child(light)


static func _build_rubble_edges(
	parent: Node3D,
	rubble: Material,
	brick: Material,
	wood: Material
) -> void:
	var lines: Array[Vector3] = [
		Vector3(-2.0,0.06,7.5),
		Vector3(7.5,0.06,-2.5),
		Vector3(-9.0,0.06,-7.0)
	]

	for line_index: int in range(lines.size()):
		var base: Vector3 = lines[line_index]
		for i: int in range(10):
			var x: float = -1.7 + i*0.38
			_box(parent, "EdgeRubble",
				base + Vector3(x,0.03*float(i%3),0.15*float((i+line_index)%2)),
				Vector3(0.18,0.12+0.03*float(i%2),0.22),
				brick if i%3==0 else rubble,
				float(i*11)
			)

		for i: int in range(2):
			_box(parent, "EdgeTimber",
				base + Vector3(-0.6+i*1.2,0.16,0.55),
				Vector3(1.4,0.10,0.12),
				wood,
				-18.0+36.0*i
			)


static func _glass_mat() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.13, 0.14, 0.38)
	mat.roughness = 0.20
	mat.metallic = 0.05
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


static func _mat(
	color: Color,
	roughness: float,
	metallic: float = 0.0
) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
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
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = position
	mi.rotation.y = deg_to_rad(yaw)
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)
	return mi
