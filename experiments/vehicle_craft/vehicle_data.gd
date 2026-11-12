extends RefCounted

const PartData = preload("res://experiments/draw_physics/part_data.gd")

var parts: Array = []
var connections: Array[Dictionary] = []


static func create_starter():
	var vehicle = new()
	vehicle.add_part(PartData.new("block-1", Transform3D(Basis.IDENTITY, Vector3(0, 0.5, 0)), "block"))
	vehicle.add_part(PartData.new("wheel-1", Transform3D(Basis.IDENTITY, Vector3(-1, 0.45, 0)), "wheel"))
	vehicle.add_part(PartData.new("wheel-2", Transform3D(Basis.IDENTITY, Vector3(1, 0.45, 0)), "wheel"))
	vehicle.add_connection("block-1", "wheel-1", "hinge")
	vehicle.add_connection("block-1", "wheel-2", "hinge")
	return vehicle


func add_part(part: Variant) -> bool:
	if part == null or typeof(part.id) != TYPE_STRING or part.id.strip_edges().is_empty():
		return false
	if not ["block", "wheel"].has(part.kind) or not _is_finite_transform(part.transform):
		return false
	if find_part(part.id) != null:
		return false
	parts.append(part)
	return true


func add_connection(part_a_id: String, part_b_id: String, kind: String) -> bool:
	var part_a = find_part(part_a_id)
	var part_b = find_part(part_b_id)
	if part_a == null or part_b == null or part_a_id == part_b_id:
		return false
	if kind == "fixed":
		if part_a.kind != "block" or part_b.kind != "block":
			return false
	elif kind == "hinge":
		if not ((part_a.kind == "wheel" and part_b.kind == "block") or (part_a.kind == "block" and part_b.kind == "wheel")):
			return false
	else:
		return false
	for connection in connections:
		if connection.kind == kind and ((connection.a == part_a_id and connection.b == part_b_id) or (connection.a == part_b_id and connection.b == part_a_id)):
			return false
	connections.append({"a": part_a_id, "b": part_b_id, "kind": kind})
	return true


func remove_part(part_id: String) -> bool:
	for index in range(parts.size()):
		if parts[index].id == part_id:
			parts.remove_at(index)
			for connection_index in range(connections.size() - 1, -1, -1):
				if connections[connection_index].a == part_id or connections[connection_index].b == part_id:
					connections.remove_at(connection_index)
			return true
	return false


func find_part(part_id: String):
	for part in parts:
		if part.id == part_id:
			return part
	return null


func can_drive() -> bool:
	var wheel_count := 0
	var block_x_total := 0.0
	var block_count := 0
	var has_left_wheel := false
	var has_right_wheel := false
	for part in parts:
		if part.kind == "block":
			block_x_total += part.transform.origin.x
			block_count += 1
		elif part.kind == "wheel":
			wheel_count += 1
			if not _has_block_hinge(part.id):
				return false
	if block_count == 0:
		return false
	var center_x := block_x_total / block_count
	for part in parts:
		if part.kind == "wheel":
			has_left_wheel = has_left_wheel or part.transform.origin.x < center_x
			has_right_wheel = has_right_wheel or part.transform.origin.x > center_x
	return wheel_count >= 2 and has_left_wheel and has_right_wheel and blocks_connected()


func blocks_connected() -> bool:
	var block_count := 0
	var first_block_id := ""
	for part in parts:
		if part.kind == "block":
			block_count += 1
			if first_block_id.is_empty():
				first_block_id = part.id
	return block_count > 0 and _blocks_connected(first_block_id, block_count)


func to_json() -> String:
	var part_data: Array[Dictionary] = []
	for part in parts:
		part_data.append(JSON.parse_string(part.to_json()))
	return JSON.stringify({"version": 1, "parts": part_data, "connections": connections})


static func from_json(source: String):
	var parser := JSON.new()
	if parser.parse(source) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return null
	var data: Dictionary = parser.data
	if data.get("version") != 1 or typeof(data.get("parts")) != TYPE_ARRAY or typeof(data.get("connections")) != TYPE_ARRAY:
		return null
	var vehicle = new()
	for item in data.parts:
		if typeof(item) != TYPE_DICTIONARY:
			return null
		var part = PartData.from_json(JSON.stringify(item))
		if not vehicle.add_part(part):
			return null
	for item in data.connections:
		if typeof(item) != TYPE_DICTIONARY or typeof(item.get("a")) != TYPE_STRING or typeof(item.get("b")) != TYPE_STRING or typeof(item.get("kind")) != TYPE_STRING:
			return null
		if not vehicle.add_connection(item.a, item.b, item.kind):
			return null
	return vehicle


func _has_block_hinge(part_id: String) -> bool:
	for connection in connections:
		if connection.kind != "hinge":
			continue
		var other_id: String = connection.b if connection.a == part_id else connection.a if connection.b == part_id else ""
		if not other_id.is_empty() and find_part(other_id).kind == "block":
			return true
	return false


func _blocks_connected(first_block_id: String, block_count: int) -> bool:
	var connected := {first_block_id: true}
	var changed := true
	while changed:
		changed = false
		for connection in connections:
			if connection.kind != "fixed":
				continue
			if connected.has(connection.a) and not connected.has(connection.b):
				connected[connection.b] = true
				changed = true
			elif connected.has(connection.b) and not connected.has(connection.a):
				connected[connection.a] = true
				changed = true
	return connected.size() == block_count


static func _is_finite_transform(value: Transform3D) -> bool:
	return value.origin.is_finite() and value.basis.x.is_finite() and value.basis.y.is_finite() and value.basis.z.is_finite()
