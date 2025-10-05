extends Node3D
class_name MonigoteMovement

signal wasStunned
signal wasUnstunned

@export var mon : Monigote

@export var MAX_SPEED            : float = 7
@export var ACCELERATION         : float = 80
@export var GRAVITY_ACCELERATION : float = 50

var moveVelocity := Vector2.ZERO

var _unclampedVelocities : Dictionary[String, Vector2]

var _movementDir : Vector2

var stunned := false

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	_unclampedVelocities.clear()
	mon.velocity = Vector3.ZERO

func goMaxSpeed(dir : Vector2) -> void:
	var vel2d := dir.normalized() * MAX_SPEED
	mon.velocity.x = vel2d.x
	mon.velocity.z = vel2d.y

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	for k in _unclampedVelocities.keys():
		_unclampedVelocities[k] = _unclampedVelocities[k].bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	mon.velocity = mon.velocity.bounce(normal)

func _applyNodeChannelVelocity(channelSource : Node, vel : Vector2):
	var channel := str(channelSource.get_path())
	applyChannelVelocity(channel, vel)

func applyChannelVelocity(channel : String, vel : Vector2):
	if not _unclampedVelocities.has(channel):
		_unclampedVelocities.set(channel, Vector2.ZERO)
	_unclampedVelocities[channel] += vel

func setChannelVelocity(channelSource : Node, vel : Vector2):
	var channel := str(channelSource.get_path())
	_unclampedVelocities.set(channel, vel)

func applyVelocity(vel : Vector2):
	_applyNodeChannelVelocity(self, vel)

const _PUSH_CHANNEL := "Push"

func applyPushedVelocity(vel : Vector2):
	applyChannelVelocity(_PUSH_CHANNEL, vel)

func isBeingPushed() -> bool:
	return _unclampedVelocities.has(_PUSH_CHANNEL) and not _unclampedVelocities[_PUSH_CHANNEL].is_zero_approx()

func applyVelocityFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	applyVelocity(pos2d.direction_to(selfPos2d) * force)

func applyAcceleraction(acc : Vector2):
	applyVelocity(acc * get_physics_process_delta_time())

func getMovementDir() -> Vector2:
	return _movementDir

func getUnclampedVelocity() -> Vector2:
	return _unclampedVelocities.values()\
		.reduce((func (accum : Vector2, x : Vector2): return accum + x), Vector2.ZERO)

func applyFrictionToUnclampedVelocities(delta : float):
	var keysToDelete := []
	for k in _unclampedVelocities.keys():
		_unclampedVelocities.set(k, _unclampedVelocities[k].move_toward(Vector2.ZERO, mon.FRICTION * delta))
		if _unclampedVelocities[k].is_zero_approx():
			keysToDelete.append(k)
	
	for k in keysToDelete:
		_unclampedVelocities.erase(k)

func stun(timeout := 5.0, directionToLookAt := Vector2.UP, rotationPercentage := 1.0, facingDown := false):
	stunned = true
	$StunTimeout.start(timeout)
	wasStunned.emit()
	
	mon.animatedSprite.startManualAnimation()
	mon.animatedSprite.setFeetLookingAt(directionToLookAt, rotationPercentage, facingDown)
	mon.setCollisionHorizontal(directionToLookAt)

func unstun():
	if not stunned:
		return
	stunned = false
	wasUnstunned.emit()
	mon.animatedSprite.endManualAnimation()
	mon.setCollisionVertical()
	$StunTimeout.stop()
	mon.velocity.y = 8

func _physics_process(delta):
	if mon.player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(mon.controller)
		
		#Sonido de Pisadas
		var stepsPlayer : Node3D = get_parent().get_node("Steps")
		if _movementDir != Vector2(0.0,0.0) && !mon.invincible && mon.is_on_floor() && !mon.grabbed && !stunned:
			if !mon.grabbing:
				stepsPlayer.running()
			else:
				stepsPlayer.walkingAndGrabbing()
		else: stepsPlayer.none()
	if mon.drunk:
		_movementDir = _movementDir.rotated(PI)
	
	var accFactor := 1.0
	if mon.grabbing and is_instance_valid(mon.grabBody):
		accFactor = mon.grabBody.grabSpeedFactor
	
	if stunned or mon.movementStopped:
		accFactor = 0
	
	if mon.grabbed:
		return
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * accFactor)
	
	applyFrictionToUnclampedVelocities(delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, mon.FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, mon.FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + getUnclampedVelocity()

	mon.velocity = Vector3(vel2d.x, mon.velocity.y, vel2d.y)
	if not mon.gravityStopped:
		mon.velocity.y -= GRAVITY_ACCELERATION * delta
		
	
	mon.move_and_slide()
