extends GdUnitTestSuite

const OutlineData = preload("res://experiments/draw_physics/outline_data.gd")
const PartData = preload("res://experiments/draw_physics/part_data.gd")


func test_outline_round_trips_through_json_without_a_scene_tree() -> void:
	var points := PackedVector2Array([Vector2(1.5, -2.0), Vector2(10, 0), Vector2(0, 12)])
	var outline = OutlineData.new(points)
	var restored = OutlineData.from_json(outline.to_json())
	assert_object(restored).is_not_null()
	assert_bool(restored.points == points).is_true()


func test_invalid_outline_json_is_rejected() -> void:
	assert_object(OutlineData.from_json("not json")).is_null()
	assert_object(OutlineData.from_json('{"version":1,"points":[[0,0],[1,1]]}')).is_null()
	assert_object(OutlineData.from_json('{"version":2,"points":[[0,0],[1,1],[2,2]]}')).is_null()
	assert_object(OutlineData.from_json('{"version":1,"points":[[0,0],[1,"bad"],[2,2]]}')).is_null()


func test_part_id_and_transform_round_trip_through_json_without_a_scene_tree() -> void:
	var transform := Transform3D(Basis(Vector3.RIGHT, Vector3(0, 2, 0), Vector3(0, 0, 3)), Vector3(4, 5, 6))
	var part = PartData.new("wheel-1", transform)
	var restored = PartData.from_json(part.to_json())
	assert_object(restored).is_not_null()
	assert_str(restored.id).is_equal("wheel-1")
	assert_bool(restored.transform.is_equal_approx(transform)).is_true()


func test_invalid_part_json_is_rejected() -> void:
	assert_object(PartData.from_json("not json")).is_null()
	assert_object(PartData.from_json('{"version":1,"id":"  ","transform":[0,0,0,1,0,0,0,1,0,0,0,1]}')).is_null()
	assert_object(PartData.from_json('{"version":1,"id":"wheel-1","transform":[0,0,0,1,0,0,0,1,0,0,0,"bad"]}')).is_null()
