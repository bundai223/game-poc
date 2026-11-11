extends RefCounted

var id: String
var transform: Transform3D


func _init(part_id: String, part_transform: Transform3D = Transform3D.IDENTITY) -> void:
	id = part_id
	transform = part_transform


func to_json() -> String:
	var basis := transform.basis
	return JSON.stringify({
		"version": 1,
		"id": id,
		"transform": [
			transform.origin.x, transform.origin.y, transform.origin.z,
			basis.x.x, basis.x.y, basis.x.z,
			basis.y.x, basis.y.y, basis.y.z,
			basis.z.x, basis.z.y, basis.z.z,
		],
	})


static func from_json(source: String):
	var parser := JSON.new()
	if parser.parse(source) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return null
	var data: Dictionary = parser.data
	if not _is_number(data.get("version")) or float(data["version"]) != 1.0 or typeof(data.get("id")) != TYPE_STRING:
		return null
	var part_id: String = data["id"]
	var values = data.get("transform")
	if part_id.strip_edges().is_empty() or typeof(values) != TYPE_ARRAY or values.size() != 12:
		return null
	for value in values:
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			return null
		if not is_finite(float(value)):
			return null
	var origin := Vector3(values[0], values[1], values[2])
	var basis := Basis(
		Vector3(values[3], values[4], values[5]),
		Vector3(values[6], values[7], values[8]),
		Vector3(values[9], values[10], values[11])
	)
	return new(part_id, Transform3D(basis, origin))


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
