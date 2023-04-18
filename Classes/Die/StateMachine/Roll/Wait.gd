extends State

var result : int

func _on_enter(res) :
	result = res

func _on_update(_delta):
	var die := target as Die
	if die.onFloor():
		die.axis_lock_angular_x = false
		die.axis_lock_angular_y = false
		die.axis_lock_angular_z = false
		
		die.emit_signal("rolled", result)
		
		get_parent().change_state("RandomAttack")
