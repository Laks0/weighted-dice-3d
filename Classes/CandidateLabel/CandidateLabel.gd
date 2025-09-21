extends Label3D

var _odds : int

## El color para las odds x3
@export var x3Color : Color = Color.YELLOW
## El color para las odds x4+
@export var x4Color : Color = Color.RED
@export var maxX4Shake : float = 20

func setCandidate(candidate):
	text = BetHandler.getCandidateName(candidate)
	modulate = BetHandler.getCandidateColor(candidate)
	
	_odds = BetHandler.getCandidateOdds(candidate)
	$OddsLabel.text = "x" + str(_odds)
	
	if _odds >= 3:
		var oddsTween := create_tween().set_loops()\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_SINE)
		oddsTween.tween_property($OddsLabel, "position:y", .1, .5)
		oddsTween.tween_property($OddsLabel, "position:y", .03, .5)
		
		modulate = x3Color
	
	if _odds >= 4:
		var shakeTween := create_tween().set_loops()
		shakeTween.tween_callback(func (): $OddsLabel.offset.x = (randf()-.5) * maxX4Shake*2)
		shakeTween.tween_interval(.05)
		modulate = x4Color
	
