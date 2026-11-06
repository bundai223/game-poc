extends GdUnitTestSuite


func test_circle_collider_is_attached_to_body() -> void:
	var body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	collider.shape = circle
	body.add_child(collider)
	add_child(body)

	assert_bool(collider.get_parent() == body).is_true()
	assert_float((collider.shape as CircleShape2D).radius).is_equal_approx(12.0, 0.001)
