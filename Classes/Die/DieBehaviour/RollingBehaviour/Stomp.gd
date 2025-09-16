extends AnimationStep

var result : int = -1
@onready var die : Die = animationRoot().die

func _onStart():
	die = animationRoot().die
	result = die.pickNewEffect(result)
	
	die.axis_lock_angular_x = true
	die.axis_lock_angular_y = true
	die.axis_lock_angular_z = true
	die.rotations.setRotationToFace(result+1)
	
	die.apply_central_impulse(Vector3.DOWN * 200)
	
	animationRoot().result = result
	end()
