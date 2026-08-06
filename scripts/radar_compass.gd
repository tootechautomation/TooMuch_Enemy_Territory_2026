extends Control

var heading_degrees := 0.0
var team_color := Color(0.20, 0.72, 1.0)
var objective_bearing := 0.0
var objective_visible := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_compass_state(
	new_heading: float,
	new_team_color: Color,
	new_objective_bearing: float,
	show_objective: bool
) -> void:
	heading_degrees = new_heading
	team_color = new_team_color
	objective_bearing = new_objective_bearing
	objective_visible = show_objective
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius: float = minf(size.x, size.y) * 0.46

	draw_circle(
		center,
		radius,
		Color(0.025, 0.035, 0.033, 0.92)
	)
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		96,
		Color(0.73, 0.68, 0.43, 0.98),
		4.0,
		true
	)
	draw_arc(
		center,
		radius - 8.0,
		0.0,
		TAU,
		96,
		Color(0.28, 0.29, 0.22, 0.98),
		3.0,
		true
	)
	draw_arc(
		center,
		radius - 23.0,
		0.0,
		TAU,
		96,
		Color(0.48, 0.46, 0.31, 0.72),
		1.0,
		true
	)

	for degree in range(0, 360, 5):
		var relative_degree: float = float(degree) - heading_degrees
		var angle: float = deg_to_rad(relative_degree - 90.0)
		var major: bool = degree % 45 == 0
		var outer: Vector2 = center + Vector2(
			cos(angle),
			sin(angle)
		) * (radius - 10.0)
		var inner_radius: float = radius - (28.0 if major else 20.0)
		var inner: Vector2 = center + Vector2(
			cos(angle),
			sin(angle)
		) * inner_radius
		draw_line(
			inner,
			outer,
			(
				Color(0.92, 0.88, 0.67, 0.95)
				if major
				else Color(0.52, 0.51, 0.39, 0.75)
			),
			3.0 if major else 1.0,
			true
		)

	# Fixed player direction marker.
	var player_arrow := PackedVector2Array([
		center + Vector2(0.0, -17.0),
		center + Vector2(-8.0, 8.0),
		center,
		center + Vector2(8.0, 8.0)
	])
	draw_colored_polygon(
		player_arrow,
		Color(0.94, 0.93, 0.82, 0.98)
	)

	# Objective bearing rotates around the compass edge.
	if objective_visible:
		var objective_angle: float = deg_to_rad(
			objective_bearing - heading_degrees - 90.0
		)
		var objective_center: Vector2 = center + Vector2(
			cos(objective_angle),
			sin(objective_angle)
		) * (radius - 38.0)
		var diamond := PackedVector2Array([
			objective_center + Vector2(0.0, -7.0),
			objective_center + Vector2(7.0, 0.0),
			objective_center + Vector2(0.0, 7.0),
			objective_center + Vector2(-7.0, 0.0)
		])
		draw_colored_polygon(
			diamond,
			Color(1.0, 0.76, 0.10, 1.0)
		)

	# Team ring.
	draw_arc(
		center,
		radius - 32.0,
		deg_to_rad(-112.0),
		deg_to_rad(-68.0),
		24,
		team_color,
		4.0,
		true
	)
