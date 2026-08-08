extends Node
class_name MemoryAssetScalability

var world_root: Node
var quality_manager: Node
var refresh_accumulator := 0.0

const REFRESH_INTERVAL := 2.0

func initialize(root: Node, manager: Node) -> void:
	world_root = root
	quality_manager = manager
	apply_current_quality()


func on_quality_changed() -> void:
	apply_current_quality()


func _process(delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return

	refresh_accumulator += delta
	if refresh_accumulator < REFRESH_INTERVAL:
		return
	refresh_accumulator = 0.0

	# New dynamically-created pickups/casualties need the same budgets as the
	# rest of the world, so re-apply a cheap targeted pass periodically.
	_apply_dynamic_world_budgets()


func apply_current_quality() -> void:
	if world_root == null or quality_manager == null:
		return

	_apply_static_detail_budgets()
	_apply_dynamic_world_budgets()
	_apply_texture_filtering_bias()


func _preset() -> int:
	if quality_manager == null:
		return 1
	return clampi(int(quality_manager.get("current_preset")), 0, 2)


func _apply_static_detail_budgets() -> void:
	var preset := _preset()

	for value: Node in world_root.find_children("*", "GeometryInstance3D", true):
		var geometry := value as GeometryInstance3D
		if geometry == null:
			continue

		var key := geometry.name.to_lower()

		# These are visual dressing systems accumulated through the realism
		# phases. They can use shorter ranges without affecting navigation.
		var micro := _matches_any(key, [
			"paperscrap", "pinnedpaper", "mappaper", "rustaccent",
			"glassshard", "bulletscar", "bulletchip", "facadechip",
			"impactdebris", "transitionrubble", "damagerubble",
			"roadedgedebris", "embeddedstone", "drainstone",
			"coverfragment", "crateband", "crateslat", "sandbagseam",
			"wetedge", "streetgrime", "paper", "fragment"
		])

		var medium := _matches_any(key, [
			"bench", "pallet", "shelf", "tool", "awning",
			"shutter", "sign", "utilitybox", "fence", "routepost",
			"crate", "barrel", "sandbag", "barricade", "rubble"
		])

		if preset == 0:
			if micro:
				_set_end_range(geometry, 11.0)
				geometry.cast_shadow = (
					GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				)
			elif medium:
				_set_end_range(geometry, 34.0)

		elif preset == 1:
			if micro:
				_set_end_range(geometry, 20.0)
				geometry.cast_shadow = (
					GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				)
			elif medium:
				_set_end_range(geometry, 55.0)

		# High leaves the state restored by VisualQualityManager untouched.


func _apply_dynamic_world_budgets() -> void:
	var preset := _preset()

	# Casualty visuals are purely cosmetic and can clean up sooner on machines
	# where memory/scene-tree pressure matters more.
	var casualty_end := 18.0 if preset == 0 else 24.0 if preset == 1 else 46.0
	for casualty: Node in world_root.find_children("Casualty_*", "", true):
		for child: Node in casualty.get_children():
			if child is GeometryInstance3D:
				var geometry := child as GeometryInstance3D
				geometry.visibility_range_end = minf(
					casualty_end,
					geometry.visibility_range_end
					if geometry.visibility_range_end > 0.0
					else casualty_end
				)

	# Dropped pickup world models only need to remain visually expensive while
	# they are close enough to matter to the player.
	var pickup_end := 18.0 if preset == 0 else 28.0 if preset == 1 else 46.0
	for pickup: Node in world_root.find_children("BattlefieldPickup_*", "", true):
		for child: Node in pickup.get_children():
			if child is GeometryInstance3D:
				var geometry := child as GeometryInstance3D
				if not (
					"PickupLabel" in child.name
					or "GroundRing" in child.name
				):
					geometry.visibility_range_end = pickup_end
					geometry.visibility_range_end_margin = 3.0

	# Supply-station decorative light has no gameplay purpose.
	for value: Node in world_root.find_children("SupplyMarkerLight", "", true):
		var light := value as Light3D
		if light == null:
			continue
		light.visible = preset != 0


func _apply_texture_filtering_bias() -> void:
	# Material textures themselves are still shared/resources; this pass avoids
	# duplicating materials and instead adjusts per-mesh LOD bias when supported.
	var preset := _preset()

	for value: Node in world_root.find_children("*", "GeometryInstance3D", true):
		var geometry := value as GeometryInstance3D
		if geometry == null:
			continue

		if _has_property(geometry, &"lod_bias"):
			match preset:
				0:
					geometry.set("lod_bias", 0.65)
				1:
					geometry.set("lod_bias", 0.85)
				_:
					geometry.set("lod_bias", 1.0)


func _set_end_range(
	geometry: GeometryInstance3D,
	target: float
) -> void:
	var existing := geometry.visibility_range_end
	if existing <= 0.0:
		geometry.visibility_range_end = target
	else:
		geometry.visibility_range_end = minf(existing, target)

	geometry.visibility_range_end_margin = minf(
		maxf(geometry.visibility_range_end * 0.16, 1.0),
		5.0
	)
	geometry.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)


func _matches_any(text: String, patterns: Array) -> bool:
	for pattern_value: Variant in patterns:
		if str(pattern_value) in text:
			return true
	return false


func _has_property(object: Object, property_name: StringName) -> bool:
	for property_data: Dictionary in object.get_property_list():
		if StringName(property_data.get("name", "")) == property_name:
			return true
	return false
