@tool
extends State

func _on_enter(_args):
	target.freeze = true
	var outTween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	outTween.tween_property(target, "scale", Vector3.ZERO, .4)
	outTween.tween_callback(func(): 
		target.position = Vector3(-10, 3, 0)
		target.scale = Vector3.ONE)
	
	var effect : Effect = target.get_parent().effects[5]
	get_tree().create_timer(effect.duration).timeout.connect(change_to_next)

func _on_exit(_args):
	target.freeze = false
	target.get_parent().environment.lightsOn()
