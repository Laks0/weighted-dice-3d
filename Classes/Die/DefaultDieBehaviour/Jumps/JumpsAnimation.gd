extends AnimationStep

var die : Die
var targetPosition : Vector3
@export var attacks : int = 3

func _ready():
	die = get_parent().die

func animationFinished():
	attacks -= 1
	if attacks <= 0:
		end()
		return
	
	$Preparation.start()
