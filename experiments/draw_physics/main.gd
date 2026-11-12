extends Node2D

const Outline = preload("res://experiments/draw_physics/outline.gd")
const OutlineData = preload("res://experiments/draw_physics/outline_data.gd")
const RigidBodyAdapter = preload("res://experiments/draw_physics/rigid_body_adapter.gd")
const Slice = preload("res://experiments/draw_physics/slice.gd")
const FLOOR_WIDTH := 10000.0
const FLOOR_HEIGHT := 32.0

var _cut_mode := false
var _cut_cursor := Vector2.ZERO
var _direction_point := Vector2.ZERO
var _last_motion_ms := 0
const CUT_SLOW_SPEED := 80.0
const CUT_PAUSE_MS := 150
const CUT_DIRECTION_DISTANCE := 12.0
const CUT_DIRECTION_COSINE := 0.70710678
var _frozen_bodies := {}
var _floor_y := 0.0
var _drawing := false
var _touch_index := -1
var _outline := PackedVector2Array()
var _created_bodies: Array[RigidBody2D] = []


func _ready() -> void:
	_floor_y = get_viewport_rect().size.y - FLOOR_HEIGHT
	var floor := StaticBody2D.new()
	floor.position = Vector2(400.0, _floor_y + FLOOR_HEIGHT / 2.0)
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(FLOOR_WIDTH, FLOOR_HEIGHT)
	collider.shape = shape
	floor.add_child(collider)
	add_child(floor)

	var instructions := Label.new()
	instructions.position = Vector2(24.0, 20.0)
	instructions.text = "Draw shapes, then switch to Cut and drag a line."
	add_child(instructions)
	var controls := CanvasLayer.new()
	add_child(controls)
	var reset_button := Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "Reset"
	reset_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	reset_button.offset_left = -216.0
	reset_button.offset_top = 16.0
	reset_button.offset_right = -24.0
	reset_button.offset_bottom = 104.0
	reset_button.pressed.connect(reset)
	controls.add_child(reset_button)
	var craft_button := Button.new()
	craft_button.name = "VehicleCraftButton"
	craft_button.text = "3D Craft"
	craft_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	craft_button.offset_left = -216.0
	craft_button.offset_top = 112.0
	craft_button.offset_right = -24.0
	craft_button.offset_bottom = 200.0
	craft_button.pressed.connect(_open_vehicle_craft)
	controls.add_child(craft_button)
	var mode_button := Button.new()
	mode_button.name = "ModeButton"
	mode_button.text = "Mode: Draw"
	mode_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	mode_button.offset_left = -216.0
	mode_button.offset_top = 208.0
	mode_button.offset_right = -24.0
	mode_button.offset_bottom = 296.0
	mode_button.pressed.connect(func():
		_cancel_draw()
		_cut_mode = not _cut_mode
		mode_button.text = "Mode: Cut" if _cut_mode else "Mode: Draw"
	)
	controls.add_child(mode_button)
	queue_redraw()


func _process(_delta: float) -> void:
	if _drawing and _cut_mode and Time.get_ticks_msec() - _last_motion_ms >= CUT_PAUSE_MS:
		if _outline[-1].distance_to(_cut_cursor) >= 3.0:
			_outline.append(_cut_cursor)
			_direction_point = _cut_cursor
			queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		reset()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _touch_index == -1:
			_begin_draw(to_local(event.position))
		elif _drawing and _touch_index == -1:
			_finish_draw(to_local(event.position))
	elif event is InputEventMouseMotion and _drawing and _touch_index == -1:
		_add_point(to_local(event.position))
	elif event is InputEventScreenTouch:
		if event.canceled and event.index == _touch_index:
			_cancel_draw()
		elif event.pressed and not _drawing:
			_touch_index = event.index
			_begin_draw(to_local(event.position))
		elif not event.pressed and event.index == _touch_index:
			_finish_draw(to_local(event.position))
			_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _touch_index and _drawing:
		_add_point(to_local(event.position))


func reset() -> void:
	_cancel_draw()
	for body in _created_bodies:
		body.queue_free()
	_created_bodies.clear()
	queue_redraw()


func spawn_body(outline: OutlineData) -> RigidBody2D:
	var body := RigidBodyAdapter.create_body(outline)
	add_child(body)
	_created_bodies.append(body)
	return body


func _open_vehicle_craft() -> void:
	get_tree().change_scene_to_file("res://experiments/vehicle_craft/main.tscn")


func _begin_draw(point: Vector2) -> void:
	_drawing = true
	_outline = PackedVector2Array([point])
	if _cut_mode:
		_cut_cursor = point
		_direction_point = point
		_last_motion_ms = Time.get_ticks_msec()
		for body in _created_bodies:
			_frozen_bodies[body] = [body.freeze, body.linear_velocity, body.angular_velocity]
			body.freeze = true
	queue_redraw()


func _add_point(point: Vector2) -> void:
	if _cut_mode:
		var now := Time.get_ticks_msec()
		var elapsed := now - _last_motion_ms
		if elapsed > 0 and _cut_cursor.distance_to(point) * 1000.0 / elapsed < CUT_SLOW_SPEED and _outline[-1].distance_to(_cut_cursor) >= 3.0:
			_outline.append(_cut_cursor)
			_direction_point = _cut_cursor
		elif _direction_point.distance_to(point) >= CUT_DIRECTION_DISTANCE:
			var incoming := _direction_point - _outline[-1]
			var outgoing := point - _direction_point
			if incoming.length() >= CUT_DIRECTION_DISTANCE and incoming.normalized().dot(outgoing.normalized()) < CUT_DIRECTION_COSINE:
				_outline.append(_direction_point)
			_direction_point = point
		if _outline.size() >= 2048:
			_cancel_draw()
			return
		_cut_cursor = point
		_last_motion_ms = now
		queue_redraw()
		return
	if _outline.is_empty() or _outline[-1].distance_to(point) >= 3.0:
		if _outline.size() >= 2048:
			_cancel_draw()
			return
		_outline.append(point)
		queue_redraw()


func _finish_draw(point: Vector2) -> void:
	if not _drawing:
		return
	_add_point(point)
	if not _drawing:
		return
	_drawing = false
	if _cut_mode:
		if _outline[-1].distance_to(point) >= 3.0:
			_outline.append(point)
		_cut_bodies()
		_cancel_draw()
		return
	var points := Outline.prepare(_outline)
	_outline.clear()
	if not points.is_empty():
		spawn_body(OutlineData.new(points))
	queue_redraw()


func _cancel_draw() -> void:
	_drawing = false
	_touch_index = -1
	_outline.clear()
	for body in _frozen_bodies:
		if is_instance_valid(body):
			var state: Array = _frozen_bodies[body]
			body.freeze = state[0]
			body.linear_velocity = state[1]
			body.angular_velocity = state[2]
	_frozen_bodies.clear()
	queue_redraw()


func _cut_bodies() -> void:
	for body in _created_bodies.duplicate():
		var visual: Polygon2D = body.get_child(0)
		var polygon := PackedVector2Array()
		for point in visual.polygon:
			polygon.append(to_local(body.to_global(point)))
		var pieces := Slice.split(polygon, _outline)
		if pieces.size() < 2:
			continue
		var state: Array = _frozen_bodies[body]
		var center := to_local(body.to_global(body.center_of_mass))
		_created_bodies.erase(body)
		_frozen_bodies.erase(body)
		body.queue_free()
		for points in pieces:
			var local_points := PackedVector2Array()
			for point in points:
				local_points.append(body.to_local(to_global(point)))
			var part := spawn_body(OutlineData.new(local_points))
			part.transform = body.transform * part.transform
			part.linear_velocity = state[1] + (part.position - center).orthogonal() * state[2]
			part.angular_velocity = state[2]


func _draw() -> void:
	draw_line(Vector2(400.0 - FLOOR_WIDTH / 2.0, _floor_y), Vector2(400.0 + FLOOR_WIDTH / 2.0, _floor_y), Color(0.85, 0.9, 0.95), 4.0)
	if _outline.size() > 1 or (_cut_mode and _drawing and _outline.size() == 1):
		var preview := _outline.duplicate()
		if _drawing:
			preview.append(_cut_cursor if _cut_mode else _outline[0])
		draw_polyline(preview, Color(1.0, 0.8, 0.25), 3.0, true)
