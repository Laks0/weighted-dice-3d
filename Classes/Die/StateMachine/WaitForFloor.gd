@tool
extends State

func _state_timeout():
	change_state("Prepare")
