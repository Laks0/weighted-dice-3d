extends Pushable
class_name Monigote

signal wasHurt
@warning_ignore("unused_signal")
signal died
## Se emite cuando el monigote agarra cualquier pushable
@warning_ignore("unused_signal")
signal grab(body)
@warning_ignore("unused_signal")
signal hasWon
signal wasStunned
signal wasUnstunned

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var GRAVITY_ACCELERATION     : float = 50
@export var MOVEMENTS_TO_ESCAPE_GRAB : int = 20
@export var STUN_TIME_AFTER_ESCAPE : float = .5
var escapeMovements : int = 0

var _movementDir : Vector2

@export var aiControllerScript : Script

var player : PlayerHandler.Player = PlayerHandler.Player.new("Juan")
@onready var controller : int = player.inputController
@onready var actions    : Dictionary = Controllers.getActions(controller)

var moveVelocity      := Vector2.ZERO
var unclampedVelocity := Vector2.ZERO

var stunned := false
var movementStopped := false
var health : int = 2

var invincible  := false

@export var invincibleAfterHurtTime: float = 3.0
@export var invincibleAfterPushTime: float = 0.2

var stageHandler : StageHandler

var drunk := false

func _ready():
	$HurtTime.timeout.connect(func(): invincible = false)
	
	if get_tree().get_nodes_in_group("StageHandler").size() > 0:
		stageHandler = get_tree().get_nodes_in_group("StageHandler")[0]
	
	if player.inputController == Controllers.AI:
		var controllerNode := Node.new()
		controllerNode.set_script(aiControllerScript)
		add_child(controllerNode)
	
	super._ready()

## Se llama desde la arena cuando el monigote es reparentado
func arenaReady():
	$AnimatedSprite.arenaReady()

func _process(delta):
	if Input.is_action_just_pressed(actions.grab):
		if grabbed:
			attemptEscape()
		else:
			$Grabbing.attemptGrab()
	
	if grabbing and Input.is_action_just_released(actions.grab):
		push()
	
	super(delta)

func _physics_process(delta):
	if player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(controller)
	
	if drunk:
		_movementDir = _movementDir.rotated(PI)
	
	var accFactor := 1.0
	if grabbing and is_instance_valid(grabBody):
		accFactor = grabBody.grabSpeedFactor
		onGrabbing()
	
	if stunned or movementStopped:
		accFactor = 0
	
	if stunned:
		pauseGrabbing()
	
	if grabbed:
		return
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * accFactor)
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity

	velocity = Vector3(vel2d.x, velocity.y - (GRAVITY_ACCELERATION * delta), vel2d.y)
	
	move_and_slide()

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	velocity = Vector3.ZERO

func goMaxSpeed(dir : Vector2) -> void:
	var vel2d := dir.normalized() * MAX_SPEED
	velocity.x = vel2d.x
	velocity.z = vel2d.y

func attemptEscape():
	escapeMovements += 1
	attemptedEscape.emit()
	Input.start_joy_vibration(controller, .3, 0, .2)
	
	if escapeMovements >= MOVEMENTS_TO_ESCAPE_GRAB:
		$Grabbing/GrabCooldown.start()
		escaped.emit()
		Input.start_joy_vibration(controller, 1, 0, .1)

func onGrabbingEscaped(body : Pushable):
	var bodyPos2d = Vector2(body.position.x, body.position.z)
	var pos2d = Vector2(position.x, position.z)
	applyVelocity(bodyPos2d.direction_to(pos2d) * 14)
	Input.start_joy_vibration(controller, 1, 0, .25)
	stun(STUN_TIME_AFTER_ESCAPE)

func onPushed(dir : Vector2, factor : float, _pusher : Pushable):
	unclampedVelocity += dir * factor * maxPushForce
	$Grabbing/GrabCooldown.start()
	invincible = false
	
	super(dir, factor, _pusher)

func push():
	moveVelocity = Vector2.ZERO
	applyVelocity(-grabDir * pow(pushFactor, 2) * 11)
	Input.start_joy_vibration(controller, pushFactor, 0, .1)
	$Grabbing.onPushed()
	super()

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	unclampedVelocity = unclampedVelocity.bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	velocity = velocity.bounce(normal)

## Establece una velocidad aplicada externamente, deteniendo otras velocidades establecidas que no sean internas al monigote
func applyVelocity(vel : Vector2):
	unclampedVelocity = vel

## Aplica una velocidad externa sin detener otras aplicadas antes
func applyForce(vel : Vector2):
	unclampedVelocity += vel

func applyVelocityFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	applyVelocity(pos2d.direction_to(selfPos2d) * force)

func accelerateUp(accel : float):
	velocity.y += accel

func hurt() -> bool:
	if invincible or Debug.vars.inmortalMonigotes:
		return false
	
	health -= 1
	$BloodTrail.emitting = true
	
	if health <= 0:
		die()
	else:
		wasHurt.emit()
		Input.start_joy_vibration(controller, .4, .4, .2)
	
	makeInvincible()
	
	return true

func die():
	if invincible:
		return
	
	if grabbing:
		push()
	
	emit_signal("died")
	
	%AnimatedSprite.visible = false
	$DeathParticles.emitting = true
	
	Input.start_joy_vibration(controller, 1, 1, .4)
	
	$DeathParticles.connect("finished", queue_free)

func stun(timeout := 5.0):
	stunned = true
	$StunTimeout.start(timeout)
	wasStunned.emit()

func unstun():
	stunned = false
	wasUnstunned.emit()

func stopMovement():
	movementStopped = true

## Similar a stun pero permite agarrar mientras está quieto, además no hace la señal
## ni la animación
func resumeMovement():
	movementStopped = false

func makeInvincible():
	invincible = true
	$HurtTime.start()

## Detiene todo movimiento e interrumpe los controles, se usa en las transiciones de estado
func freeze():
	stopMovement()
	set_process(false)
	set_physics_process(false)
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	
	push()
	if grabbed:
		escaped.emit()

func unfreeze():
	resumeMovement()
	set_process(true)
	set_physics_process(true)

func dance():
	$AnimatedSprite.dance()
