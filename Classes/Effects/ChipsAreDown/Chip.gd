extends RigidBody3D

const PUSH_SPEED : int = 10

func _on_body_entered(body):
	if $DeadTime.is_stopped():
		$DeadTime.start()
	
	if body is Monigote:
		body.hurt()
		
		var direction = position.direction_to(body.position)
		var dir2d := Vector2(direction.x, direction.z).normalized()
		body.knockback(dir2d * PUSH_SPEED)

func _on_dead_time_timeout():
	queue_free()
