extends RefCounted

const Outline = preload("res://experiments/draw_physics/outline.gd")
const EPSILON := 0.01


static func split(polygon: PackedVector2Array, stroke: PackedVector2Array) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = [polygon]
	if stroke.size() < 2:
		return pieces
	# shortcut: self-crossing strokes are rejected; support a planar graph to split them.
	for first in range(stroke.size() - 1):
		for second in range(first + 2, stroke.size() - 1):
			if Geometry2D.segment_intersects_segment(stroke[first], stroke[first + 1], stroke[second], stroke[second + 1]) != null:
				return pieces
	var pending: Array[PackedVector2Array] = [polygon]
	pieces.clear()
	while not pending.is_empty():
		var current: PackedVector2Array = pending.pop_back()
		var divided := false
		for path in Geometry2D.intersect_polyline_with_polygon(stroke, current):
			var result := _split_path(current, path)
			if result.size() == 2:
				pending.append_array(result)
				divided = true
				break
			if path.size() >= 2 and path[0].distance_to(path[-1]) >= EPSILON and _edge_at(current, path[0]) >= 0 and _edge_at(current, path[-1]) >= 0 and _edge_at(current, (path[0] + path[1]) / 2.0) < 0 and Geometry2D.is_point_in_polygon((path[0] + path[1]) / 2.0, current):
				return [polygon]
		if not divided:
			pieces.append(current)
	return pieces


static func _split_path(polygon: PackedVector2Array, path: PackedVector2Array) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	if path.size() < 2 or path[0].distance_to(path[-1]) < EPSILON:
		return result
	var start_edge := _edge_at(polygon, path[0])
	var end_edge := _edge_at(polygon, path[-1])
	if start_edge < 0 or end_edge < 0:
		return result
	var first := PackedVector2Array(path)
	var second := PackedVector2Array(path)
	second.reverse()
	_append_boundary(first, polygon, end_edge, start_edge, path[-1], path[0])
	_append_boundary(second, polygon, start_edge, end_edge, path[0], path[-1])
	var valid_first := Outline.prepare(first)
	var valid_second := Outline.prepare(second)
	if valid_first.is_empty() or valid_second.is_empty():
		return result
	var area := absf(_area(polygon))
	if absf(absf(_area(valid_first)) + absf(_area(valid_second)) - area) > maxf(1.0, area * 0.001):
		return result
	result.append(valid_first)
	result.append(valid_second)
	return result


static func _edge_at(polygon: PackedVector2Array, point: Vector2) -> int:
	for i in polygon.size():
		if Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()]).distance_to(point) < EPSILON:
			return i
	return -1


static func _append_boundary(output: PackedVector2Array, polygon: PackedVector2Array, from_edge: int, to_edge: int, from: Vector2, to: Vector2) -> void:
	var index := from_edge
	var same_edge_forward := from_edge == to_edge and (to - from).dot(polygon[(from_edge + 1) % polygon.size()] - polygon[from_edge]) >= 0.0
	if same_edge_forward:
		return
	while true:
		index = (index + 1) % polygon.size()
		output.append(polygon[index])
		if index == to_edge:
			break


static func _area(polygon: PackedVector2Array) -> float:
	var value := 0.0
	for i in polygon.size():
		value += polygon[i].cross(polygon[(i + 1) % polygon.size()])
	return value / 2.0
