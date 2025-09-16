extends DieBehaviourStep

@export var time : float = .5

func _onStart():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(die, "position:y", animationRoot().dieLevitationHeight, time)
	tween.tween_callback(end)
