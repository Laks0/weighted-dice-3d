extends Node3D

@onready var mon : Monigote = get_parent()
@export var verticalInitialSpeed   : float = 5.5
@export var horizontalInitialSpeed : float = 15
@export var verticalAcceleration   : float = 20
@export var horizontalAcceleration : float = 40

var jumping := false
## Marca si se sigue apretando el botón para saltar más
var stillAccelerating := false

var jumpDirection : Vector2

func _process(delta):
	if not jumping and Input.is_action_just_pressed(mon.actions.jump):
		jump()
	
	if stillAccelerating and Input.is_action_just_released(mon.actions.jump):
		stillAccelerating = false
	
	if jumping and stillAccelerating:
		mon.accelerateUp(verticalAcceleration * delta)
		mon.unclampedAccelerate(jumpDirection * horizontalAcceleration * delta)
	
	if jumping and Input.is_action_just_pressed(mon.actions.grab):
		$GrabBuffer.start()

func jump():
	if jumping or not $JumpCooldown.is_stopped():
		return
	
	mon.untimed_stun()
	mon.accelerateUp(verticalInitialSpeed)
	jumpDirection = Controllers.getDirection(mon.controller)
	mon.knockback(jumpDirection * horizontalInitialSpeed)
	jumping = true
	stillAccelerating = true

func onFloorCollision(body):
	if mon.velocity.y > 0 or not jumping:
		return
	
	if body is StaticBody3D:
		stopJump()
	
	if body is Monigote:
		stopJump()
		body.knockback(Vector2.DOWN * 8)
		mon.knockback(Vector2.UP * 8)

func stopJump():
	jumping = false
	$JumpCooldown.start()
	mon.unstun()
	
	if Input.is_action_pressed(mon.actions.grab) and not $GrabBuffer.is_stopped():
		mon.attemptGrab()
