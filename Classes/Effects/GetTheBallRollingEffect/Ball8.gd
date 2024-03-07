extends CharacterBody3D
class_name Ball8

# metros/segundos
@export var speed := 7
var direction := Vector3(-1, 0, 0)

func _physics_process(delta):
	direction = direction.normalized()
	$WallRaycast.target_position = direction * 1.1
	if $WallRaycast.is_colliding() and $WallRaycast.get_collider().is_in_group("Walls"):
		direction *= -1
	
	$HitArea.position = direction
	
	velocity = direction * speed
	rotation += direction.rotated(Vector3.UP, PI/2) * delta * speed
	move_and_slide()

func _on_hit_area_body_entered(body):
	if body is Monigote:
		var grabDir3d = Vector3(body.grabDir.x, 0, body.grabDir.y)
		var monPosition = body.position
		if body.grabbing and body.grabBody is PoolStick\
				and grabDir3d.dot(monPosition.direction_to(position)) > 0:
			return
		body.hurt()
