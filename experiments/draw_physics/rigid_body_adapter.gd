extends RefCounted

const OutlineData = preload("res://experiments/draw_physics/outline_data.gd")


static func create_body(outline: OutlineData) -> RigidBody2D:
	var origin := Vector2.ZERO
	for point in outline.points:
		origin += point
	origin /= outline.points.size()
	var local_points := PackedVector2Array()
	for point in outline.points:
		local_points.append(point - origin)
	var body := RigidBody2D.new()
	body.position = origin
	var visual := Polygon2D.new()
	visual.polygon = local_points
	visual.color = Color(0.2, 0.68, 0.95)
	var border := Line2D.new()
	border.points = local_points
	border.closed = true
	border.width = 3.0
	border.default_color = Color.BLACK
	visual.add_child(border)
	body.add_child(visual)
	var collider := CollisionPolygon2D.new()
	collider.polygon = local_points
	body.add_child(collider)
	return body
