extends AnimationStep

func start():
	animationRoot().die.freeze = true
	var positionTween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	var preparationPosition := Vector3(-3.5, 3, 0)
	var altPosition := Vector3(3.5,3,0)
	var currentPosition : Vector3 = animationRoot().die.global_position
	if currentPosition.distance_squared_to(preparationPosition) > currentPosition.distance_squared_to(altPosition):
		preparationPosition = altPosition
	
	positionTween.tween_property(animationRoot().die, "position", preparationPosition, .3)
	positionTween.finished.connect(end)
