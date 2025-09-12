extends DieBehaviour

@export var maxBursts : int = 5
var burstCounter : int

@export var burstForce : float = 200

## Vueltas por segundo
@export var maxRotationSpeed : float = 30
var rotationSpeedFactor : float
@export var preparationTime : float = 1.2

var shootDirection : Vector3

func _onStart():
	burstCounter = 0

func _onActiveProcess(_delta):
	if die.freeze or not $AfterBurstTime.is_stopped():
		return
	
	var linearAbs := die.linear_velocity.abs()
	# is_zero_approx no funciona porque el epsilon tiene que ser muy grande
	var epsilon : float = .1
	if linearAbs.x > epsilon or linearAbs.y > epsilon or linearAbs.z > epsilon:
		return
	
	if burstCounter < maxBursts:
		burstCounter += 1
		_burst()
	else:
		stop()

func _burst():
	rotationSpeedFactor = 0
	
	var dir2d := die._getRandomMonigoteDirection()
	shootDirection = Vector3(dir2d.x, 0, dir2d.y)
	var preTravel := Vector3(0,.2,0) - shootDirection
	
	die.freeze = true
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_interval(.1)
	tween.tween_property(die, "transform",
		die.transform.looking_at(die.global_position + shootDirection).translated(preTravel),
		preparationTime/4)
	tween.tween_method(func (t : float):
		die.rotate_object_local(Vector3.LEFT,maxRotationSpeed*t*get_physics_process_delta_time()),
	.1, 1, 3*preparationTime/4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(.12)
	
	tween.tween_callback($AfterBurstTime.start)
	
	await tween.finished
	
	die.freeze = false
	die.throw(shootDirection * burstForce)
