extends Node3D
class_name MonigoteAnimation3DHandler

@export var mon : Monigote
@export var animatedSprite : MonigoteSprite

## La animación que determina la transformación base, las demás animaciones
## aplican transformaciones a su resultado
@export var baseAnimation : MonigoteAnimation3D

var _dirBeingGrabbed              := Vector2.LEFT
var _elevationPercentage          : float
var _isAnimationManual := false

# Buscar forma de sacar esto
var thrownFactor : float

func _ready():
	for c : MonigoteAnimation3D in get_children():
		c.mon = mon
		c.animatedSprite = animatedSprite

var _asdfasdf:= false

func _physics_process(_delta):
	var animatedBasis := baseAnimation.resultBasis
	for c : MonigoteAnimation3D in get_children():
		if c == baseAnimation or not c.playing:
			continue
		
		animatedBasis *= c.resultBasis
	
	if _isAnimationManual:
		if _asdfasdf:
			return
		
		var baseRotation := baseAnimation.resultBasis.get_euler().x
		animatedSprite.rotation.x = min(-PI/2 * _elevationPercentage, baseRotation)
		animatedSprite.rotation.y = PI/2-_dirBeingGrabbed.angle()
		animatedSprite.modulate.a = .7
		
		if not mon.grabbed and not mon.movement.isBeingPushed():
			_asdfasdf = true
			await get_tree().create_timer(mon.afterPushStunTime*thrownFactor).timeout
			if not _asdfasdf:
				return
			endManualAnimation()
			mon.resumeMovement()
	else:
		animatedSprite.basis = animatedBasis

func startManualAnimation():
	_asdfasdf = false
	_isAnimationManual = true
	animatedSprite.basis = Basis().scaled(animatedSprite.scale)
	_elevationPercentage = 0

func endManualAnimation():
	_isAnimationManual = false

func manualAnimate(dirBeingGrabbed : Vector2, elevationPercentage : float):
	_dirBeingGrabbed = dirBeingGrabbed
	_elevationPercentage = elevationPercentage
