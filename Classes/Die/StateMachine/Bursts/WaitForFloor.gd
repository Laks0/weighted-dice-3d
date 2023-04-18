@tool
extends State

func _state_timeout():
	get_parent().bursts += 1
	
	if get_parent().bursts <= get_parent().MAX_BURSTS:
		change_state("Prepare")
