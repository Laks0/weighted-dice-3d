@tool
extends State

var result : int
var die : Die

func _on_enter(_args):
	result = randi() % 6
	
	die = target as Die
	
	die.rotation_degrees = die.rotations[result]
	die.axis_lock_angular_x = true
	die.axis_lock_angular_y = true
	die.axis_lock_angular_z = true
	
	die.apply_central_impulse(Vector3.DOWN * 200)
	
	change_state("Wait", result)
