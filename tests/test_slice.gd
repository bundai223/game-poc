extends GdUnitTestSuite

const Slice = preload("res://experiments/draw_physics/slice.gd")


func test_straight_and_bent_cuts_split_square() -> void:
	var square := PackedVector2Array([Vector2(0, 0), Vector2(200, 0), Vector2(200, 200), Vector2(0, 200)])
	var straight := PackedVector2Array([Vector2(-20, 100), Vector2(220, 100)])
	var bent := PackedVector2Array([Vector2(-20, 60), Vector2(100, 100), Vector2(220, 140)])
	assert_int(Slice.split(square, straight).size()).is_equal(2)
	assert_int(Slice.split(square, bent).size()).is_equal(2)
	assert_int(Slice.split(square, PackedVector2Array([Vector2(-20, 50), Vector2(50, 50)])).size()).is_equal(1)


func test_concave_cut_can_make_three_pieces() -> void:
	var shape := PackedVector2Array([Vector2(0, 0), Vector2(200, 0), Vector2(200, 200), Vector2(150, 200), Vector2(150, 50), Vector2(50, 50), Vector2(50, 200), Vector2(0, 200)])
	assert_int(Slice.split(shape, PackedVector2Array([Vector2(-20, 100), Vector2(220, 100)])).size()).is_equal(3)


func test_small_piece_keeps_original_shape() -> void:
	var square := PackedVector2Array([Vector2(0, 0), Vector2(200, 0), Vector2(200, 200), Vector2(0, 200)])
	var pieces := Slice.split(square, PackedVector2Array([Vector2(-10, 1), Vector2(210, 1)]))
	assert_int(pieces.size()).is_equal(1)
	assert_bool(pieces[0] == square).is_true()


func test_self_crossing_cut_leaves_shape_unchanged() -> void:
	var square := PackedVector2Array([Vector2(0, 0), Vector2(200, 0), Vector2(200, 200), Vector2(0, 200)])
	var stroke := PackedVector2Array([Vector2(-10, 50), Vector2(210, 150), Vector2(-10, 150), Vector2(210, 50)])
	assert_int(Slice.split(square, stroke).size()).is_equal(1)
