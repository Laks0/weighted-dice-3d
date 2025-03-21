extends Node3D

@onready var mon : Monigote = get_parent()
@export var verticalInitialSpeed   : float = 5.5
@export var horizontalInitialSpeed : float = 15
@export var verticalAcceleration   : float = 22
@export var horizontalAcceleration : float = 40
@export var airFriction            : float = 50
var floorFriction : float

var jumping := false
## Marca si se sigue apretando el botón para saltar más
var stillAccelerating := false

var jumpDirection : Vector2

func _process(delta):
	if jumping:
		mon.pauseBeingGrabbed()
	if stillAccelerating:
		mon.pauseGrabbing()
	
	if not jumping and Input.is_action_just_pressed(mon.actions.jump):
		jump()
	
	if stillAccelerating and Input.is_action_just_released(mon.actions.jump):
		stillAccelerating = false
	
	if jumping and stillAccelerating:
		mon.accelerateUp(verticalAcceleration * delta)
		mon.applyForce(jumpDirection * horizontalAcceleration * delta)
	
	if jumping and Input.is_action_just_pressed(mon.actions.grab):
		$GrabBuffer.start()
	
	if jumping and mon.grabbing and mon.velocity.y < 0:
		mon.push()

func jump():
	if jumping or not $JumpCooldown.is_stopped():
		return
	if mon.grabbed:
		return
	
	mon.stun(false)
	mon.accelerateUp(verticalInitialSpeed)
	jumpDirection = Controllers.getDirection(mon.controller)
	mon.applyVelocity(jumpDirection * horizontalInitialSpeed)
	jumping = true
	stillAccelerating = true
	
	# Mientras un monigote está saltando no puede colisionar con otros monigotes
	mon.set_collision_mask_value(1, false)
	floorFriction = mon.FRICTION
	mon.FRICTION = airFriction

func stopJump():
	jumping = false
	$JumpCooldown.start()
	mon.unstun(false)
	mon.goMaxSpeed(Controllers.getDirection(mon.controller))
	
	mon.set_collision_mask_value(1, true)
	mon.FRICTION = floorFriction

func onFloorCollision(body):
	if not jumping:
		return
	
	if body is Monigote and mon.velocity.y > 0:
		return
	
	if body is Monigote:
		body.applyVelocity(Vector2.DOWN * 8)
		mon.applyVelocity(Vector2.UP * 8)
	
	stopJump()
