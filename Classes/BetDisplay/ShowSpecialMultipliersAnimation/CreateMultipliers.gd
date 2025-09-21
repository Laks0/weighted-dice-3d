extends AnimationStep

var _candidateLabelScene : PackedScene

func _onStart():
	_candidateLabelScene = animationRoot().candidateLabelScene
