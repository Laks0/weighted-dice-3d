@tool
extends State

func _on_update(_delta):
	if target.onFloor() or not target.visible:
		change_to_next()
