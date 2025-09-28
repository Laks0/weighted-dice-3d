extends Node3D
var fullSpeed := true
var delaying := false
func walkingAndGrabbing():
	fullSpeed = false
	#if !$LStep.playing && !$RStep.playing:
	#	$LStep.play()

func running():
	fullSpeed = true
	if !$LStep.playing && !$RStep.playing:
		$LStep.play()

func none():
	$LStep.stop()
	$RStep.stop()
	delaying = false

func nextStep(lastStep : String):
	if !fullSpeed:
		return #Esto a retocar cuando haya animaciónde monigotes caminando lento al grabbear
		#delaying = true
		#await get_tree().create_timer(0.1).timeout
	if lastStep == "l": $RStep.play()
	else: $LStep.play()

func _on_l_step_finished() -> void:
	nextStep("l")

func _on_r_step_finished() -> void:
	nextStep("r")
