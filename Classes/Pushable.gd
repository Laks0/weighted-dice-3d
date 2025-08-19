extends CharacterBody3D
class_name Pushable

## Se emite cuando se escapa de un grab
@warning_ignore("unused_signal")
signal escaped
@warning_ignore("unused_signal")
signal attemptedEscape
signal beenGrabbed
signal grabbedBody(body : Pushable)
signal wasPushed(dir : Vector2, factor : float, _pusher : Pushable)
signal pushed
## Se llama cuando quien lo está agarrando es agarrado
signal doubled
signal grabbingBodyEscaped(body : Pushable)

@export_range(0, 3) var maxGrabTime  : float = 1
@export             var grabDistance : float = .3

## La fuerza máxima a la que _es empujado_
@export var maxPushForce : float = 20
## El factor de la fuerza máxima que se usa cuando el objeto agarrado se escapa
@export var failedPushFactor : float = .3

@export var customMovement    : bool = false
@export var affectedByGravity : bool = false

## El factor de la velocidad de un monigote cuando está agarrando el objeto
@export var grabSpeedFactor : float = .08

@export var FRICTION : float = 40

var grabbing        := false
var grabbed         := false
var grabDir         := Vector2.RIGHT
var dirBeingGrabbed := Vector2.RIGHT
var grabBody        : Pushable
var pushFactor      : float = 0

var color := Color.WHITE
## La fuerza con la que está siendo agarrado (de 0 a 1)
var forceBeingGrabbed := .0
## La fuerza con la que está agarrando (de 0 a 1)
var forceGrabbing     := .0

var timer : Timer = Timer.new() # Timer para el grab

var _grabbingPausedFrames     : int = 0
var _beingGrabbedPausedFrames : int = 0
## La cantidad de frames que se pausa el agarre cuando se llama a pauseGrabbing o pauseBeingGrabbed
const _PAUSE_FRAMES           : int = 5

func _ready():
	timer.one_shot = true
	add_child(timer)

## Pausa por una cantidad corta de frames la capacidad de ser agarrado
func pauseBeingGrabbed():
	_beingGrabbedPausedFrames = _PAUSE_FRAMES

## Pausa por una cantidad corta de frames la capacidad de agarrar
func pauseGrabbing():
	_grabbingPausedFrames = _PAUSE_FRAMES

func stopGrabbing():
	_grabbingPausedFrames = 9223372036854775800

func resumeGrabbing():
	_grabbingPausedFrames = 0

func canBeGrabbed(_grabber) -> bool:
	return _beingGrabbedPausedFrames <= 0 and not grabbed

func canGrab() -> bool:
	return _grabbingPausedFrames <= 0 and not (grabbed or grabbing)

func onGrabbed():
	grabbed = true
	beenGrabbed.emit()
	
	if is_instance_valid(grabBody) and grabbing:
		grabBody.doubled.emit()

func onPushed(dir : Vector2, factor : float, _pusher : Pushable):
	wasPushed.emit(dir, factor, _pusher)
	grabbed = false
	color = Color.WHITE
	
	# Permite volver a colisionar con el que lo agarró
	# IMPORTANTE: esto significa que los pushables no pueden tener excepciones
	# de colisión
	get_tree().create_timer(.1).timeout.connect(func ():
		if not is_instance_valid(self):
			return
		for e in get_collision_exceptions():
			remove_collision_exception_with(e)
	)
	
	if customMovement:
		return
	
	velocity += Vector3(dir.x, 0, dir.y) * factor * maxPushForce

## Devuelve si el grab fue exitoso o no
func startGrab(body : Pushable) -> bool:
	if not canGrab():
		return false
	if not body.canBeGrabbed(self):
		return false
	if body == self:
		return false
	
	grabbing = true
	grabbedBody.emit(body)
	
	timer.start(maxGrabTime)
	
	grabBody = body
	body.onGrabbed()

	# En caso de que se escape
	body.connect("escaped", func ():
		if not body.grabbed:
			return
		onGrabbingEscaped(body)
		grabbingBodyEscaped.emit(body)
		pushFactor = failedPushFactor
		push())

	return true

func onGrabbingEscaped(_body : Pushable) -> void:
	pass

func push():
	if not grabbing:
		return
	
	grabbing = false
	timer.stop()
	
	if not is_instance_valid(grabBody):
		return
	
	grabBody.onPushed(grabDir, pushFactor, self)
	grabBody = null
	pushed.emit()

func _physics_process(delta):
	if grabbed:
		return
	
	if affectedByGravity:
		velocity.y -= 20 * delta
	
	if customMovement:
		return
	
	# La velocidad vertical no se interpola a 0
	var y_vel = velocity.y
	# Solo interpolar x y z
	velocity = (velocity*Vector3(1,0,1)).move_toward(Vector3.ZERO, FRICTION * delta)
	# Volver al valor inicial de y
	velocity.y = y_vel
	move_and_slide()

func _process(_delta):
	_beingGrabbedPausedFrames = max(0, _beingGrabbedPausedFrames - 1)
	_grabbingPausedFrames = max(0, _grabbingPausedFrames - 1)

func onGrabbing():
	if not is_instance_valid(grabBody):
		return
	
	# Determina la fuerza dependiendo del tiempo
	var t = (grabBody.maxGrabTime - timer.time_left) / grabBody.maxGrabTime # Para que vaya del 0 al 1
	grabBody.forceBeingGrabbed = t
	forceGrabbing = t
	grabBody.dirBeingGrabbed = grabDir
	
	var minFactor := .4
	var offset := .4
	pushFactor = (pow((t+offset), 3) * ((1-minFactor)/pow(1+offset,3)) + minFactor)
	
	# Prohibe al cuerpo colisionar con el que lo agarra
	grabBody.add_collision_exception_with(self)

func bounce(normal : Vector3) -> void:
	if customMovement:
		return
	
	velocity = velocity.bounce(normal)
