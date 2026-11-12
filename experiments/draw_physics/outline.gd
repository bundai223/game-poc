extends RefCounted

const MIN_AREA := 500.0
const MIN_EDGE_LENGTH := 3.0
const SIMPLIFY_DISTANCE := 2.0
const MAX_VERTICES := 32
const EPSILON := 0.001


static func prepare(input: PackedVector2Array) -> PackedVector2Array:
	var points := input.duplicate()
	for point in points:
		if not is_finite(point.x) or not is_finite(point.y):
			return PackedVector2Array()
	if points.size() > 1 and points[0].distance_to(points[-1]) < MIN_EDGE_LENGTH:
		points.remove_at(points.size() - 1)
	if points.size() < 3:
		return PackedVector2Array()

	var changed := true
	while changed and points.size() >= 3:
		changed = false
		for index in range(points.size()):
			var previous := points[(index - 1 + points.size()) % points.size()]
			var current := points[index]
			var next := points[(index + 1) % points.size()]
			if current.distance_to(previous) < MIN_EDGE_LENGTH or _distance_to_segment(current, previous, next) <= SIMPLIFY_DISTANCE:
				points.remove_at(index)
				changed = true
				break
	if points.size() < 3 or points.size() > MAX_VERTICES:
		return PackedVector2Array()

	var area_twice := 0.0
	var has_turn := false
	for index in range(points.size()):
		var a := points[index]
		var b := points[(index + 1) % points.size()]
		var c := points[(index + 2) % points.size()]
		area_twice += a.cross(b)
		var turn := (b - a).cross(c - b)
		if absf(turn) > EPSILON:
			has_turn = true
	if absf(area_twice) / 2.0 < MIN_AREA or not has_turn:
		return PackedVector2Array()

	for first in range(points.size()):
		var first_next := (first + 1) % points.size()
		for second in range(first + 1, points.size()):
			var second_next := (second + 1) % points.size()
			if first == second or first_next == second or second_next == first:
				continue
			if _segments_intersect(points[first], points[first_next], points[second], points[second_next]):
				return PackedVector2Array()
	return points


static func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var edge := finish - start
	return point.distance_to(start) if edge.length_squared() == 0.0 else point.distance_to(start + edge * clampf((point - start).dot(edge) / edge.length_squared(), 0.0, 1.0))


static func _segments_intersect(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	var ab_c := (b - a).cross(c - a)
	var ab_d := (b - a).cross(d - a)
	var cd_a := (d - c).cross(a - c)
	var cd_b := (d - c).cross(b - c)
	if absf(ab_c) <= EPSILON and _on_segment(c, a, b):
		return true
	if absf(ab_d) <= EPSILON and _on_segment(d, a, b):
		return true
	if absf(cd_a) <= EPSILON and _on_segment(a, c, d):
		return true
	if absf(cd_b) <= EPSILON and _on_segment(b, c, d):
		return true
	return ab_c * ab_d < 0.0 and cd_a * cd_b < 0.0


static func _on_segment(point: Vector2, start: Vector2, finish: Vector2) -> bool:
	return point.x >= minf(start.x, finish.x) - EPSILON and point.x <= maxf(start.x, finish.x) + EPSILON and point.y >= minf(start.y, finish.y) - EPSILON and point.y <= maxf(start.y, finish.y) + EPSILON
