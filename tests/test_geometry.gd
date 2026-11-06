extends GdUnitTestSuite


func test_triangle_area() -> void:
	var points := PackedVector2Array([Vector2(0, 0), Vector2(4, 0), Vector2(0, 3)])
	var area := absf((points[1] - points[0]).cross(points[2] - points[0])) / 2.0
	assert_float(area).is_equal_approx(6.0, 0.001)
