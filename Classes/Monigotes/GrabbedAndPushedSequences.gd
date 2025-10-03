extends Node3D

@export var animatedSprite : MonigoteSprite
@export var mon : Monigote

@export var maxStunTime   : float = 1
@export var stunThreshold : float = .6
var _forceThrown : float

var _beingPushed := false 

@export var _floorParticles : GPUParticles3D

func onMonigoteBeingGrabbed(dir: Vector2, _factor: float, pusher: Pushable) -> void:
	animatedSprite.setFeetLookingAt(dir, pusher.grabbingHandler.getCurrentElevationPercentage())

func onMonigoteBeenGrabbed() -> void:
	animatedSprite.startManualAnimation()
	$AfterPushStunTimer.stop()
	animatedSprite.play("Pushed")
	animatedSprite.frame = 6
	animatedSprite.setNameToGlobalSpace()

func onMonigoteWasPushed(dir: Vector2, factor: float, _pusher: Pushable) -> void:
	_forceThrown = factor
	_beingPushed = true
	
	animatedSprite.endManualAnimation()
	mon.movement.stun(10000, -dir, 1.2, true)
	
	if _forceThrown >= stunThreshold:
		_floorParticles.restart()

func onPushTravelEnded():
	_floorParticles.emitting = false
	_beingPushed = false
	if _forceThrown >= stunThreshold:
		$AfterPushStunTimer.start(maxStunTime * _forceThrown)
	else:
		onStuntimeEnded()

func onStuntimeEnded():
	animatedSprite.setNameToLocalSpace()
	
	mon.movement.unstun()

func _physics_process(_delta: float) -> void:
	if not _beingPushed:
		return
	
	if not mon.movement.isBeingPushed():
		onPushTravelEnded()
