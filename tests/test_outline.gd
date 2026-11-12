extends GdUnitTestSuite

const Outline = preload("res://experiments/draw_physics/outline.gd")


func test_valid_triangle_is_preserved() -> void:
	var points := PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])
	assert_int(Outline.prepare(points).size()).is_equal(3)


func test_small_outline_is_rejected() -> void:
	assert_int(Outline.prepare(PackedVector2Array([Vector2(0, 0), Vector2(1, 1)])).size()).is_zero()


func test_self_crossing_outlines_are_rejected() -> void:
	var bow := PackedVector2Array([Vector2(0, 0), Vector2(100, 100), Vector2(0, 100), Vector2(100, 0)])
	var star := PackedVector2Array([Vector2(0, 0), Vector2(100, 200), Vector2(200, 0), Vector2(0, 125), Vector2(200, 125)])
	assert_int(Outline.prepare(bow).size()).is_zero()
	assert_int(Outline.prepare(star).size()).is_zero()


func test_simple_concave_outline_is_accepted() -> void:
	var concave := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(50, 25), Vector2(100, 100), Vector2(0, 100)])
	assert_int(Outline.prepare(concave).size()).is_equal(5)


func test_non_finite_points_and_touching_edges_are_rejected() -> void:
	var non_finite := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(INF, 50), Vector2(0, 100)])
	var touching := PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(50, 0), Vector2(0, 100)])
	assert_int(Outline.prepare(non_finite).size()).is_zero()
	assert_int(Outline.prepare(touching).size()).is_zero()


func test_near_collinear_points_are_simplified() -> void:
	var points := PackedVector2Array([Vector2(0, 0), Vector2(50, 0.5), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)])
	assert_int(Outline.prepare(points).size()).is_equal(4)
