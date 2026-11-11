extends GdUnitTestSuite

const DrawPhysics = preload("res://experiments/draw_physics/main.tscn")
const Outline = preload("res://experiments/draw_physics/outline.gd")
const OutlineData = preload("res://experiments/draw_physics/outline_data.gd")

var _physics_ticks_per_second: int


func before_test() -> void:
	_physics_ticks_per_second = Engine.physics_ticks_per_second
	Engine.physics_ticks_per_second = 60


func after_test() -> void:
	Engine.physics_ticks_per_second = _physics_ticks_per_second


func test_outline_falls_and_stops_at_the_floor() -> void:
	var demo := DrawPhysics.instantiate()
	add_child(demo)
	var points := Outline.prepare(PackedVector2Array([Vector2(-30, -20), Vector2(30, -20), Vector2(0, 40)]))
	var body: RigidBody2D = demo.spawn_body(OutlineData.new(points))
	for _frame in 120:
		await get_tree().physics_frame
	assert_bool(body.position.y > demo._floor_y - 100.0 and body.position.y < demo._floor_y).is_true()
	assert_bool(absf(body.linear_velocity.y) < 10.0).is_true()
