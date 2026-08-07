extends RefCounted
class_name FacadeStreetDressingPass

# v8.78 — visual-only facade identity and wartime street dressing.
# No collision, weapon, objective or networking changes.

static func apply(root: Node) -> void:
	if root == null or root.has_node("FacadeStreetDressingPass_v878"):
		return

	var holder := Node3D.new()
	holder.name = "FacadeStreetDressingPass_v878"
	root.add_child(holder)

	var wood := _mat(Color(0.17,0.09,0.04),0.94)
	var dark_wood := _mat(Color(0.10,0.052,0.025),0.97)
	var metal := _mat(Color(0.075,0.080,0.078),0.48,0.68)
	var rust := _mat(Color(0.19,0.07,0.025),0.80,0.18)
	var plaster := _mat(Color(0.36,0.34,0.30),0.98)
	var canvas := _mat(Color(0.18,0.17,0.11),0.99)
	var dark := _mat(Color(0.025,0.024,0.022),0.95)
	var glass := _glass()
	var paper := _mat(Color(0.52,0.46,0.34),0.99)

	_build_shutters_and_boarding(holder, wood, dark_wood, metal)
	_build_awnings(holder, canvas, metal)
	_build_hanging_signs(holder, wood, metal, paper)
	_build_wall_utilities(holder, metal, rust, plaster, dark)
	_build_wall_lamps(holder, metal, glass)
	_build_service_doors(holder, wood, metal, dark)
	_build_facade_cables(holder, metal)


static func _build_shutters_and_boarding(
	parent: Node3D,
	wood: Material,
	dark_wood: Material,
	metal: Material
) -> void:
	var windows: Array[Vector3] = [
		Vector3(-15.2,1.7,-10.15),
		Vector3(-12.1,1.8,8.45),
		Vector3(10.0,1.8,9.15),
		Vector3(16.7,1.7,-8.45),
		Vector3(-14.7,3.8,-10.2),
		Vector3(11.3,3.8,9.2)
	]

	for i: int in range(windows.size()):
		var p := windows[i]

		if i % 2 == 0:
			# hinged shutters
			var left := _box(
				parent,"ShutterLeft",p+Vector3(-0.58,0,-0.05),
				Vector3(0.42,1.05,0.08),wood,float(-15+i*3)
			)
			left.rotation.z = deg_to_rad(-2.0)

			var right := _box(
				parent,"ShutterRight",p+Vector3(0.58,0,-0.05),
				Vector3(0.42,1.05,0.08),wood,float(14-i*2)
			)
			right.rotation.z = deg_to_rad(2.0)

			for y: float in [-0.28,0.0,0.28]:
				_box(parent,"ShutterBrace",
					p+Vector3(-0.58,y,-0.10),
					Vector3(0.36,0.06,0.045),dark_wood)
				_box(parent,"ShutterBrace",
					p+Vector3(0.58,y,-0.10),
					Vector3(0.36,0.06,0.045),dark_wood)
		else:
			# hastily boarded window
			for board: int in range(4):
				var plank := _box(
					parent,"WindowBoard",
					p+Vector3(-0.42+board*0.28,0,-0.10),
					Vector3(0.20,1.15,0.075),
					wood,
					float(-8+board*5)
				)
				plank.rotation.z = deg_to_rad(float(-6+board*4))

			_box(parent,"BoardingBandTop",
				p+Vector3(0,0.38,-0.14),
				Vector3(1.15,0.08,0.05),metal)
			_box(parent,"BoardingBandBottom",
				p+Vector3(0,-0.38,-0.14),
				Vector3(1.15,0.08,0.05),metal)


static func _build_awnings(
	parent: Node3D,
	canvas: Material,
	metal: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-13.8,2.55,-10.4),
		Vector3(-11.5,2.55,8.7),
		Vector3(10.7,2.55,9.45),
		Vector3(16.2,2.55,-8.7)
	]

	for i: int in range(points.size()):
		var p := points[i]

		var awning := _box(
			parent,"CanvasAwning",p,
			Vector3(2.0,0.10,1.15),canvas,float(-3+i*2)
		)
		awning.rotation.x = deg_to_rad(9.0)

		for x: float in [-0.85,0.85]:
			var brace := _box(
				parent,"AwningBrace",p+Vector3(x,-0.55,-0.35),
				Vector3(0.055,1.15,0.055),metal
			)
			brace.rotation.x = deg_to_rad(-32.0)


static func _build_hanging_signs(
	parent: Node3D,
	wood: Material,
	metal: Material,
	paper: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-16.8,2.7,-9.7),
		Vector3(-10.7,2.8,9.1),
		Vector3(12.0,2.7,9.8)
	]

	for i: int in range(points.size()):
		var p := points[i]

		_box(parent,"SignBracket",
			p+Vector3(0,0.15,0),
			Vector3(0.85,0.07,0.07),metal)

		_box(parent,"SignDrop",
			p+Vector3(0.35,-0.25,0),
			Vector3(0.05,0.75,0.05),metal)

		var sign := _box(
			parent,"HangingSign",
			p+Vector3(0.35,-0.68,0),
			Vector3(1.15,0.55,0.10),wood,float(-5+i*5)
		)

		# faded inset panel
		_box(parent,"SignFace",
			sign.position+Vector3(0,0,-0.06),
			Vector3(0.90,0.35,0.02),paper,float(-5+i*5))


static func _build_wall_utilities(
	parent: Node3D,
	metal: Material,
	rust: Material,
	plaster: Material,
	dark: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-16.1,1.25,-10.25),
		Vector3(-10.9,1.3,8.55),
		Vector3(12.1,1.3,9.25),
		Vector3(17.2,1.3,-8.5)
	]

	for i: int in range(points.size()):
		var p := points[i]

		_box(parent,"WallUtilityBox",
			p,Vector3(0.52,0.72,0.20),metal)

		_box(parent,"UtilityDoor",
			p+Vector3(0,0,-0.12),
			Vector3(0.38,0.54,0.025),dark)

		_box(parent,"UtilityConduit",
			p+Vector3(0.34,0.70,0.02),
			Vector3(0.06,1.3,0.06),rust)

		_box(parent,"UtilityRepairPatch",
			p+Vector3(-0.52,0.05,0.08),
			Vector3(0.48,0.92,0.035),plaster,float(i*3))


static func _build_wall_lamps(
	parent: Node3D,
	metal: Material,
	glass: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-14.4,2.45,-10.35),
		Vector3(-12.3,2.45,8.65),
		Vector3(10.9,2.45,9.35),
		Vector3(16.5,2.45,-8.6)
	]

	for i: int in range(points.size()):
		var p := points[i]

		_box(parent,"WallLampArm",
			p+Vector3(0,-0.05,0),
			Vector3(0.42,0.06,0.06),metal)

		_box(parent,"WallLampHood",
			p+Vector3(0.25,-0.08,-0.05),
			Vector3(0.34,0.18,0.32),metal)

		var glass_part := _box(
			parent,"WallLampGlass",
			p+Vector3(0.25,-0.25,-0.05),
			Vector3(0.18,0.18,0.18),glass
		)
		glass_part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		var light := OmniLight3D.new()
		light.name = "FacadeLamp_%d" % i
		light.position = p+Vector3(0.25,-0.28,-0.15)
		light.light_color = Color(1.0,0.58,0.25)
		light.light_energy = 0.30
		light.omni_range = 3.4
		light.shadow_enabled = true
		parent.add_child(light)


static func _build_service_doors(
	parent: Node3D,
	wood: Material,
	metal: Material,
	dark: Material
) -> void:
	var points: Array[Vector3] = [
		Vector3(-17.0,1.05,-8.6),
		Vector3(-10.3,1.05,10.0),
		Vector3(13.0,1.05,10.4)
	]

	for i: int in range(points.size()):
		var p := points[i]

		_box(parent,"ServiceDoorVoid",
			p+Vector3(0,0,0.04),
			Vector3(1.15,2.10,0.08),dark)

		_box(parent,"ServiceDoor",
			p+Vector3(0,0,-0.04),
			Vector3(1.00,1.95,0.10),wood,float(-4+i*4))

		for y: float in [-0.55,0.0,0.55]:
			_box(parent,"DoorBrace",
				p+Vector3(0,y,-0.11),
				Vector3(0.92,0.08,0.05),metal,float(-4+i*4))

		_cyl(parent,"DoorHandle",
			p+Vector3(0.33,0.0,-0.15),
			0.045,0.09,metal,90.0)


static func _build_facade_cables(
	parent: Node3D,
	metal: Material
) -> void:
	var spans: Array[Dictionary] = [
		{"a":Vector3(-16.5,3.6,-10.3),"b":Vector3(-12.7,3.2,-10.3)},
		{"a":Vector3(-12.8,3.6,8.8),"b":Vector3(-9.8,3.3,8.8)},
		{"a":Vector3(10.7,3.5,9.4),"b":Vector3(13.8,3.1,9.4)},
		{"a":Vector3(15.3,3.5,-8.7),"b":Vector3(18.2,3.15,-8.7)}
	]

	for i: int in range(spans.size()):
		var d: Dictionary = spans[i]
		_cable(parent,"FacadeCable_%d" % i,d["a"],d["b"],metal)


static func _cable(
	parent: Node3D,
	name: String,
	a: Vector3,
	b: Vector3,
	material: Material
) -> void:
	var delta := b-a
	var length := delta.length()
	if length <= 0.01:
		return

	var cable := MeshInstance3D.new()
	cable.name = name

	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.018
	mesh.bottom_radius = 0.018
	mesh.height = length
	mesh.radial_segments = 8
	cable.mesh = mesh
	cable.material_override = material
	cable.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	parent.add_child(cable)

	var y_axis := delta.normalized()
	var reference := Vector3.FORWARD
	if absf(y_axis.dot(reference)) > 0.92:
		reference = Vector3.RIGHT

	var x_axis := reference.cross(y_axis).normalized()
	var z_axis := x_axis.cross(y_axis).normalized()
	cable.transform = Transform3D(
		Basis(x_axis,y_axis,z_axis).orthonormalized(),
		(a+b)*0.5
	)


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
	mat.albedo_color = Color(0.55,0.42,0.22,0.28)
	mat.roughness = 0.18
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
