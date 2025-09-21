extends AnimationStep

@export var target : Camera3D

func _onStart():
	var camera : MultipleResCamera = animationRoot().camera
	
	await camera.goToCamera(target).finished
	end()
