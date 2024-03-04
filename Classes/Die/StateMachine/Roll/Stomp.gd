@tool
extends State

var result : int = -1
var die : Die

func _on_enter(_args):
	var old_result = result
	while result == old_result:
		if randf() <= 1.0/target.invertedChanceOfSix:
			result = 5
		else:
			result = randi() % 5
	
	die = target as Die
	
	die.rotation_degrees = die.rotations[result]
	die.axis_lock_angular_x = true
	die.axis_lock_angular_y = true
	die.axis_lock_angular_z = true
	
	die.apply_central_impulse(Vector3.DOWN * 200)
	
	change_state("Wait", result)
