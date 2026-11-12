extends GdUnitTestSuite

const PartData = preload("res://experiments/draw_physics/part_data.gd")
const VehicleData = preload("res://experiments/vehicle_craft/vehicle_data.gd")
const VehicleAdapter = preload("res://experiments/vehicle_craft/vehicle_adapter.gd")


func test_starter_vehicle_has_a_fixed_frame_and_two_hinged_wheels() -> void:
	var vehicle = VehicleData.create_starter()
	assert_int(vehicle.parts.size()).is_equal(3)
	assert_int(vehicle.connections.size()).is_equal(2)
	assert_bool(vehicle.can_drive()).is_true()
	var runtime = VehicleAdapter.create_runtime_vehicle(vehicle)
	assert_int(runtime.find_children("*", "RigidBody3D", true, false).size()).is_equal(3)
	assert_int(runtime.find_children("*", "HingeJoint3D", true, false).size()).is_equal(2)
	runtime.free()


func test_vehicle_parts_and_connections_round_trip_through_json() -> void:
	var vehicle = VehicleData.new()
	vehicle.add_part(PartData.new("frame", Transform3D(Basis.IDENTITY, Vector3(0, 0.5, 0)), "block"))
	vehicle.add_part(PartData.new("left-wheel", Transform3D(Basis.IDENTITY, Vector3(-1, 0.5, 0)), "wheel"))
	vehicle.add_part(PartData.new("right-wheel", Transform3D(Basis.IDENTITY, Vector3(1, 0.5, 0)), "wheel"))
	vehicle.add_connection("frame", "left-wheel", "hinge")
	vehicle.add_connection("frame", "right-wheel", "hinge")

	var restored = VehicleData.from_json(vehicle.to_json())
	assert_object(restored).is_not_null()
	assert_int(restored.parts.size()).is_equal(3)
	assert_int(restored.connections.size()).is_equal(2)
	assert_bool(restored.can_drive()).is_true()


func test_unconnected_frame_blocks_cannot_drive() -> void:
	var vehicle = VehicleData.create_starter()
	vehicle.add_part(PartData.new("block-2", Transform3D(Basis.IDENTITY, Vector3(4, 0.5, 0)), "block"))
	assert_bool(vehicle.can_drive()).is_false()


func test_two_wheels_on_the_same_side_cannot_turn() -> void:
	var vehicle = VehicleData.new()
	vehicle.add_part(PartData.new("frame", Transform3D(Basis.IDENTITY, Vector3(0, 0.5, 0)), "block"))
	vehicle.add_part(PartData.new("wheel-a", Transform3D(Basis.IDENTITY, Vector3(-1, 0.45, 0)), "wheel"))
	vehicle.add_part(PartData.new("wheel-b", Transform3D(Basis.IDENTITY, Vector3(-1, 0.45, 1)), "wheel"))
	vehicle.add_connection("frame", "wheel-a", "hinge")
	vehicle.add_connection("frame", "wheel-b", "hinge")
	assert_bool(vehicle.can_drive()).is_false()


func test_removing_a_wheel_removes_its_hinge_connection() -> void:
	var vehicle = VehicleData.create_starter()
	assert_bool(vehicle.remove_part("wheel-1")).is_true()
	assert_int(vehicle.connections.size()).is_equal(1)
	assert_bool(vehicle.can_drive()).is_false()


func test_connections_require_known_parts_and_compatible_types() -> void:
	var vehicle = VehicleData.create_starter()
	assert_bool(vehicle.add_connection("frame", "wheel-1", "hinge")).is_false()
	assert_bool(vehicle.add_connection("block-1", "missing", "hinge")).is_false()
	assert_bool(vehicle.add_connection("wheel-1", "wheel-2", "fixed")).is_false()
	assert_bool(vehicle.add_connection("block-1", "wheel-1", "unknown")).is_false()
