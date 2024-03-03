extends RigidBody3D
class_name Die

signal rolled(n)
## Se llama cuando el dado se subió al cubilete
signal onCubilete
## Se llama cuando el cubilete suelta el dado
signal dropped

var prepareArrow : AnimatedSprite3D

@export var rotations : Array[Vector3]

## La velocidad mínima que necesita el dado para poder herir a un monigote
@export var minMovementToHurt : float = .1
## El tiempo que espera después de rollear para atacar
@export var timeAfterRoll : float = 1.4

func throw(impulse : Vector3):
	apply_central_impulse(impulse)
	var torque := Vector3(randf(), randf(), randf()).normalized()
	apply_torque_impulse(torque * 10)

func onFloor() -> bool:
	for body in get_colliding_bodies():
		if body.is_in_group("Table"):
			return true
	return false

func disableCollision():
	$Area3D.monitoring = false
	$CollisionShape3D.disabled = true

func enableCollision():
	$Area3D.monitoring = true
	$CollisionShape3D.disabled = false

func _ready():
	disableCollision()
	visible = false

func _process(_delta):
	if prepareArrow.visible:
		prepareArrow.position = position

func _getRandomMonigoteDirection() -> Vector2:
	var monigote : Monigote = get_parent().getRandomMonigote()
	var dir3d : Vector3 = position.direction_to(monigote.position)
	
	return Vector2(dir3d.x, dir3d.z)

func _getClosestMonigoteDirection() -> Vector2:
	var closestMonigotePos = get_parent().getClosestMonigote(position).position
	var dir3d = position.direction_to(closestMonigotePos)
	return Vector2(dir3d.x, dir3d.z)

func _on_area_3d_body_entered(body):
	if linear_velocity.length() < minMovementToHurt:
		return
	
	if body is Monigote:
		body.hurt()
		body.knockback(Vector2(linear_velocity.x, linear_velocity.z) * 2)
