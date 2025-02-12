extends StaticBody3D
class_name Ball8

@export var initialVelocity : float = 100
@export var friction        : float = .1
var direction := Vector3(-1, 0, 0)
var velocity  := Vector3.ZERO
var freeToMove := false

func _physics_process(delta):
	$Bola8.rotation += direction.rotated(Vector3.UP, PI/2) * delta * velocity.abs()
	velocity = velocity.lerp(Vector3.ZERO, friction)
	position += velocity * delta
	
	if velocity.is_zero_approx() and not $PoolStickAnimation.is_playing() and freeToMove:
		startPushAnimation()
	
	if velocity.is_zero_approx():
		return
	
	$BounceCast.target_position = direction * 2
	
	if $BounceCast.is_colliding() and $BounceCast.get_collider().is_in_group("Walls"):
		var normal = $BounceCast.get_collision_normal()
		$BounceCast.enabled = false
		bounceDirectionByNormal(normal)
		
		await get_tree().physics_frame
		$BounceCast.enabled = true

func push():
	velocity = direction.normalized() * initialVelocity

func startPushAnimation():
	var newAngle := randf() * 2 * PI
	var direction2d := Vector2.from_angle(newAngle)
	direction = Vector3(direction2d.x, 0, -direction2d.y)
	
	$PoolStick.global_position = global_position
	# Esto es por cómo posicioné el palo en la animación, ahora es más fácil 
	# cambiarlo desde acá que cambiar la animación
	# Si hay que rehacer la animación del palo (probablemente) habría que ponerlo
	# en dirección positiva en la x y sacar esta resta
	$PoolStick.rotation.y = newAngle - PI/2
	
	$PoolStickAnimation.play("Push")
	$BounceCast.target_position =  direction * 2

func bounceDirectionByNormal(normal : Vector3):
	direction = direction.bounce(normal)
	velocity = velocity.bounce(normal)

func _on_hit_area_body_entered(body):
	if velocity.is_zero_approx():
		return
	
	if body is Monigote:
		body.hurt()
