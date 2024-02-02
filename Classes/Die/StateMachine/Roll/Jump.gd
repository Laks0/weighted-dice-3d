@tool
extends State

var die : Die

func _on_enter(_args):
	die = target as Die
	
	die.linear_velocity = Vector3.ZERO
	
	die.throw(Vector3.UP * 100)

func _on_update(_delta):
	if die.linear_velocity.y < 0:
		change_state("Stomp")
