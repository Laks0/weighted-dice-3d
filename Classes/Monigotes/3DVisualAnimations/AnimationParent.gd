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

func _ready():
	for c in get_children():
		if not c is MonigoteAnimation3D:
			continue
		c.mon = mon
		c.animatedSprite = animatedSprite

func _physics_process(_delta):
	var animatedBasis := baseAnimation.resultBasis
	for c in get_children():
		if not c is MonigoteAnimation3D:
			continue
		if c == baseAnimation or not c.playing:
			continue
		
		animatedBasis *= c.resultBasis
	
	if _isAnimationManual:
		var baseRotation := baseAnimation.resultBasis.get_euler().x
		animatedSprite.rotation.x = min(-PI/2 * _elevationPercentage, baseRotation)
		animatedSprite.rotation.y = PI/2-_dirBeingGrabbed.angle()
		animatedSprite.modulate.a = .7
	else:
		animatedSprite.basis = animatedBasis

func startManualAnimation():
	_isAnimationManual = true
	animatedSprite.basis = Basis().scaled(animatedSprite.scale)
	_elevationPercentage = 0

func endManualAnimation():
	_isAnimationManual = false

func manualAnimate(dirBeingGrabbed : Vector2, elevationPercentage : float):
	_dirBeingGrabbed = dirBeingGrabbed
	_elevationPercentage = elevationPercentage
