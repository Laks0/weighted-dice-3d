extends DieBehaviour

func _onStart():
	die.freeze = true
	var outTween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	outTween.tween_property(die, "scale", Vector3.ZERO, .4)
	outTween.tween_callback(func(): 
		die.position = Vector3(-10, 3, 0)
		die.scale = Vector3.ONE
		die.visible = false)

func _onCurrentEffectFinished():
	die.freeze = false
	stop()
