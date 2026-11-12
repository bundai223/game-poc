extends RefCounted


static func create_editor_view(vehicle, selected_id: String = "") -> Node3D:
	var assembly := Node3D.new()
	assembly.name = "Assembly"
	for part in vehicle.parts:
		var body := StaticBody3D.new()
		body.name = "Part_%s" % part.id
		body.set_meta("part_id", part.id)
		body.transform = part.transform
		_add_part_visual(body, part.kind, part.id == selected_id)
		_add_part_collision(body, part.kind)
		assembly.add_child(body)
	_add_axles(assembly, vehicle)
	return assembly


static func create_runtime_vehicle(vehicle) -> Node3D:
	var assembly := Node3D.new()
	assembly.name = "Vehicle"
	var chassis := RigidBody3D.new()
	chassis.name = "Chassis"
	chassis.mass = maxf(1.0, float(vehicle.parts.size() - 2) * 2.0)
	assembly.add_child(chassis)
	for part in vehicle.parts:
		if part.kind == "block":
			var visual := MeshInstance3D.new()
			visual.transform = part.transform
			var box := BoxMesh.new()
			box.size = Vector3.ONE
			visual.mesh = box
			visual.material_override = _material(Color(0.2, 0.62, 0.92))
			chassis.add_child(visual)
			var collision := CollisionShape3D.new()
			collision.transform = part.transform
			var box_shape := BoxShape3D.new()
			box_shape.size = Vector3.ONE
			collision.shape = box_shape
			chassis.add_child(collision)
	_add_axles(chassis, vehicle)
	for part in vehicle.parts:
		if part.kind != "wheel":
			continue
		var wheel := RigidBody3D.new()
		wheel.name = "Wheel_%s" % part.id
		wheel.position = part.transform.origin
		wheel.mass = 0.5
		assembly.add_child(wheel)
		_add_part_visual(wheel, "wheel")
		_add_part_collision(wheel, "wheel")
		var hinge := HingeJoint3D.new()
		hinge.name = "Hinge_%s" % part.id
		hinge.position = part.transform.origin
		hinge.rotation.y = PI / 2.0
		hinge.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, false)
		hinge.set_param(HingeJoint3D.PARAM_MOTOR_MAX_IMPULSE, 2.0)
		hinge.set_meta("part_id", part.id)
		assembly.add_child(hinge)
		hinge.node_a = NodePath("../Chassis")
		hinge.node_b = NodePath("../%s" % wheel.name)
	return assembly


static func _add_axles(parent: Node3D, vehicle) -> void:
	for connection in vehicle.connections:
		if connection.kind != "hinge":
			continue
		var first = vehicle.find_part(connection.a)
		var second = vehicle.find_part(connection.b)
		var wheel = first if first.kind == "wheel" else second
		var block = first if first.kind == "block" else second
		var axle_length := absf(wheel.transform.origin.x - block.transform.origin.x) - 0.5
		if axle_length <= 0.0:
			continue
		var axle := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.055
		mesh.bottom_radius = 0.055
		mesh.height = axle_length
		axle.mesh = mesh
		axle.position = (wheel.transform.origin + block.transform.origin) / 2.0
		axle.rotation.z = PI / 2.0
		axle.material_override = _material(Color(0.72, 0.74, 0.76))
		parent.add_child(axle)


static func _add_part_visual(parent: Node3D, kind: String, selected: bool = false) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	if kind == "block":
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		visual.mesh = box
		visual.material_override = _material(Color(1.0, 0.64, 0.18) if selected else Color(0.2, 0.62, 0.92))
	else:
		var tire := CylinderMesh.new()
		tire.top_radius = 0.5
		tire.bottom_radius = 0.5
		tire.height = 0.28
		visual.mesh = tire
		visual.rotation.z = PI / 2.0
		visual.material_override = _material(Color(1.0, 0.64, 0.18) if selected else Color(0.12, 0.14, 0.17))
	parent.add_child(visual)


static func _add_part_collision(parent: Node3D, kind: String) -> void:
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	if kind == "block":
		var box := BoxShape3D.new()
		box.size = Vector3.ONE
		collision.shape = box
	else:
		var tire := CylinderShape3D.new()
		tire.radius = 0.5
		tire.height = 0.28
		collision.shape = tire
		collision.rotation.z = PI / 2.0
		var material := PhysicsMaterial.new()
		material.friction = 2.5
		material.bounce = 0.0
		parent.physics_material_override = material
	parent.add_child(collision)


static func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.8
	return result
