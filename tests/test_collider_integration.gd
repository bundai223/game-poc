extends GdUnitTestSuite

const DrawPhysics = preload("res://experiments/draw_physics/main.tscn")
const OutlineData = preload("res://experiments/draw_physics/outline_data.gd")


func test_drag_creates_matching_polygon_and_collision_nodes() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(100, 100)
	demo._unhandled_input(press)
	var move := InputEventMouseMotion.new()
	move.position = Vector2(200, 100)
	demo._unhandled_input(move)
	move.position = Vector2(150, 200)
	demo._unhandled_input(move)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = Vector2(150, 200)
	demo._unhandled_input(release)

	assert_int(demo._created_bodies.size()).is_equal(1)
	var body: RigidBody2D = demo._created_bodies[0]
	var visual: Polygon2D = body.get_child(0)
	var collider: CollisionPolygon2D = body.get_child(1)
	assert_bool(visual.polygon == collider.polygon).is_true()
	assert_bool(body.position.distance_to(Vector2(150, 133.3333)) < 0.01).is_true()


func test_single_touch_creates_one_body_and_reset_removes_it() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	for position in [Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)]:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.pressed = true
		touch.position = position
		demo._unhandled_input(touch)
		if position == Vector2(200, 100):
			var mouse := InputEventMouseButton.new()
			mouse.button_index = MOUSE_BUTTON_LEFT
			mouse.pressed = true
			mouse.position = position
			demo._unhandled_input(mouse)
			mouse.pressed = false
			demo._unhandled_input(mouse)
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = position
		demo._unhandled_input(drag)
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.position = Vector2(150, 200)
	demo._unhandled_input(release)
	assert_int(demo._created_bodies.size()).is_equal(1)
	demo.reset()
	assert_int(demo._created_bodies.size()).is_zero()


func test_cancelled_touch_does_not_create_body() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100, 100)
	demo._unhandled_input(touch)
	for position in [Vector2(200, 100), Vector2(150, 200)]:
		var drag := InputEventScreenDrag.new()
		drag.position = position
		demo._unhandled_input(drag)
	touch.pressed = false
	touch.canceled = true
	demo._unhandled_input(touch)
	assert_int(demo._created_bodies.size()).is_zero()
	assert_bool(demo._drawing).is_false()


func test_excessively_long_stroke_is_discarded() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	demo._unhandled_input(press)
	var move := InputEventMouseMotion.new()
	for i in range(2049):
		move.position = Vector2(i * 4, 100)
		demo._unhandled_input(move)
	assert_bool(demo._drawing).is_false()
	assert_int(demo._created_bodies.size()).is_zero()


func test_reset_button_removes_drawn_bodies() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var points := PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])
	demo.spawn_body(OutlineData.new(points))
	var button := demo.find_child("ResetButton", true, false) as Button
	assert_object(button).is_not_null()
	if button == null:
		return
	button.pressed.emit()
	assert_int(demo._created_bodies.size()).is_zero()


func test_touching_reset_button_is_not_a_drawing() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	await get_tree().process_frame
	demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])))
	var button := demo.find_child("ResetButton", true, false) as Button
	var touch := InputEventScreenTouch.new()
	touch.position = button.get_global_rect().get_center()
	touch.pressed = true
	get_viewport().push_input(touch)
	touch.pressed = false
	get_viewport().push_input(touch)
	assert_int(demo._created_bodies.size()).is_zero()
	assert_bool(demo._drawing).is_false()


func test_touch_drag_through_viewport_creates_body() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	await get_tree().process_frame
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100, 100)
	get_viewport().push_input(touch)
	var drag := InputEventScreenDrag.new()
	for position in [Vector2(200, 100), Vector2(150, 200)]:
		drag.position = position
		get_viewport().push_input(drag)
	touch.pressed = false
	touch.position = Vector2(150, 200)
	get_viewport().push_input(touch)
	assert_int(demo._created_bodies.size()).is_equal(1)


func test_touch_drag_with_nonzero_index_creates_body() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	await get_tree().process_frame
	var touch := InputEventScreenTouch.new()
	touch.index = 1
	touch.pressed = true
	touch.position = Vector2(100, 100)
	get_viewport().push_input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	for position in [Vector2(200, 100), Vector2(150, 200)]:
		drag.position = position
		get_viewport().push_input(drag)
	touch.pressed = false
	touch.position = Vector2(150, 200)
	get_viewport().push_input(touch)
	assert_int(demo._created_bodies.size()).is_equal(1)
