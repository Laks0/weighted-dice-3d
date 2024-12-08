extends Pushable
class_name Monigote

signal wasHurt
signal died
## Se emite cuando el monigote agarra cualquier pushable
signal grab(body)
signal hasWon

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var MOVEMENTS_TO_ESCAPE_GRAB : int = 20
var escapeMovements : int = 0

var _movementDir : Vector2

@export var aiControllerScript : Script

var player : PlayerHandler.Player = PlayerHandler.Player.new("Juan")
@onready var controller : int = player.inputController
@onready var actions    : Dictionary = Controllers.getActions(controller)

var moveVelocity      := Vector2.ZERO
var unclampedVelocity := Vector2.ZERO

var stunned := false
var health : int = 2

var invincible  := false

@export var invincibleAfterHurtTime: float = 3.0
@export var invincibleAfterPushTime: float = 0.2

var stageHandler : StageHandler

var drunk := false

func _ready():
	$HurtTime.timeout.connect(func(): invincible = false)
	
	stageHandler = get_parent().get_node_or_null("StageHandler")
	
	if player.inputController == Controllers.AI:
		var controllerNode := Node.new()
		controllerNode.set_script(aiControllerScript)
		add_child(controllerNode)
	
	super._ready()

## Se llama desde la arena cuando el monigote es reparentado
func arenaReady():
	$AnimatedSprite.arenaReady()

func _process(_delta):
	if Input.is_action_just_pressed(actions.grab):
		if grabbed:
			attemptEscape()
		else:
			$Grabbing.attemptGrab()
	
	if grabbing and Input.is_action_just_released(actions.grab):
		push()
	
	# DEBUG
	if Input.is_action_just_pressed("die"):
		$AnimatedSprite/Hands.go_to_ready_position(.5)
		await get_tree().create_timer(.6).timeout
		$AnimatedSprite/Hands.go_to_rest(.5)
	
	if stageHandler.currentStage != StageHandler.Stages.ARENA:
		return
		
	position.y = Globals.SPRITE_HEIGHT

func _physics_process(delta):
	if player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(controller)
	
	if drunk:
		_movementDir = _movementDir.rotated(PI)
	
	var accFactor := 1.0
	if grabbing:
		accFactor = grabBody.grabSpeedFactor
		onGrabbing()
	
	if stunned:
		accFactor = 0
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * accFactor)
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity
	
	velocity = Vector3(vel2d.x, -40*delta, vel2d.y)
	
	move_and_slide()

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	velocity = Vector3.ZERO

func attemptEscape():
	$AnimatedSprite.shake()
	escapeMovements += 1
	Input.start_joy_vibration(controller, .3, 0, .2)
	
	if escapeMovements >= MOVEMENTS_TO_ESCAPE_GRAB:
		$Grabbing/GrabCooldown.start()
		escaped.emit()
		Input.start_joy_vibration(controller, 1, 0, .1)

func onGrabbingEscaped(body : Pushable):
	var bodyPos2d = Vector2(body.position.x, body.position.z)
	var pos2d = Vector2(position.x, position.z)
	knockback(bodyPos2d.direction_to(pos2d) * 14)
	Input.start_joy_vibration(controller, 1, 0, .25)

func onPushed(dir : Vector2, factor : float, _pusher : Pushable):
	unclampedVelocity += dir * factor * maxPushForce
	$Grabbing/GrabCooldown.start()
	invincible = false
	
	super(dir, factor, _pusher)

func push():
	moveVelocity = Vector2.ZERO
	knockback(-grabDir * pow(pushFactor, 2) * 11)
	Input.start_joy_vibration(controller, pushFactor, 0, .1)
	super()

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	unclampedVelocity = unclampedVelocity.bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	velocity = velocity.bounce(normal)

func knockback(vel : Vector2):
	unclampedVelocity = vel

func knockbackFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	knockback(pos2d.direction_to(selfPos2d) * force)

func hurt() -> bool:
	if invincible or DebugVars.inmortalMonigotes:
		return false
	
	health -= 1
	
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

func stun():
	if !$StunCooldown.is_stopped():
		return
	
	$StunCooldown.start()
	stunned = true

func makeInvincible():
	invincible = true
	$HurtTime.start()

## Detiene todo movimiento e interrumpe los controles, se usa en las transiciones de estado
func freeze():
	set_process(false)
	set_physics_process(false)
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	
	push()
	if grabbed:
		escaped.emit()

func unfreeze():
	set_process(true)
	set_physics_process(true)

func _on_stun_cooldown_timeout():
	stunned = false

func dance():
	$AnimatedSprite.dance()

#####################
# FUNCIONES CEDIDAS #
#####################
## Funciones de la clase que se le cede el funcionamiento a otro script

func onGrabbing():
	$Grabbing.onGrabbing()
	super.onGrabbing()

func canBeGrabbed(grabber) -> bool:
	return super(grabber) and $Grabbing.canBeGrabbed

func canGrab() -> bool:
	return $Grabbing.canGrab()

func onGrabbed():
	$Grabbing.onGrabbed()
	super()
