extends Node3D

@export var animatedSprite : MonigoteSprite
@export var mon : Monigote
@export var spriteAnimationHandler : MonigoteAnimation3DHandler
@export var collisionShape : CollisionShape3D

@export var maxStunTime   : float = 1
@export var stunThreshold : float = .6
var _forceThrown : float

var _beingPushed := false 

@export var _floorParticles : GPUParticles3D

func onMonigoteBeingGrabbed(dir: Vector2, _factor: float, pusher: Pushable) -> void:
	spriteAnimationHandler.manualAnimate(dir, pusher.grabbingHandler.getCurrentElevationPercentage())

func onMonigoteBeenGrabbed() -> void:
	spriteAnimationHandler.startManualAnimation()
	$AfterPushStunTimer.stop()
	animatedSprite.stopAnimations()
	animatedSprite.play("Pushed")
	animatedSprite.frame = 6

func onMonigoteWasPushed(dir: Vector2, factor: float, _pusher: Pushable) -> void:
	_forceThrown = factor
	_beingPushed = true
	mon.stopMovement()
	
	spriteAnimationHandler.manualAnimate(-dir, 1.2)
	animatedSprite.play("Pushed")
	animatedSprite.frame = 2
	
	collisionShape.look_at(Vector3.DOWN, Vector3(dir.x,0,dir.y))
	
	if _forceThrown >= stunThreshold:
		_floorParticles.restart()

func onPushTravelEnded():
	_floorParticles.emitting = false
	collisionShape.rotation = Vector3.ZERO
	_beingPushed = false
	if _forceThrown >= stunThreshold:
		$AfterPushStunTimer.start(maxStunTime * _forceThrown)
	else:
		onStuntimeEnded()

func onStuntimeEnded():
	mon.resumeMovement()
	spriteAnimationHandler.endManualAnimation()
	animatedSprite.resumeAnimations()
	
	mon.velocity.y = 8

func _physics_process(_delta: float) -> void:
	if not _beingPushed:
		return
	
	if not mon.movement.isBeingPushed():
		onPushTravelEnded()
