extends Node3D

const VehicleData = preload("res://experiments/vehicle_craft/vehicle_data.gd")
const VehicleAdapter = preload("res://experiments/vehicle_craft/vehicle_adapter.gd")
const PartData = preload("res://experiments/draw_physics/part_data.gd")
const GRID_SIZE := 1.0
const SAVE_PATH := "user://vehicle-craft.json"

var _vehicle = VehicleData.create_starter()
var _tool := "select"
var _selected_id := ""
var _next_id := 3
var _running := false
var _preview: Node3D
var _runtime: Node3D
var _chassis: RigidBody3D
var _status: Label
var _drive_buttons := {"forward": false, "back": false, "left": false, "right": false}


func _ready() -> void:
	_create_world()
	_create_ui()
	var has_saved_vehicle := FileAccess.file_exists(SAVE_PATH)
	if has_saved_vehicle:
		_load_vehicle()
	_show_editor()
	if not has_saved_vehicle:
		_update_status("Place parts. Select, move or delete them.")


func _unhandled_input(event: InputEvent) -> void:
	if _running:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_edit_at(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_edit_at(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _set_tool("block")
			KEY_2: _set_tool("wheel")
			KEY_DELETE, KEY_BACKSPACE: _delete_selected()
			KEY_ENTER: _start_trial()
			KEY_ESCAPE: _return_to_edit()


func _physics_process(_delta: float) -> void:
	if not _running:
		return
	var throttle := float(_drive_buttons.forward or Input.is_key_pressed(KEY_W)) - float(_drive_buttons.back or Input.is_key_pressed(KEY_S))
	var steering := float(_drive_buttons.right or Input.is_key_pressed(KEY_D)) - float(_drive_buttons.left or Input.is_key_pressed(KEY_A))
	var block_x_total := 0.0
	var block_count := 0
	for part in _vehicle.parts:
		if part.kind == "block":
			block_x_total += part.transform.origin.x
			block_count += 1
	var center_x := block_x_total / block_count
	for node in _runtime.find_children("*", "HingeJoint3D", true, false):
		var hinge := node as HingeJoint3D
		var part = _vehicle.find_part(hinge.get_meta("part_id"))
		var speed := throttle * 10.0 + steering * 5.0 * signf(part.transform.origin.x - center_x)
		hinge.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, speed)
		hinge.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, absf(speed) > 0.1)
	# shortcut: chassis force supplements wheel motors, replace with tire forces if traction fidelity matters.
	if throttle != 0.0 or steering != 0.0:
		_chassis.sleeping = false
	_chassis.apply_central_force(Vector3(0, 0, -throttle * 6.0))
	_chassis.apply_torque(Vector3.UP * steering)
	if _chassis != null:
		var target := _chassis.global_position + Vector3(0, 0.5, 0)
		$Camera3D.position = target + Vector3(7, 6, 9)
		$Camera3D.look_at(target)


func _create_world() -> void:
	var floor := StaticBody3D.new()
	floor.name = "Floor"
	floor.position.y = -0.5
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 1, 40)
	floor_shape.shape = box
	floor.add_child(floor_shape)
	var floor_visual := MeshInstance3D.new()
	var plane := BoxMesh.new()
	plane.size = box.size
	floor_visual.mesh = plane
	floor_visual.material_override = _material(Color(0.18, 0.2, 0.23))
	floor.add_child(floor_visual)
	var grid_mesh := ImmediateMesh.new()
	var grid_material := StandardMaterial3D.new()
	grid_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_material.albedo_color = Color(0.32, 0.36, 0.4, 0.7)
	grid_mesh.surface_begin(Mesh.PRIMITIVE_LINES, grid_material)
	for coordinate in range(-20, 21):
		grid_mesh.surface_add_vertex(Vector3(coordinate, 0.506, -20))
		grid_mesh.surface_add_vertex(Vector3(coordinate, 0.506, 20))
		grid_mesh.surface_add_vertex(Vector3(-20, 0.506, coordinate))
		grid_mesh.surface_add_vertex(Vector3(20, 0.506, coordinate))
	grid_mesh.surface_end()
	var grid := MeshInstance3D.new()
	grid.mesh = grid_mesh
	floor.add_child(grid)
	add_child(floor)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_energy = 1.2
	add_child(light)
	var environment := WorldEnvironment.new()
	var sky := Environment.new()
	sky.background_mode = Environment.BG_COLOR
	sky.background_color = Color(0.82, 0.88, 0.94)
	sky.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	sky.ambient_light_color = Color(0.75, 0.8, 0.9)
	sky.ambient_light_energy = 0.5
	environment.environment = sky
	add_child(environment)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(7, 7, 9)
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3.ZERO)


func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	var title := Label.new()
	title.text = "3D Vehicle Craft"
	rows.add_child(title)
	var tools := HBoxContainer.new()
	rows.add_child(tools)
	_add_button(tools, "Select", func(): _set_tool("select"))
	_add_button(tools, "Block (1)", func(): _set_tool("block"))
	_add_button(tools, "Wheel (2)", func(): _set_tool("wheel"))
	_add_button(tools, "Move", func(): _set_tool("move"))
	_add_button(tools, "Delete", _delete_selected)
	var actions := HBoxContainer.new()
	rows.add_child(actions)
	_add_button(actions, "Run (Enter)", _start_trial)
	_add_button(actions, "Edit (Esc)", _return_to_edit)
	_add_button(actions, "Save", _save_vehicle)
	_add_button(actions, "Load", _load_vehicle)
	_add_button(actions, "2D Physics", _open_drawing_demo)
	var driving := HBoxContainer.new()
	rows.add_child(driving)
	_add_drive_button(driving, "Forward (W)", "forward")
	_add_drive_button(driving, "Reverse (S)", "back")
	_add_drive_button(driving, "Left (A)", "left")
	_add_drive_button(driving, "Right (D)", "right")
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_status)


func _add_button(parent: HBoxContainer, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(88, 44)
	button.pressed.connect(action)
	parent.add_child(button)


func _add_drive_button(parent: HBoxContainer, text: String, direction: String) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(88, 44)
	button.button_down.connect(func(): _drive_buttons[direction] = true)
	button.button_up.connect(func(): _drive_buttons[direction] = false)
	parent.add_child(button)


func _show_editor() -> void:
	_running = false
	_runtime = null
	_chassis = null
	_preview = VehicleAdapter.create_editor_view(_vehicle, _selected_id)
	add_child(_preview)


func _edit_at(screen_position: Vector2) -> void:
	var origin: Vector3 = $Camera3D.project_ray_origin(screen_position)
	var direction: Vector3 = $Camera3D.project_ray_normal(screen_position)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 200.0)
	query.collision_mask = 3
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider = hit.collider
	var hit_id: String = collider.get_meta("part_id", "") if collider.has_meta("part_id") else ""
	if _tool == "select":
		_selected_id = hit_id
		_refresh_editor()
		_update_status("Selected: %s" % _selected_id if not _selected_id.is_empty() else "Tap a part to select it.")
	elif _tool == "move" and not _selected_id.is_empty() and hit_id.is_empty():
		_move_selected(hit.position)
	elif _tool in ["block", "wheel"] and hit_id.is_empty():
		_place_part(hit.position, _tool)


func _place_part(hit_position: Vector3, kind: String) -> void:
	var cell := Vector3(roundf(hit_position.x / GRID_SIZE), 0.75 if kind == "block" else 0.5, roundf(hit_position.z / GRID_SIZE))
	for part in _vehicle.parts:
		if Vector2(part.transform.origin.x, part.transform.origin.z).distance_to(Vector2(cell.x, cell.z)) < 0.1:
			_update_status("That space is occupied.")
			return
	var part_id := _next_part_id(kind)
	var part = PartData.new(part_id, Transform3D(Basis.IDENTITY, cell), kind)
	if not _vehicle.add_part(part):
		return
	if kind == "block":
		var neighbors := _adjacent_blocks(part)
		var has_blocks := false
		for existing in _vehicle.parts:
			has_blocks = has_blocks or existing.kind == "block"
		if has_blocks and neighbors.is_empty():
			_vehicle.remove_part(part_id)
			_update_status("Place blocks next to the frame.")
			return
		_vehicle.connections.clear()
		_rebuild_connections()
	else:
		var neighbor = _wheel_mount(part)
		if neighbor == null:
			_vehicle.remove_part(part_id)
			_update_status("Place wheels beside a block.")
			return
		_vehicle.add_connection(neighbor.id, part.id, "hinge")
	_selected_id = part_id
	_refresh_editor()
	_update_status("Placed %s." % ("block" if kind == "block" else "wheel"))


func _move_selected(hit_position: Vector3) -> void:
	var part = _vehicle.find_part(_selected_id)
	if part == null:
		return
	var previous: Transform3D = part.transform
	var new_origin := Vector3(roundf(hit_position.x / GRID_SIZE), previous.origin.y, roundf(hit_position.z / GRID_SIZE))
	for other in _vehicle.parts:
		if other.id != part.id and Vector2(other.transform.origin.x, other.transform.origin.z).distance_to(Vector2(new_origin.x, new_origin.z)) < 0.1:
			_update_status("That space is occupied.")
			return
	part.transform = Transform3D(previous.basis, new_origin)
	_vehicle.connections.clear()
	var valid := true
	for block in _vehicle.parts:
		if block.kind == "block":
			for neighbor in _adjacent_blocks(block):
				if block.id < neighbor.id:
					_vehicle.add_connection(block.id, neighbor.id, "fixed")
	for wheel in _vehicle.parts:
		if wheel.kind == "wheel":
			var mount = _wheel_mount(wheel)
			if mount == null:
				valid = false
				break
			_vehicle.add_connection(mount.id, wheel.id, "hinge")
	if not _vehicle.blocks_connected():
		valid = false
	if not valid:
		part.transform = previous
		_vehicle.connections.clear()
		_rebuild_connections()
		_update_status("Move it where all parts stay connected.")
		return
	_refresh_editor()
	_update_status("Part moved.")


func _rebuild_connections() -> void:
	for part in _vehicle.parts:
		if part.kind == "block":
			for neighbor in _adjacent_blocks(part):
				if part.id < neighbor.id:
					_vehicle.add_connection(part.id, neighbor.id, "fixed")
	for wheel in _vehicle.parts:
		if wheel.kind == "wheel":
			var mount = _wheel_mount(wheel)
			if mount != null:
				_vehicle.add_connection(mount.id, wheel.id, "hinge")


func _adjacent_blocks(part) -> Array:
	var result: Array = []
	for other in _vehicle.parts:
		if other.kind == "block" and other.id != part.id:
			var delta: Vector3 = part.transform.origin - other.transform.origin
			if absf(delta.x) + absf(delta.z) == GRID_SIZE:
				result.append(other)
	return result


func _wheel_mount(wheel):
	for block in _vehicle.parts:
		if block.kind == "block":
			var delta: Vector3 = wheel.transform.origin - block.transform.origin
			if absf(delta.x) == GRID_SIZE and absf(delta.z) < 0.1:
				return block
	return null


func _next_part_id(kind: String) -> String:
	var prefix := "block" if kind == "block" else "wheel"
	while _vehicle.find_part("%s-%d" % [prefix, _next_id]) != null:
		_next_id += 1
	var result := "%s-%d" % [prefix, _next_id]
	_next_id += 1
	return result


func _delete_selected() -> void:
	if _running or _selected_id.is_empty():
		return
	if not _vehicle.remove_part(_selected_id):
		return
	_selected_id = ""
	_refresh_editor()
	_update_status("Selected part deleted.")


func _set_tool(tool: String) -> void:
	_tool = tool
	_update_status({"select": "Tap a part to select it.", "block": "Tap the ground to place a block.", "wheel": "Tap beside a block to place a wheel.", "move": "Select a part, then tap its destination."}[tool])


func _start_trial() -> void:
	if _running:
		return
	if not _vehicle.can_drive():
		_update_status("Trial needs a connected frame and at least two mounted wheels.")
		return
	if _preview != null:
		_preview.queue_free()
		_preview = null
	_runtime = VehicleAdapter.create_runtime_vehicle(_vehicle)
	add_child(_runtime)
	_chassis = _runtime.get_node("Chassis")
	_running = true
	_update_status("Drive with W/S and steer with A/D or the buttons. Edit to rebuild.")


func _return_to_edit() -> void:
	if not _running:
		return
	_running = false
	_drive_buttons = {"forward": false, "back": false, "left": false, "right": false}
	_runtime.queue_free()
	_runtime = null
	_chassis = null
	_show_editor()
	_update_status("Back to edit. Add, move or delete parts, then run another trial.")


func _refresh_editor() -> void:
	if _preview != null:
		_preview.queue_free()
	_preview = VehicleAdapter.create_editor_view(_vehicle, _selected_id)
	add_child(_preview)


func _save_vehicle() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_update_status("Save failed: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(_vehicle.to_json())
	if file.get_error() != OK:
		_update_status("Save failed.")
		return false
	_update_status("Vehicle saved.")
	return true


func _load_vehicle() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_update_status("No saved vehicle.")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_update_status("Could not read saved vehicle.")
		return
	var restored = VehicleData.from_json(file.get_as_text())
	if restored == null:
		_update_status("Saved vehicle is invalid. Current vehicle kept.")
		return
	_vehicle = restored
	_selected_id = ""
	if _preview != null:
		_refresh_editor()
	_update_status("Vehicle loaded.")


func _open_drawing_demo() -> void:
	if _save_vehicle():
		get_tree().change_scene_to_file("res://experiments/draw_physics/main.tscn")


func _update_status(message: String) -> void:
	if _status != null:
		_status.text = message


func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.9
	return result
