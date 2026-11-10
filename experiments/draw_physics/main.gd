extends Node2D

const Outline = preload("res://experiments/draw_physics/outline.gd")
const FLOOR_Y := 560.0
const FLOOR_WIDTH := 10000.0
const FLOOR_HEIGHT := 32.0

var _drawing := false
var _touch_index := -1
var _outline := PackedVector2Array()
var _created_bodies: Array[RigidBody2D] = []


func _ready() -> void:
	var floor := StaticBody2D.new()
	floor.position = Vector2(400.0, FLOOR_Y + FLOOR_HEIGHT / 2.0)
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(FLOOR_WIDTH, FLOOR_HEIGHT)
	collider.shape = shape
	floor.add_child(collider)
	add_child(floor)

	var instructions := Label.new()
	instructions.position = Vector2(24.0, 20.0)
	instructions.text = "Drag to draw a convex shape. Release to drop it."
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
			_drawing = false
			_touch_index = -1
			_outline.clear()
			queue_redraw()
		elif event.pressed and not _drawing:
			_touch_index = event.index
			_begin_draw(to_local(event.position))
		elif not event.pressed and event.index == _touch_index:
			_finish_draw(to_local(event.position))
			_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _touch_index and _drawing:
		_add_point(to_local(event.position))


func reset() -> void:
	_drawing = false
	_touch_index = -1
	_outline.clear()
	for body in _created_bodies:
		body.queue_free()
	_created_bodies.clear()
	queue_redraw()


func spawn_body(points: PackedVector2Array) -> RigidBody2D:
	var origin := Vector2.ZERO
	for point in points:
		origin += point
	origin /= points.size()
	var local_points := PackedVector2Array()
	for point in points:
		local_points.append(point - origin)
	var body := RigidBody2D.new()
	body.position = origin
	var visual := Polygon2D.new()
	visual.polygon = local_points
	visual.color = Color(0.2, 0.68, 0.95)
	body.add_child(visual)
	var collider := CollisionPolygon2D.new()
	collider.polygon = local_points
	body.add_child(collider)
	add_child(body)
	_created_bodies.append(body)
	return body


func _begin_draw(point: Vector2) -> void:
	_drawing = true
	_outline = PackedVector2Array([point])
	queue_redraw()


func _add_point(point: Vector2) -> void:
	if _outline.is_empty() or _outline[-1].distance_to(point) >= 3.0:
		if _outline.size() >= 2048:
			_drawing = false
			_touch_index = -1
			_outline.clear()
			queue_redraw()
			return
		_outline.append(point)
		queue_redraw()


func _finish_draw(point: Vector2) -> void:
	if not _drawing:
		return
	_add_point(point)
	_drawing = false
	var points := Outline.prepare(_outline)
	_outline.clear()
	if not points.is_empty():
		spawn_body(points)
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2(400.0 - FLOOR_WIDTH / 2.0, FLOOR_Y), Vector2(400.0 + FLOOR_WIDTH / 2.0, FLOOR_Y), Color(0.85, 0.9, 0.95), 4.0)
	if _outline.size() > 1:
		var preview := _outline.duplicate()
		if _drawing:
			preview.append(_outline[0])
		draw_polyline(preview, Color(1.0, 0.8, 0.25), 3.0, true)
