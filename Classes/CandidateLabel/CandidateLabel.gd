extends Label3D

var odds : int

## El color para las odds x3
@export var x3Color : Color = Color.YELLOW
## El color para las odds x4+
@export var x4Color : Color = Color.RED
@export var maxX4Shake : float = 20

func setCandidate(candidate):
	text = BetHandler.getCandidateName(candidate)
	modulate = BetHandler.getCandidateColor(candidate)
	
	$OddsLabel.visible = false
	
	odds = BetHandler.getCandidateOdds(candidate)
	$OddsLabel.text = "x" + str(odds)
	
	if odds == 3:
		$OddsLabel.modulate = x3Color
		$OddsLabel.position.y -= .05
		$OddsLabel.font_size += 8
		$OddsLabel.outline_size += 4
	elif odds >= 4:
		$OddsLabel.modulate = x4Color
		$OddsLabel.position.y -= .07
		$OddsLabel.font_size += 20
		$OddsLabel.outline_size += 13
	$OddsLabel/OddsParticles.draw_pass_1.material.albedo_color = $OddsLabel.modulate

func startOddsAnimation(delayTime : float = 0) -> Tween:
	var animationTween := create_tween()
	
	var currentPosition = $OddsLabel.position
	animationTween.tween_interval(delayTime)
	animationTween.tween_callback(func (): $OddsLabel.visible = true)
	if odds <= 2:
		$OddsLabel.position.y = -3
		animationTween.tween_property($OddsLabel, "position", currentPosition, .4)
	
	elif odds <= 3:
		$OddsLabel.position.y = -3
		animationTween.tween_callback(func (): $OddsLabel/OddsParticles.emitting = true)
		
		animationTween.tween_property($OddsLabel, "position:y", currentPosition.y, .5)
	
	elif odds >= 4:
		$OddsLabel.position.y = -3
		animationTween.tween_callback(func (): $OddsLabel/OddsParticles.emitting = true)
		
		animationTween.tween_property($OddsLabel, "position:y", currentPosition.y, .5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		animationTween.tween_property($OddsLabel, "position", 
			currentPosition + Vector3.BACK * .5, .4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		animationTween.tween_property($OddsLabel, "position", currentPosition, .3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		animationTween.tween_callback(
			get_viewport().get_camera_3d().startShake.bind(.1,.1)
		)
	
	animationTween.tween_callback(_startLoopAnimation)
	
	return animationTween

func _startLoopAnimation():
	if odds >= 3:
		var oddsTween := create_tween().set_loops()\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_SINE)
		oddsTween.tween_property($OddsLabel, "position:z", .1, .5)
		oddsTween.tween_property($OddsLabel, "position:z", .03, .5)
	
	if odds >= 4:
		var shakeTween := create_tween().set_loops()
		shakeTween.tween_callback(func (): $OddsLabel.offset.x = (randf()-.5) * maxX4Shake*2)
		shakeTween.tween_interval(.05)
