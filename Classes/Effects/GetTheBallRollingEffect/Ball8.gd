extends StaticBody3D
class_name Ball8

@export var initialForce : float = 100
## Aceleración negativa en m/s²
@export var friction : float = 10
@export var timeBetweenBounces := .05

var direction := Vector3(-1, 0, 0)
var movingSpeed := 0.0

var moving := false
var trajectory : Array[Ball8TrajectoryCalculator.BallTrajectoryPoint] = []

func _physics_process(delta):
	if moving:
		$Bola8.rotation += direction.rotated(Vector3.UP, PI/2) * delta * movingSpeed * 2

func push():
	if trajectory.is_empty():
		await $TrajectoryCalculator.trajectoryCalculated
	
	var tween := create_tween()
	for i in range(trajectory.size()):
		var point := trajectory[i]
		var initialPosition := global_position
		var initialSpeed := initialForce
		if i > 0:
			initialSpeed = trajectory[i-1].nextSpeed
			initialPosition = trajectory[i-1].position
		var movementDir := initialPosition.direction_to(point.position)
		
		# Dada una aceleración constante de -friction, cuánto tiempo es necesario
		# para llegar a una velocidad de point.nextSpeed
		var transitionTime : float = (initialSpeed - point.nextSpeed) / (friction)
		
		# Pre movimiento
		tween.tween_callback(func ():
			moving = true)
		
		# Movimiento
		tween.tween_method(_setPosition.bind(initialPosition, movementDir, initialSpeed, -friction),
			0.0, transitionTime, transitionTime)
		
		# Post movimiento
		tween.tween_callback(func (): 
			direction = point.nextDirection
			moving = false)
		
		tween.tween_interval(timeBetweenBounces)
	
	tween.tween_callback(startPushAnimation)

# MRUV
func _setPosition(t : float, initialPosition : Vector3, dir : Vector3, initialSpeed : float, acceleration : float):
	global_position = initialPosition + dir * t * (initialSpeed + acceleration * .5 * t)
	movingSpeed = initialSpeed + acceleration * t

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
	
	$PoolStickAnimation.stop()
	$PoolStickAnimation.play("Push")
	
	trajectory = []
	$TrajectoryCalculator.startCalculating(direction, initialForce, friction)

func setTrajectory(points : Array[Ball8TrajectoryCalculator.BallTrajectoryPoint]):
	trajectory = points
	
	# Telegraphing
	
	$TelegraphTrail.visible = true
	$TelegraphTrail.restart()
	var tween := create_tween()
	for p in points:
		tween.tween_callback(func ():
			var dir = $TelegraphTrail.to_local(p.position).normalized()
			$TelegraphTrail.look_at(dir)
			$TelegraphTrail.rotation.x -= PI/2
		)
		tween.tween_property($TelegraphTrail, "global_position", p.position, .1)
		tween.tween_interval(.05)
	tween.tween_interval(.5)
	tween.tween_callback(func (): 
		$TelegraphTrail.position = Vector3.ZERO
		$TelegraphTrail.visible = false
	)

func _on_hit_area_body_entered(body):
	if not moving:
		return
	
	if body is Monigote:
		body.hurt()
