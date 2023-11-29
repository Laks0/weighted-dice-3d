extends RigidBody3D
class_name Die

signal rolled(n)

var prepareArrow : AnimatedSprite3D

@export var rotations : Array[Vector3]

func throw(impulse : Vector3):
	apply_central_impulse(impulse)
	var torque := Vector3(randf(), randf(), randf()).normalized()
	apply_torque_impulse(torque * 10)

func onFloor() -> bool:
	for body in get_colliding_bodies():
		if body.is_in_group("Table"):
			return true
	return false

func _process(_delta):
	if prepareArrow.visible:
		prepareArrow.position = position

func _getRandomMonigoteDirection() -> Vector2:
	var monigote : Monigote = get_parent().getRandomMonigote()
	var dir3d : Vector3 = position.direction_to(monigote.position)
	
	return Vector2(dir3d.x, dir3d.z)

func _on_area_3d_body_entered(body):
	if body is Monigote:
		body.hurt()
		body.knockback(Vector2(linear_velocity.x, linear_velocity.z) * 2)
