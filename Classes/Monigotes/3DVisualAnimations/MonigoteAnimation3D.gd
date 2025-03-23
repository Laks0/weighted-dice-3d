extends Node3D
class_name MonigoteAnimation3D

var mon : Monigote: 
	set(m):
		mon = m
		_onMonigoteSet()
var animatedSprite : AnimatedSprite3D:
	set(sprite):
		animatedSprite = sprite
		_onAnimatedSpriteSet()

## La transformación que se tiene que aplicar al monigote,
## todas las animaciones mutiplican sus transformaciones
var resultBasis    : Basis
var playing := false

func play():
	playing = true

func stop():
	playing = false

func processUpdate(_delta):
	pass

func physicsUpdate(_delta):
	pass

func _process(delta):
	if playing:
		processUpdate(delta)

func _physics_process(delta):
	if playing:
		physicsUpdate(delta)

func _onMonigoteSet():
	pass

func _onAnimatedSpriteSet():
	pass
