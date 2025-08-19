extends RigidBody3D

const PUSH_SPEED : int = 10

func _on_body_entered(body):
	if body.is_in_group("Table") and $DeadTime.is_stopped():
		freeze = true
		$DeadTime.start()
	
	if body is Monigote and not linear_velocity.is_zero_approx():
		body.hurt()
		
		var direction = position.direction_to(body.position)
		var dir2d := Vector2(direction.x, direction.z).normalized()
		body.movement.applyVelocity(dir2d * PUSH_SPEED)

func _on_dead_time_timeout():
	queue_free()
