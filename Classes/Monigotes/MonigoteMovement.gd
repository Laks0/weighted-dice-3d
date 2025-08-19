extends Node3D
class_name MonigoteMovement

@export var mon : Monigote

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var GRAVITY_ACCELERATION     : float = 50

var moveVelocity      := Vector2.ZERO
var unclampedVelocity := Vector2.ZERO
var frameVelocity     := Vector2.ZERO

var _movementDir : Vector2

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	mon.velocity = Vector3.ZERO

func goMaxSpeed(dir : Vector2) -> void:
	var vel2d := dir.normalized() * MAX_SPEED
	mon.velocity.x = vel2d.x
	mon.velocity.z = vel2d.y

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	unclampedVelocity = unclampedVelocity.bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	mon.velocity = mon.velocity.bounce(normal)

func applyFrameVelocity(vel : Vector2):
	frameVelocity += vel

func applyVelocity(vel : Vector2):
	unclampedVelocity += vel

func applyAcceleraction(acc : Vector2):
	unclampedVelocity += acc * get_physics_process_delta_time()

func getMovementDir() -> Vector2:
	return _movementDir

func getUnclampedVelocity() -> Vector2:
	return unclampedVelocity

func _physics_process(delta):
	if mon.player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(mon.controller)
	
	if mon.drunk:
		_movementDir = _movementDir.rotated(PI)
	
	var accFactor := 1.0
	if mon.grabbing and is_instance_valid(mon.grabBody):
		accFactor = mon.grabBody.grabSpeedFactor
	
	if mon.stunned or mon.movementStopped:
		accFactor = 0
	
	if mon.grabbed:
		return
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * accFactor)
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, mon.FRICTION * delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, mon.FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, mon.FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity + frameVelocity
	
	frameVelocity = Vector2.ZERO

	mon.velocity = Vector3(vel2d.x, mon.velocity.y, vel2d.y)
	if not mon.gravityStopped:
		mon.velocity.y -= GRAVITY_ACCELERATION * delta
	
	mon.move_and_slide()
