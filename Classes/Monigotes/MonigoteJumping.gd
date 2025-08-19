extends Node3D

signal jumpStarted
signal jumpEnded

@export var verticalSpeedCurve : Curve
@export var horizontalSpeedCurve : Curve
@export var maxVerticalSpeed : float = 4.5
@export var maxHorizontalSpeed : float = 30

# Porcentaje mínimo del salto antes de que se pueda soltar
@export var minJumpProgression : float = .4

@onready var mon : Monigote = get_parent()
var floorFriction : float

var jumpDirection : Vector2

var jumpProgression : float

func _ready():
	$JumpParticles.material_override.albedo_color = mon.player.color

func _process(_delta):
	if $JumpTimer.is_stopped():
		return
	
	if not $DirectionPickGraceTime.is_stopped() and jumpDirection == Vector2.ZERO:
		jumpDirection = Controllers.getDirection(mon.controller).normalized()
	
	jumpProgression = 1 - ($JumpTimer.time_left/$JumpTimer.wait_time)
	
	mon.velocity.y = maxVerticalSpeed * verticalSpeedCurve.sample(jumpProgression)
	mon.applyVelocity(maxHorizontalSpeed * jumpDirection * horizontalSpeedCurve.sample(jumpProgression))
	
	if jumpProgression >= minJumpProgression and not Input.is_action_pressed(mon.actions["jump"]):
		endJump()

func jump():
	if mon.grabbed or mon.movementStopped:
		return
	if not $JumpCooldown.is_stopped():
		return
	
	$TimeToResumeGrabbing.stop()
	
	mon.stopMovement()
	mon.gravityStopped = true
	mon.stopGrabbing()
	
	$DirectionPickGraceTime.start()
	
	jumpDirection = Controllers.getDirection(mon.controller).normalized()
	
	# Mientras un monigote está saltando no puede colisionar con otros monigotes
	mon.set_collision_mask_value(1, false)
	jumpStarted.emit()
	
	$JumpTimer.start()

func onFloorCollision(_body):
	if jumpProgression >= minJumpProgression:
		endJump()

func endJump():
	mon.resumeMovement()
	mon.set_collision_mask_value(1, true)
	mon.gravityStopped = false
	$JumpTimer.stop()
	jumpEnded.emit()
	$JumpCooldown.start()

func _input(event):
	if event.is_echo() or not event.is_pressed():
		return
	if event.is_action(mon.actions["jump"]):
		jump()
