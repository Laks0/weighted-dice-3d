@tool
extends State

func _on_enter(dir : Vector2):
	get_parent().bursts += 1
	var die := target as Die
	
	die.throw(Vector3(dir.x * 200, 0, dir.y * 200))
