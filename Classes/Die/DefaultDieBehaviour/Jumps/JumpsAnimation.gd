extends AnimationStep

@onready var die : Die = get_parent().die
var targetPosition : Vector3

@export var attacks : int = 3

func animationFinished():
	attacks -= 1
	if attacks <= 0:
		end()
		return
	
	$Preparation.start()
