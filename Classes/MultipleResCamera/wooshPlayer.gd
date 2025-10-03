extends Node

func playSound(sound : String):
	if sound == "wooshTrans": $Transition.play()
	if sound == "Zoom": $Zoom.play()
