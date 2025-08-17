extends Node3D

signal jumpStarted
signal jumpEnded

@export var verticalSpeedCurve : Curve
@export var horizontalSpeedCurve : Curve
@export var maxVerticalSpeed : float = 4.0

@onready var mon : Monigote = get_parent()
var floorFriction : float

var jumpDirection : Vector2

func _ready():
	$LandParticles.material_override.albedo_color = mon.player.color

func _process(delta):
	if $JumpTimer.is_stopped():
		return
	
	var jumpProgression : float = 1 - ($JumpTimer.time_left/$JumpTimer.wait_time)
	
	mon.velocity.y = maxVerticalSpeed * verticalSpeedCurve.sample(jumpProgression)
	mon.applyVelocity(30 * jumpDirection * horizontalSpeedCurve.sample(jumpProgression))

func jump():
	if mon.grabbed or mon.movementStopped:
		return
	
	mon.stopMovement()
	mon.gravityStopped = true
	jumpDirection = Controllers.getDirection(mon.controller)
	
	# Mientras un monigote está saltando no puede colisionar con otros monigotes
	mon.set_collision_mask_value(1, false)
	#floorFriction = mon.FRICTION
	#mon.FRICTION = airFriction
	jumpStarted.emit()
	
	$JumpTimer.start()

func onFloorCollision(body):
	pass

func endJump():
	mon.resumeMovement()
	mon.set_collision_mask_value(1, true)
	mon.gravityStopped = false

func _input(event):
	if event.is_action(mon.actions["jump"]):
		jump()
