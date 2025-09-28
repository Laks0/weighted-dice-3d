extends Node3D
class_name MonigoteAnimation3DHandler

@export var mon : Monigote
@export var animatedSprite : MonigoteSprite

## La animación que determina la transformación base, las demás animaciones
## aplican transformaciones a su resultado
@export var baseAnimation : MonigoteAnimation3D

var _dirBeingGrabbed              := Vector2.LEFT
var _elevationPercentage          : float
var _isBeingGrabbedAnimationGoing := false

func _ready():
	for c : MonigoteAnimation3D in get_children():
		c.mon = mon
		c.animatedSprite = animatedSprite

func _physics_process(_delta):
	var animatedBasis := baseAnimation.resultBasis
	for c : MonigoteAnimation3D in get_children():
		if c == baseAnimation or not c.playing:
			continue
		
		animatedBasis *= c.resultBasis
	
	if _isBeingGrabbedAnimationGoing:
		var baseRotation := baseAnimation.resultBasis.get_euler().x
		animatedSprite.rotation.x = min(-PI/2 * _elevationPercentage, baseRotation)
		animatedSprite.rotation.y = PI/2-_dirBeingGrabbed.angle()
		animatedSprite.modulate.a = .7
	else:
		animatedSprite.basis = animatedBasis

func startMonigoteGrabbedAnimation():
	_isBeingGrabbedAnimationGoing = true
	_elevationPercentage = 0

func endMonigoteGrabbedAnimation():
	_isBeingGrabbedAnimationGoing = false

func animateGrabbing(dirBeingGrabbed : Vector2, elevationPercentage : float):
	_dirBeingGrabbed = dirBeingGrabbed
	_elevationPercentage = elevationPercentage
