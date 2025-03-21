extends Node3D

@export var mon : Monigote
@export var animatedSprite : AnimatedSprite3D

## La animación que determina la transformación base, las demás animaciones
## aplican transformaciones a su resultado
@export var baseAnimation : MonigoteAnimation3D

func _ready():
	for c : MonigoteAnimation3D in get_children():
		c.mon = mon
		c.animatedSprite = animatedSprite

func _process(_delta):
	var animatedBasis := baseAnimation.resultBasis
	for c : MonigoteAnimation3D in get_children():
		if c == baseAnimation or not c.playing:
			continue
		
		animatedBasis *= c.resultBasis
	
	if mon.grabbed:
		var baseRotation := baseAnimation.resultBasis.get_euler().x
		animatedSprite.rotation.x = min(-PI/2 * mon.forceBeingGrabbed, baseRotation)
		animatedSprite.rotation.y = PI/2-mon.dirBeingGrabbed.angle()
		animatedSprite.modulate.a = .7
	else:
		animatedSprite.basis = animatedBasis
