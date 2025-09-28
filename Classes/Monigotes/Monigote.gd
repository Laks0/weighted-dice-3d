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

@export var MOVEMENTS_TO_ESCAPE_GRAB : int = 20
@export var STUN_TIME_AFTER_ESCAPE : float = .5
var escapeMovements : int = 0

@export var aiControllerScript : Script

var player : PlayerHandler.Player = PlayerHandler.Player.new("Juan")
@onready var controller : int = player.inputController
@onready var actions    : Dictionary = Controllers.getActions(controller)

var movementStopped := false
var gravityStopped := false
var health : int = 2

var invincible  := false

@export var invincibleAfterHurtTime: float = 3.0
@export var invincibleAfterPushTime: float = 0.2

var stageHandler : StageHandler

var drunk := false

@onready var movement : MonigoteMovement = $Moving
@onready var jumping : MonigoteJumping = $Jumping
@onready var animatedSprite : MonigoteSprite = %AnimatedSprite

func _ready():
	$HurtTime.timeout.connect(func(): invincible = false)
	
	if get_tree().get_nodes_in_group("StageHandler").size() > 0:
		stageHandler = get_tree().get_nodes_in_group("StageHandler")[0]
	
	if player.inputController == Controllers.AI:
		var controllerNode := Node.new()
		controllerNode.set_script(aiControllerScript)
		add_child(controllerNode)

func _physics_process(_delta):
	if movement.stunned:
		pauseGrabbing()

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
	movement.applyVelocity(bodyPos2d.direction_to(pos2d) * 14)
	Input.start_joy_vibration(controller, 1, 0, .25)
	movement.stun(STUN_TIME_AFTER_ESCAPE)

func onPushed(dir : Vector2, factor : float, _pusher : Pushable):
	movement.resetMovement()
	movement.applyVelocity(dir * factor * maxPushForce)
	$Grabbing/GrabCooldown.start()
	invincible = false
	
	super(dir, factor, _pusher)

func push():
	movement.applyVelocity(-grabDir * pow(pushFactor, 2) * 11)
	Input.start_joy_vibration(controller, pushFactor, 0, .1)
	$Grabbing.onPushed()
	super()

func applyVelocityFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	movement.applyVelocity(pos2d.direction_to(selfPos2d) * force)

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
	movement.resetMovement()
	stopMovement()
	set_process(false)
	set_physics_process(false)
	movement.set_physics_process(false)
	
	push()
	if grabbed:
		escaped.emit()

func unfreeze():
	resumeMovement()
	set_process(true)
	set_physics_process(true)
	movement.set_physics_process(true)

func dance():
	$AnimatedSprite.dance()

func bounce(normal : Vector3):
	movement.bounce(normal)
