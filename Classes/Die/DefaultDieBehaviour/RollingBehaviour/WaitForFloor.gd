extends AnimationStep

func _onActiveProcess(_delta):
	if animationRoot().die.onFloor() or not animationRoot().die.visible:
		end()
