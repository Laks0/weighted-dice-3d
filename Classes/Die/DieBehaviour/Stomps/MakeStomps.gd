extends DieBehaviourStep

@export var downTime : float = .1
@export var restTime : float = .1
@export var upTime   : float = .3

@export var shakeMagnitude := .2
@export var shakeTime := .1

func _onStart():
	var levitationHeight := die.position.y
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	for i in range(animationRoot().stomps):
		tween.tween_callback(func ():
			die.hitting = true)
		
		if i > 0:
			tween.tween_interval(restTime)
			tween.tween_property(die, "transform",
				die.rotations.getTransformHavingRolled(animationRoot().stomps-i)\
					.translated(Vector3.UP * (levitationHeight-.6)),
				upTime)
		
		tween.tween_property(die, "position:y", .6, downTime)
		
		tween.tween_callback(func ():
			get_viewport().get_camera_3d().startShake(shakeMagnitude,shakeTime)
			die.hitting = false
		)

	tween.tween_callback(end)
