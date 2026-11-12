extends GdUnitTestSuite

const VehicleCraft = preload("res://experiments/vehicle_craft/main.tscn")


func test_starter_vehicle_can_switch_between_trial_and_edit() -> void:
	var demo := VehicleCraft.instantiate()
	add_child(demo)
	await get_tree().process_frame
	assert_bool(demo._vehicle.can_drive()).is_true()
	var buttons := demo.find_children("*", "Button", true, false)
	var run_button: Button
	var edit_button: Button
	for node in buttons:
		if node.text == "試走 ↵":
			run_button = node
		elif node.text == "編集 Esc":
			edit_button = node
	assert_object(run_button).is_not_null()
	assert_object(edit_button).is_not_null()
	run_button.pressed.emit()
	assert_bool(demo._running).is_true()
	assert_int(demo._runtime.find_children("*", "HingeJoint3D", true, false).size()).is_equal(2)
	edit_button.pressed.emit()
	assert_bool(demo._running).is_false()
	assert_object(demo._preview).is_not_null()


func test_drive_button_moves_chassis_and_spins_wheels() -> void:
	var demo := VehicleCraft.instantiate()
	add_child(demo)
	await get_tree().process_frame
	demo._start_trial()
	var forward_button: Button
	for node in demo.find_children("*", "Button", true, false):
		if node.text == "前進 W":
			forward_button = node
	assert_object(forward_button).is_not_null()
	var wheel: RigidBody3D = demo._runtime.get_node("Wheel_wheel-1")
	forward_button.button_down.emit()
	for _frame in 90:
		await get_tree().physics_frame
	forward_button.button_up.emit()
	assert_bool(demo._chassis.position.z < -0.1).is_true()
	assert_bool(absf(wheel.angular_velocity.x) > 0.1).is_true()
	var right_button: Button
	for node in demo.find_children("*", "Button", true, false):
		if node.text == "右 D":
			right_button = node
	assert_object(right_button).is_not_null()
	var heading: float = demo._chassis.rotation.y
	right_button.button_down.emit()
	for _frame in 60:
		await get_tree().physics_frame
	right_button.button_up.emit()
	assert_bool(absf(demo._chassis.rotation.y - heading) > 0.1).is_true()
	demo._return_to_edit()


func test_blocks_and_wheels_can_be_placed_moved_and_deleted() -> void:
	var demo := VehicleCraft.instantiate()
	add_child(demo)
	await get_tree().process_frame
	demo._place_part(Vector3(0, 0, 1), "block")
	var block = demo._vehicle.find_part("block-3")
	assert_object(block).is_not_null()
	demo._selected_id = block.id
	demo._move_selected(Vector3(0, 0, -1))
	assert_bool(block.transform.origin.is_equal_approx(Vector3(0, 0.5, -1))).is_true()
	demo._place_part(Vector3(1, 0, -1), "wheel")
	var wheel
	for part in demo._vehicle.parts:
		if part.kind == "wheel" and part.id not in ["wheel-1", "wheel-2"]:
			wheel = part
	assert_object(wheel).is_not_null()
	assert_bool(demo._vehicle.can_drive()).is_true()
	demo._selected_id = wheel.id
	demo._delete_selected()
	assert_object(demo._vehicle.find_part(wheel.id)).is_null()
	assert_bool(demo._vehicle.can_drive()).is_true()
