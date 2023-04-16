extends State

func _on_enter(dir : Vector2):
	var die := target as Die
	
	die.throw(Vector3(dir.x * 200, 0, dir.y * 200))
	
	change_state("Wait")
