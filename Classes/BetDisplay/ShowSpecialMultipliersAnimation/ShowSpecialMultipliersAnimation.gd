extends AnimationStep

var camera : MultipleResCamera
var candidateLabelScene : PackedScene

@export var betDisplay : BetDisplaySimple

func _onStart():
	candidateLabelScene = get_parent()._candidateLabelScene
