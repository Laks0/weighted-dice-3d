@tool
extends State

func _on_update(_delta):
	if target.onFloor():
		change_to_next()
