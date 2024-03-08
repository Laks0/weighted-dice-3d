@tool
extends State

func _on_enter(_args):
	target.freeze = true
	var outTween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	outTween.tween_property(target, "position", Vector3(-9, 5, 0), 1)
	
	var effect : Effect = target.get_parent().effects[5]
	get_tree().create_timer(effect.duration).timeout.connect(change_to_next)

func _on_exit(_args):
	target.freeze = false
	target.get_parent().lightsOn()
