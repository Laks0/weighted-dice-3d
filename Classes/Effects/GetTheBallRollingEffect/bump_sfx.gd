extends AudioStreamPlayer3D


@export var pitchScaleFactor := 0.97
@export var initialPitch := 1.1

func playSFX():
	var count = get_parent().rollCounter
	pitch_scale *= pitchScaleFactor
	if count == 0: pitch_scale = initialPitch
	play()
