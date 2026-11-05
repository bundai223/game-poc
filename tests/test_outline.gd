extends GdUnitTestSuite

const Outline = preload("res://experiments/draw_physics/outline.gd")


func test_valid_triangle_is_preserved() -> void:
	var points := PackedVector2Array([Vector2(100, 100), Vector2(200, 100), Vector2(150, 200)])
	assert_int(Outline.prepare(points).size()).is_equal(3)


func test_small_or_self_intersecting_outlines_are_rejected() -> void:
	assert_int(Outline.prepare(PackedVector2Array([Vector2(0, 0), Vector2(1, 1)])).size()).is_zero()
	var bow := PackedVector2Array([Vector2(0, 0), Vector2(100, 100), Vector2(0, 100), Vector2(100, 0)])
	assert_int(Outline.prepare(bow).size()).is_zero()
