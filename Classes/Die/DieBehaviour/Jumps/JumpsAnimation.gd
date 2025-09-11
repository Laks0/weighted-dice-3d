extends AnimationStep

var die : Die
var targetPosition : Vector3
@export var maxAttacks : int = 3

var attacks : int

func _onStart():
	die = get_parent().die
	attacks = maxAttacks

func animationFinished():
	attacks -= 1
	if attacks <= 0:
		end()
		return
	
	$Preparation.start()
