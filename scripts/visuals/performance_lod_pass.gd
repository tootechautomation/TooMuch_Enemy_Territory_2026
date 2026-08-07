extends RefCounted
class_name PerformanceLODPass

# v8.81 — rendering optimization / distance-detail pass.
# Visual only. Does not change collision, gameplay, weapons or objectives.

static func apply(root: Node) -> void:
	if root == null or root.has_node("PerformanceLODPass_v881"):
		return

	var marker := Node.new()
	marker.name = "PerformanceLODPass_v881"
	root.add_child(marker)

	_optimize_microdetail(root)
	_optimize_particles(root)
	_optimize_decorative_lights(root)


static func _optimize_microdetail(root: Node) -> void:
	for value: Node in root.find_children("*", "MeshInstance3D", true):
		var mesh_instance := value as MeshInstance3D
		if mesh_instance == null:
			continue

		var key := mesh_instance.name.to_lower()

		# Very small surface marks/detail do not need to exist across the map.
		if _matches_any(key, [
			"bulletscar", "bulletchip", "sandbagseam", "crateband",
			"crateslat", "rustaccent", "paperscrap", "pinnedpaper",
			"mappaper", "glassshard", "windowglassshard", "coverimpact",
			"damagerubble", "impactdebris", "streetgrime", "wetedge",
			"embeddedstone", "drainstone", "grounddebris", "groundchip"
		]):
			_set_visibility(mesh_instance, 22.0, 4.0)
			mesh_instance.cast_shadow = (
				GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			)
			continue

		# Small props are useful slightly farther away, but their shadows are
		# rarely worth the render cost at normal combat distances.
		if _matches_any(key, [
			"utilitybox", "junctionbox", "radioknob", "doorknob",
			"doorhandle", "accesscover", "drainbar", "coverfragment",
			"wallanchor", "downspoutwetpatch", "wetpuddlebase",
			"rainripple", "paper", "debris", "fragment", "rubble"
		]):
			_set_visibility(mesh_instance, 38.0, 6.0)
			mesh_instance.cast_shadow = (
				GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			)
			continue

		# Medium decorative architecture remains visible through most normal
		# combat engagements but fades before the far skyline.
		if _matches_any(key, [
			"awning", "shutter", "hanging sign", "hangingsign",
			"service door", "servicedoor", "streetpole", "bench",
			"pallet", "shelf", "tool", "fence", "sandbag",
			"barricade", "crate", "canopy", "route", "lamp",
			"downspout", "gutter"
		]):
			_set_visibility(mesh_instance, 70.0, 10.0)

		# Keep major building silhouettes and rooflines fully visible.


static func _optimize_particles(root: Node) -> void:
	for value: Node in root.find_children("*", "GPUParticles3D", true):
		var particles := value as GPUParticles3D
		if particles == null:
			continue

		var key := particles.name.to_lower()

		# Close-range rain interactions.
		if (
			"rainsplash" in key
			or "roofdrip" in key
			or "dust" in key
			or "ember" in key
		):
			_set_visibility(particles, 34.0, 6.0)

		# Atmospheric smoke/haze should still contribute at longer range.
		elif "smoke" in key or "haze" in key:
			_set_visibility(particles, 95.0, 15.0)


static func _optimize_decorative_lights(root: Node) -> void:
	for value: Node in root.find_children("*", "OmniLight3D", true):
		var light := value as OmniLight3D
		if light == null:
			continue

		var key := light.name.to_lower()

		# Hero/objective lights keep shadows; secondary decorative/bounce lights
		# use shadowless lighting to reduce cost.
		if _matches_any(key, [
			"bounce", "fill", "edge", "approach", "upperstory",
			"distantfire", "coolbattle", "readability"
		]):
			light.shadow_enabled = false

		# Small practical lamps do not need very large influence radii.
		if _matches_any(key, [
			"facadelamp", "walllamp", "interiorpractical",
			"streetwarm", "warmlamp", "detailpractical"
		]):
			light.omni_range = minf(light.omni_range, 4.0)


static func _set_visibility(
	instance: GeometryInstance3D,
	end_distance: float,
	fade_margin: float
) -> void:
	if instance == null:
		return

	# These are standard GeometryInstance3D distance visibility properties.
	instance.visibility_range_end = end_distance
	instance.visibility_range_end_margin = fade_margin
	instance.visibility_range_fade_mode = (
		GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	)


static func _matches_any(
	text: String,
	patterns: Array
) -> bool:
	for pattern_value: Variant in patterns:
		if str(pattern_value) in text:
			return true
	return false
