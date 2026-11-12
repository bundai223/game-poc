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
	var border: Line2D = visual.get_child(0)
	assert_bool(border.closed).is_true()
	assert_bool(border.points == visual.polygon).is_true()
	assert_bool(border.default_color == Color.BLACK).is_true()
	assert_bool(body.position.distance_to(Vector2(150, 133.3333)) < 0.01).is_true()


func test_concave_stroke_creates_a_body() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var points := PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(220, 150), Vector2(300, 300), Vector2(100, 300)])
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = points[0]
	demo._unhandled_input(press)
	var move := InputEventMouseMotion.new()
	for index in range(1, points.size()):
		move.position = points[index]
		demo._unhandled_input(move)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = points[0]
	demo._unhandled_input(release)

	assert_int(demo._created_bodies.size()).is_equal(1)
	var visual: Polygon2D = demo._created_bodies[0].get_child(0)
	var border: Line2D = visual.get_child(0)
	assert_bool(border.closed and border.points == visual.polygon).is_true()


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


func test_delete_mode_hits_transformed_body_and_preserves_other_bodies() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	demo.position = Vector2(40, 30)
	var points := PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])
	var target: RigidBody2D = demo.spawn_body(OutlineData.new(points))
	target.freeze = true
	target.rotation = PI / 4
	var other: RigidBody2D = demo.spawn_body(OutlineData.new(points))
	other.position += Vector2(300, 0)
	other.freeze = true
	await get_tree().physics_frame
	var mode := demo.find_child("ModeButton", true, false) as Button
	mode.pressed.emit()
	mode.pressed.emit()
	assert_str(mode.text).is_equal("Mode: Delete")
	var touch := InputEventScreenTouch.new()
	touch.index = 7
	touch.pressed = true
	touch.position = demo.get_canvas_transform() * target.global_position
	demo._unhandled_input(touch)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(demo._created_bodies.size()).is_equal(1)
	assert_bool(demo._created_bodies[0] == other).is_true()
	touch.position = Vector2(10, 10)
	demo._unhandled_input(touch)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(demo._created_bodies.size()).is_equal(1)
	mode.pressed.emit()
	assert_str(mode.text).is_equal("Mode: Draw")


func test_delete_mode_cancels_in_progress_drawing() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(100, 100)
	demo._unhandled_input(press)
	var mode := demo.find_child("ModeButton", true, false) as Button
	mode.pressed.emit()
	mode.pressed.emit()
	assert_bool(demo._drawing).is_false()
	assert_int(demo._outline.size()).is_zero()


func test_mouse_click_in_delete_mode_and_reset_pending_input() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var points := PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])
	var body: RigidBody2D = demo.spawn_body(OutlineData.new(points))
	body.freeze = true
	await get_tree().physics_frame
	var mode := demo.find_child("ModeButton", true, false) as Button
	mode.pressed.emit()
	mode.pressed.emit()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = body.global_position
	demo._unhandled_input(click)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(demo._created_bodies.size()).is_zero()
	body = demo.spawn_body(OutlineData.new(points))
	body.freeze = true
	demo._unhandled_input(click)
	mode.pressed.emit()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(demo._created_bodies.size()).is_equal(1)

func test_cut_mode_freezes_splits_and_resumes_bodies() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var body: RigidBody2D = demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(300, 300), Vector2(100, 300)])))
	body.linear_velocity = Vector2(30, 10)
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var touch := InputEventScreenTouch.new()
	touch.index = 4
	touch.position = Vector2(50, 200)
	touch.pressed = true
	demo._unhandled_input(touch)
	assert_bool(body.freeze).is_true()
	var drag := InputEventScreenDrag.new()
	drag.index = 4
	drag.position = Vector2(350, 200)
	demo._unhandled_input(drag)
	touch.position = drag.position
	touch.pressed = false
	demo._unhandled_input(touch)
	assert_int(demo._created_bodies.size()).is_equal(2)
	for piece in demo._created_bodies:
		var visual: Polygon2D = piece.get_child(0)
		var border: Line2D = visual.get_child(0)
		assert_bool(border.closed and border.points == visual.polygon).is_true()
		assert_bool(piece.freeze).is_false()
		assert_bool(piece.linear_velocity.is_equal_approx(Vector2(30, 10))).is_true()


func test_cancelling_cut_restores_motion() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var body: RigidBody2D = demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(100, 300)])))
	body.linear_velocity = Vector2(20, 30)
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(50, 150)
	demo._unhandled_input(touch)
	touch.canceled = true
	touch.pressed = false
	demo._unhandled_input(touch)
	assert_bool(body.freeze).is_false()
	assert_bool(body.linear_velocity.is_equal_approx(Vector2(20, 30))).is_true()
	assert_int(demo._created_bodies.size()).is_equal(1)


func test_cut_applies_to_multiple_rotated_bodies() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var square := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)])
	var first: RigidBody2D = demo.spawn_body(OutlineData.new(square))
	first.rotation = 0.3
	var second: RigidBody2D = demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(200, 0), Vector2(300, 0), Vector2(300, 100), Vector2(200, 100)])))
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = Vector2(-100, 50)
	mouse.pressed = true
	demo._unhandled_input(mouse)
	mouse.position = Vector2(400, 50)
	mouse.pressed = false
	demo._unhandled_input(mouse)
	assert_int(demo._created_bodies.size()).is_equal(4)
	assert_bool(is_equal_approx(demo._created_bodies[0].rotation, 0.3)).is_true()
	assert_bool(second.is_queued_for_deletion()).is_true()


func test_pause_during_cut_creates_a_bend() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = Vector2(20, 50)
	mouse.pressed = true
	demo._unhandled_input(mouse)
	var move := InputEventMouseMotion.new()
	move.position = Vector2(100, 100)
	demo._unhandled_input(move)
	demo._last_motion_ms = Time.get_ticks_msec() - 200
	demo._process(0.0)
	demo._process(0.0)
	assert_int(demo._outline.size()).is_equal(2)
	assert_bool(demo._outline[1].is_equal_approx(Vector2(100, 100))).is_true()
	button.pressed.emit()


func test_direction_change_adds_corner_and_cuts_on_mouse_release() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(300, 300), Vector2(100, 300)])))
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = Vector2(50, 200)
	mouse.pressed = true
	demo._unhandled_input(mouse)
	var move := InputEventMouseMotion.new()
	for point in [Vector2(100, 200), Vector2(150, 200), Vector2(200, 200), Vector2(200, 250), Vector2(200, 350)]:
		move.position = point
		demo._unhandled_input(move)
	assert_int(demo._outline.size()).is_equal(2)
	assert_bool(demo._outline[1].is_equal_approx(Vector2(200, 200))).is_true()
	mouse.position = Vector2(200, 350)
	mouse.pressed = false
	demo._unhandled_input(mouse)
	assert_int(demo._created_bodies.size()).is_equal(2)


func test_touch_small_jitter_does_not_create_corners() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var touch := InputEventScreenTouch.new()
	touch.index = 3
	touch.position = Vector2(30, 100)
	touch.pressed = true
	demo._unhandled_input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 3
	for point in [Vector2(50, 100), Vector2(60, 102), Vector2(70, 99), Vector2(80, 101), Vector2(100, 100)]:
		drag.position = point
		demo._unhandled_input(drag)
	assert_int(demo._outline.size()).is_equal(1)
	touch.canceled = true
	touch.pressed = false
	demo._unhandled_input(touch)
	assert_bool(demo._drawing).is_false()


func test_touch_direction_change_creates_corner_and_cuts() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(300, 300), Vector2(100, 300)])))
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	var touch := InputEventScreenTouch.new()
	touch.index = 7
	touch.position = Vector2(50, 200)
	touch.pressed = true
	demo._unhandled_input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 7
	for point in [Vector2(120, 200), Vector2(200, 200), Vector2(200, 250), Vector2(200, 350)]:
		drag.position = point
		demo._unhandled_input(drag)
	assert_int(demo._outline.size()).is_equal(2)
	assert_bool(demo._outline[1].is_equal_approx(Vector2(200, 200))).is_true()
	touch.position = Vector2(200, 350)
	touch.pressed = false
	demo._unhandled_input(touch)
	assert_int(demo._created_bodies.size()).is_equal(2)


func test_paused_corner_is_not_added_twice_when_direction_changes() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var button := demo.find_child("ModeButton", true, false) as Button
	button.pressed.emit()
	demo._begin_draw(Vector2(50, 100))
	demo._add_point(Vector2(150, 100))
	demo._last_motion_ms = Time.get_ticks_msec() - 200
	demo._process(0.0)
	demo._add_point(Vector2(150, 130))
	assert_int(demo._outline.size()).is_equal(2)
	assert_bool(demo._outline[1].is_equal_approx(Vector2(150, 100))).is_true()
	button.pressed.emit()

func test_switching_from_cut_to_delete_resumes_body() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var body: RigidBody2D = demo.spawn_body(OutlineData.new(PackedVector2Array([Vector2(100, 100), Vector2(300, 100), Vector2(100, 300)])))
	body.linear_velocity = Vector2(20, 30)
	var mode := demo.find_child("ModeButton", true, false) as Button
	mode.pressed.emit()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(50, 150)
	demo._unhandled_input(touch)
	assert_bool(body.freeze).is_true()
	mode.pressed.emit()
	assert_str(mode.text).is_equal("Mode: Delete")
	assert_bool(body.freeze).is_false()
	assert_bool(body.linear_velocity.is_equal_approx(Vector2(20, 30))).is_true()
	assert_bool(demo._drawing).is_false()
