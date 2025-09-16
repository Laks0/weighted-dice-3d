extends DieBehaviourStep

@export var dieLevitationHeight : float = 3
@export var rounds : int = 3
@export var stomps : int = 3

var elapsedRounds : int = 0

func _onStart():
	elapsedRounds = 0
	die.freeze = true

func _onEnd():
	die.freeze = false

func animationFinished():
	elapsedRounds += 1
	if elapsedRounds >= rounds:
		end()
	else:
		get_child(0).start()
