extends Node3D
class_name MonigoteMovement

signal wasStunned
signal wasUnstunned

@export var mon : Monigote

@export var MAX_SPEED            : float = 7
@export var ACCELERATION         : float = 80
@export var GRAVITY_ACCELERATION : float = 50

var moveVelocity := Vector2.ZERO

var unclampedVelocities : Dictionary[String, Vector2]

var _movementDir : Vector2

var stunned := false

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocities.clear()
	mon.velocity = Vector3.ZERO

func goMaxSpeed(dir : Vector2) -> void:
	var vel2d := dir.normalized() * MAX_SPEED
	mon.velocity.x = vel2d.x
	mon.velocity.z = vel2d.y

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	for k in unclampedVelocities.keys():
		unclampedVelocities[k] = unclampedVelocities[k].bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	mon.velocity = mon.velocity.bounce(normal)

func applyChannelVelocity(channelSource : Node, vel : Vector2):
	var channel := str(channelSource.get_path())
	if not unclampedVelocities.has(channel):
		unclampedVelocities.set(channel, Vector2.ZERO)
	unclampedVelocities[channel] += vel

func setChannelVelocity(channelSource : Node, vel : Vector2):
	var channel := str(channelSource.get_path())
	unclampedVelocities.set(channel, vel)

func applyVelocity(vel : Vector2):
	applyChannelVelocity(self, vel)

func applyVelocityFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	applyVelocity(pos2d.direction_to(selfPos2d) * force)

func applyAcceleraction(acc : Vector2):
	applyVelocity(acc * get_physics_process_delta_time())

func getMovementDir() -> Vector2:
	return _movementDir

func getUnclampedVelocity() -> Vector2:
	return unclampedVelocities.values()\
		.reduce((func (accum : Vector2, x : Vector2): return accum + x), Vector2.ZERO)

func applyFrictionToUnclampedVelocities(delta : float):
	var keysToDelete := []
	for k in unclampedVelocities.keys():
		unclampedVelocities.set(k, unclampedVelocities[k].move_toward(Vector2.ZERO, mon.FRICTION * delta))
		if unclampedVelocities[k].is_zero_approx():
			keysToDelete.append(k)
	
	for k in keysToDelete:
		unclampedVelocities.erase(k)

func stun(timeout := 5.0):
	stunned = true
	$StunTimeout.start(timeout)
	wasStunned.emit()

func unstun():
	stunned = false
	wasUnstunned.emit()

func _physics_process(delta):
	if mon.player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(mon.controller)
		
		#Sonido de Pisadas
#		var stepsPlayer : AudioStreamPlayer3D = get_parent().get_node("Steps")
#		if _movementDir != Vector2(0.0,0.0):
#			if !stepsPlayer.playing:
#				stepsPlayer.play()
#		else: stepsPlayer.stop()
			
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
