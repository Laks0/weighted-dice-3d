extends DieBehaviour

var targetPosition : Vector3 = Vector3.ZERO
@export var maxAttacks : int = 3

var attacks : int

func _onStart():
	attacks = maxAttacks

func animationFinished():
	attacks -= 1
	if attacks <= 0:
		end()
		return
	
	$Preparation.start()
