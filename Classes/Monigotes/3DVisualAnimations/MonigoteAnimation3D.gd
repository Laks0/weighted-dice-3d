extends Node3D
class_name MonigoteAnimation3D

var mon       : Monigote
var animatedSprite : AnimatedSprite3D
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
	if playing and mon.is_processing():
		processUpdate(delta)

func _physics_process(delta):
	if playing and mon.is_processing():
		physicsUpdate(delta)
