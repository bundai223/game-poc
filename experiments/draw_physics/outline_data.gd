extends RefCounted

var points: PackedVector2Array


func _init(outline_points: PackedVector2Array = PackedVector2Array()) -> void:
	points = outline_points.duplicate()


func to_json() -> String:
	var encoded_points: Array = []
	for point in points:
		encoded_points.append([point.x, point.y])
	return JSON.stringify({"version": 1, "points": encoded_points})


static func from_json(source: String):
	var parser := JSON.new()
	if parser.parse(source) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return null
	var data: Dictionary = parser.data
	if not _is_number(data.get("version")) or float(data["version"]) != 1.0 or typeof(data.get("points")) != TYPE_ARRAY:
		return null
	var encoded_points: Array = data["points"]
	if encoded_points.size() < 3:
		return null
	var decoded_points := PackedVector2Array()
	for pair in encoded_points:
		if typeof(pair) != TYPE_ARRAY or pair.size() != 2:
			return null
		if not _is_number(pair[0]) or not _is_number(pair[1]):
			return null
		var point := Vector2(float(pair[0]), float(pair[1]))
		if not is_finite(point.x) or not is_finite(point.y):
			return null
		decoded_points.append(point)
	return new(decoded_points)


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
