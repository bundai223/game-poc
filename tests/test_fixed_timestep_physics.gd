extends GdUnitTestSuite

var _physics_ticks_per_second: int


func before_test() -> void:
	_physics_ticks_per_second = Engine.physics_ticks_per_second
	Engine.physics_ticks_per_second = 60


func after_test() -> void:
	Engine.physics_ticks_per_second = _physics_ticks_per_second


func test_falling_body_moves_within_tolerance_after_half_second() -> void:
	var body := RigidBody2D.new()
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	collider.shape = circle
	body.add_child(collider)
	add_child(body)

	for _frame in 30:
		await get_tree().physics_frame

	assert_bool(body.position.y > 100.0 and body.position.y < 160.0).is_true()
