extends Node3D
class_name ConceptArtRealismPass2

const BUILD_SEED := 8442026

var _materials: Dictionary = {}
var _rng := RandomNumberGenerator.new()

func build(root: Node) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_rng.seed = BUILD_SEED
	_build_village_facade_depth()
	_build_fort_wall_depth()
	_build_rail_yard_detail()
	_build_ground_microgeometry()
	_build_battlefield_rubble()
	_build_cinematic_prop_density()
	_build_drainage_and_wet_edges()
	_upgrade_lighting_microcontrast(root)

func _texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

func _material(
	key: String,
	albedo_path: String,
	normal_path: String,
	roughness_path: String,
	color: Color,
	roughness_value: float,
	uv_scale: float = 1.0,
	metallic_value: float = 0.0
) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness_value
	mat.metallic = metallic_value
	mat.uv1_scale = Vector3(uv_scale, uv_scale, uv_scale)
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	var albedo := _texture(albedo_path)
	var normal := _texture(normal_path)
	var rough := _texture(roughness_path)
	if albedo != null:
		mat.albedo_texture = albedo
	if normal != null:
		mat.normal_enabled = true
		mat.normal_texture = normal
		mat.normal_scale = 1.15
	if rough != null:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	_materials[key] = mat
	return mat

func _plain(
	key: String,
	color: Color,
	roughness_value: float,
	metallic_value: float = 0.0
) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness_value
	mat.metallic = metallic_value
	_materials[key] = mat
	return mat

func _brick() -> StandardMaterial3D:
	return _material(
		"p2_brick",
		"res://assets/cc0/ambientcg/Bricks097/Bricks097_Color.jpg",
		"res://assets/cc0/ambientcg/Bricks097/Bricks097_NormalGL.jpg",
		"res://assets/cc0/ambientcg/Bricks097/Bricks097_Roughness.jpg",
		Color(0.66, 0.57, 0.50), 0.88, 2.6
	)

func _concrete() -> StandardMaterial3D:
	return _material(
		"p2_concrete",
		"res://assets/pbr/concrete_albedo.png",
		"res://assets/pbr/concrete_normal.png",
		"res://assets/pbr/concrete_roughness.png",
		Color(0.62, 0.63, 0.60), 0.91, 2.8
	)

func _plaster() -> StandardMaterial3D:
	return _material(
		"p2_plaster",
		"res://assets/pbr/damaged_plaster_albedo.png",
		"res://assets/pbr/damaged_plaster_normal.png",
		"res://assets/pbr/damaged_plaster_roughness.png",
		Color(0.76, 0.72, 0.63), 0.93, 2.2
	)

func _wood() -> StandardMaterial3D:
	return _material(
		"p2_wood",
		"res://assets/pbr/wood_albedo.png",
		"res://assets/pbr/wood_normal.png",
		"res://assets/pbr/wood_roughness.png",
		Color(0.48, 0.36, 0.25), 0.82, 2.4
	)

func _metal() -> StandardMaterial3D:
	return _material(
		"p2_metal",
		"res://assets/pbr/rusted_metal_albedo.png",
		"res://assets/pbr/rusted_metal_normal.png",
		"res://assets/pbr/rusted_metal_roughness.png",
		Color(0.55, 0.52, 0.47), 0.61, 3.0, 0.48
	)

func _rubble() -> StandardMaterial3D:
	return _material(
		"p2_rubble",
		"res://assets/pbr/rubble_ground_albedo.png",
		"res://assets/pbr/rubble_ground_normal.png",
		"res://assets/pbr/rubble_ground_roughness.png",
		Color(0.59, 0.55, 0.48), 0.94, 2.8
	)

func _mud() -> StandardMaterial3D:
	return _material(
		"p2_mud",
		"res://assets/pbr/mud_albedo.png",
		"res://assets/pbr/mud_normal.png",
		"res://assets/pbr/mud_roughness.png",
		Color(0.39, 0.31, 0.24), 0.64, 3.3
	)

func _box(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	material: Material,
	rotation_degrees_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = position_value
	node.rotation_degrees = rotation_degrees_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _cylinder(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	radius: float,
	height: float,
	material: Material,
	rotation_degrees_value: Vector3 = Vector3.ZERO,
	segments: int = 14
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = position_value
	node.rotation_degrees = rotation_degrees_value
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _sphere(
	parent: Node3D,
	name_value: String,
	position_value: Vector3,
	scale_value: Vector3,
	material: Material
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name_value
	node.position = position_value
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	node.mesh = mesh
	node.scale = scale_value
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _building_root(
	name_value: String,
	position_value: Vector3,
	rotation_y: float
) -> Node3D:
	var root := Node3D.new()
	root.name = name_value
	root.position = position_value
	root.rotation_degrees.y = rotation_y
	add_child(root)
	return root

func _add_window(
	root: Node3D,
	position_value: Vector3,
	width: float,
	height: float,
	front_z: float
) -> void:
	var frame := _wood()
	var darkness := _plain("p2_window_dark", Color(0.025,0.030,0.030), 0.30)
	_box(root, "WindowRecess", position_value + Vector3(0.0,0.0,front_z), Vector3(width,height,0.055), darkness)
	var t := 0.075
	var z := front_z - 0.045
	_box(root, "WindowFrameTop", position_value + Vector3(0.0,height*0.5, z), Vector3(width+t,t,0.11), frame)
	_box(root, "WindowFrameBottom", position_value + Vector3(0.0,-height*0.5,z), Vector3(width+t,t,0.11), frame)
	_box(root, "WindowFrameLeft", position_value + Vector3(-width*0.5,0.0,z), Vector3(t,height,t+0.035), frame)
	_box(root, "WindowFrameRight", position_value + Vector3(width*0.5,0.0,z), Vector3(t,height,t+0.035), frame)
	_box(root, "WindowMullion", position_value + Vector3(0.0,0.0,z-0.01), Vector3(0.045,height,0.12), frame)
	_box(root, "WindowSill", position_value + Vector3(0.0,-height*0.5-0.08,z-0.01), Vector3(width+0.22,0.11,0.22), _concrete())

func _add_facade_depth(
	name_value: String,
	position_value: Vector3,
	rotation_y: float,
	width: float,
	height: float,
	front_z: float,
	brick_facade: bool
) -> void:
	var root := _building_root(name_value, position_value, rotation_y)
	var wall_mat: Material = _brick() if brick_facade else _plaster()
	var stone := _concrete()
	# A real facade needs silhouette depth: foundation, floor bands, corner
	# pilasters, lintels and a projecting cornice rather than one flat plane.
	_box(root,"FoundationPlinth",Vector3(0.0,0.32,front_z),Vector3(width+0.16,0.64,0.28),stone)
	_box(root,"FloorBand",Vector3(0.0,3.15,front_z-0.025),Vector3(width+0.18,0.14,0.22),stone)
	_box(root,"Cornice",Vector3(0.0,height-0.30,front_z-0.03),Vector3(width+0.42,0.24,0.34),stone)
	_box(root,"LeftPilaster",Vector3(-width*0.5+0.18,height*0.5,front_z-0.02),Vector3(0.34,height-0.60,0.28),wall_mat)
	_box(root,"RightPilaster",Vector3(width*0.5-0.18,height*0.5,front_z-0.02),Vector3(0.34,height-0.60,0.28),wall_mat)
	for floor_index in range(2):
		var y := 1.62 + float(floor_index) * 2.55
		for col in [-1, 1]:
			_add_window(root,Vector3(float(col)*1.70,y,0.0),1.05,1.48,front_z-0.16)
	# Drain pipe, brackets and repair patch give the eye recognizable scale.
	_cylinder(root,"DrainPipe",Vector3(width*0.5-0.45,height*0.47,front_z-0.25),0.052,height-0.95,_metal())
	for bracket_y in [1.1, 2.7, 4.4, 5.9]:
		_box(root,"DrainBracket",Vector3(width*0.5-0.45,float(bracket_y),front_z-0.31),Vector3(0.18,0.045,0.09),_metal())
	_box(root,"FacadeRepairPatch",Vector3(-0.45,1.02,front_z-0.17),Vector3(1.35,0.55,0.045),_brick(),Vector3(0.0,0.0,-4.0))

func _build_village_facade_depth() -> void:
	# Matches the established west-side townhouse row. These details are visual
	# only and sit just proud of the authoritative collision meshes.
	_add_facade_depth("FacadeDepthA",Vector3(-51.0,0.0,-27.0),8.0,7.4,7.1,-3.08,true)
	_add_facade_depth("FacadeDepthB",Vector3(-52.0,0.0,-8.0),-4.0,7.4,7.2,-3.18,false)
	_add_facade_depth("FacadeDepthC",Vector3(-50.0,0.0,13.0),7.0,7.1,7.0,-3.08,false)
	_add_facade_depth("FacadeDepthD",Vector3(-49.0,0.0,34.0),-9.0,7.4,7.2,-3.18,true)

func _build_fort_wall_depth() -> void:
	var concrete := _concrete()
	var metal := _metal()
	var dark := _plain("p2_fort_recess",Color(0.035,0.038,0.037),0.96)
	# Segment the otherwise broad fort slabs into believable poured-concrete bays.
	for data in [
		[Vector3(30.0,0.0,15.45),Vector2(24.0,5.0),0.0],
		[Vector3(30.0,0.0,34.55),Vector2(24.0,5.0),180.0]
	]:
		var root := _building_root("FortWallRelief",Vector3(data[0]),float(data[2]))
		for bay in range(7):
			var x := -10.2 + float(bay)*3.4
			_box(root,"ConcreteJoint",Vector3(x,2.48,0.0),Vector3(0.07,4.75,0.08),dark)
			_box(root,"WallCap",Vector3(x+1.7,5.03,-0.02),Vector3(3.35,0.22,1.18),concrete)
		for bolt in range(18):
			_cylinder(root,"TieHole",Vector3(-10.6+float(bolt%9)*2.65,1.25+float(bolt/9)*2.15,-0.59),0.035,0.025,dark,Vector3(90.0,0.0,0.0),10)
	# Gate-side buttresses and rusted steel reinforcement.
	for z in [19.0,31.0]:
		var gate_root := _building_root("GateButtress",Vector3(17.42,0.0,float(z)),0.0)
		_box(gate_root,"ConcreteButtress",Vector3(0.0,1.65,0.0),Vector3(1.35,3.3,1.5),concrete,Vector3(0.0,0.0,-5.0 if z < 25.0 else 5.0))
		for rod in range(3):
			_cylinder(gate_root,"ExposedRebar",Vector3(-0.28+float(rod)*0.28,3.52,0.0),0.025,0.75,metal,Vector3.ZERO,10)

func _build_rail_yard_detail() -> void:
	var metal := _metal()
	var wood := _wood()
	var dark := _plain("p2_rail_dark",Color(0.035,0.040,0.040),0.82,0.25)
	for car_x in [14.0,24.0,34.0]:
		var root := _building_root("RailCarDetail",Vector3(float(car_x),0.0,-20.5),0.0)
		# Underframe and wheels make the old rectangular rail cars read as vehicles.
		_box(root,"UnderFrame",Vector3(0.0,0.58,0.0),Vector3(7.15,0.28,2.48),dark)
		for wheel_x in [-2.45,2.45]:
			for wheel_z in [-1.26,1.26]:
				_cylinder(root,"RailWheel",Vector3(float(wheel_x),0.47,float(wheel_z)),0.42,0.16,dark,Vector3(90.0,0.0,0.0),18)
		for rib in range(7):
			_box(root,"CarVerticalRib",Vector3(-3.25+float(rib)*1.08,1.75,-1.43),Vector3(0.08,2.55,0.10),metal)
		_box(root,"SlidingDoor",Vector3(0.0,1.78,-1.49),Vector3(2.35,2.45,0.10),metal)
		_box(root,"DoorBraceA",Vector3(0.0,1.78,-1.57),Vector3(0.08,2.70,0.08),wood,Vector3(0.0,0.0,40.0))
		_box(root,"DoorBraceB",Vector3(0.0,1.78,-1.58),Vector3(0.08,2.70,0.08),wood,Vector3(0.0,0.0,-40.0))

func _build_ground_microgeometry() -> void:
	var mud := _mud()
	var rubble := _rubble()
	# Long shallow ruts and raised muddy shoulders remove the perfectly flat floor.
	for z in [-27.0,-9.0,8.0,26.0]:
		for offset in [-0.55,0.55]:
			_box(self,"VehicleRut",Vector3(-20.0+float(offset),0.035,float(z)),Vector3(0.16,0.035,13.0),mud,Vector3(0.0,_rng.randf_range(-4.0,4.0),0.0))
	for index in range(145):
		var p := Vector3(_rng.randf_range(-44.0,44.0),_rng.randf_range(0.035,0.095),_rng.randf_range(-36.0,36.0))
		if absf(p.x) < 4.0:
			continue
		var s := Vector3(_rng.randf_range(0.06,0.24),_rng.randf_range(0.035,0.13),_rng.randf_range(0.07,0.28))
		_box(self,"GroundDebris",p,s,rubble,Vector3(_rng.randf_range(-30.0,30.0),_rng.randf_range(0.0,180.0),_rng.randf_range(-30.0,30.0)))

func _build_battlefield_rubble() -> void:
	var brick := _brick()
	var concrete := _concrete()
	var wood := _wood()
	for center in [Vector3(-43.5,0.0,-25.0),Vector3(-44.0,0.0,7.0),Vector3(38.5,0.0,31.5),Vector3(39.0,0.0,-10.5)]:
		var root := _building_root("DenseRubblePile",center,_rng.randf_range(-180.0,180.0))
		for index in range(22):
			var mat: Material = brick if index % 3 != 0 else concrete
			_box(root,"BrokenMasonry",Vector3(_rng.randf_range(-1.5,1.5),_rng.randf_range(0.05,0.36),_rng.randf_range(-1.0,1.0)),Vector3(_rng.randf_range(0.14,0.48),_rng.randf_range(0.08,0.24),_rng.randf_range(0.12,0.40)),mat,Vector3(_rng.randf_range(-35.0,35.0),_rng.randf_range(0.0,180.0),_rng.randf_range(-35.0,35.0)))
		for timber in range(4):
			_box(root,"BrokenTimber",Vector3(_rng.randf_range(-1.2,1.2),0.28+float(timber)*0.05,_rng.randf_range(-0.8,0.8)),Vector3(_rng.randf_range(1.0,2.4),0.12,0.14),wood,Vector3(_rng.randf_range(-12.0,12.0),_rng.randf_range(0.0,180.0),_rng.randf_range(-25.0,25.0)))

func _build_cinematic_prop_density() -> void:
	var wood := _wood()
	var metal := _metal()
	# Smaller human-scale props are what make the concept frame feel authored.
	for center in [Vector3(-13.0,0.0,-18.0),Vector3(9.0,0.0,-12.0),Vector3(26.0,0.0,9.0),Vector3(-30.0,0.0,30.0)]:
		var root := _building_root("SmallPropCluster",center,_rng.randf_range(-30.0,30.0))
		_box(root,"AmmoCrate",Vector3(0.0,0.24,0.0),Vector3(0.78,0.48,0.46),wood)
		_box(root,"AmmoCrateLid",Vector3(0.0,0.51,0.0),Vector3(0.82,0.07,0.50),wood)
		_cylinder(root,"JerryCanBody",Vector3(0.68,0.31,0.12),0.20,0.58,metal,Vector3.ZERO,8)
		_box(root,"LoosePlank",Vector3(-0.35,0.10,-0.55),Vector3(1.55,0.08,0.20),wood,Vector3(4.0,-18.0,7.0))

func _build_drainage_and_wet_edges() -> void:
	var metal := _metal()
	var wet := _plain("p2_wet_channel",Color(0.035,0.045,0.047),0.12,0.0)
	# Drainage channels and grates create highlights and edge complexity at ground level.
	for z in [-28.0,-10.0,8.0,27.0]:
		_box(self,"DrainChannel",Vector3(-16.1,0.034,float(z)),Vector3(0.48,0.025,8.0),wet)
		for grate in range(7):
			_box(self,"DrainGrate",Vector3(-16.1,0.055,float(z)-3.0+float(grate)),Vector3(0.50,0.035,0.065),metal)

func _upgrade_lighting_microcontrast(root: Node) -> void:
	# Add a few restrained practical pools instead of flooding the whole map.
	for data in [
		[Vector3(-47.0,3.2,-18.0),Color(1.0,0.56,0.26)],
		[Vector3(-46.0,3.1,22.0),Color(1.0,0.52,0.22)],
		[Vector3(19.0,3.0,18.0),Color(0.90,0.64,0.38)],
		[Vector3(19.0,3.0,31.5),Color(0.90,0.62,0.36)]
	]:
		var light := OmniLight3D.new()
		light.name = "RealismPass2Practical"
		light.position = Vector3(data[0])
		light.light_color = data[1] as Color
		light.light_energy = 0.72
		light.omni_range = 7.5
		light.shadow_enabled = true
		add_child(light)
