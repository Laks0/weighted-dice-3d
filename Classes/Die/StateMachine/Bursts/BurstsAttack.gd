@tool
extends StateLoop

const MAX_BURSTS = 3
var bursts : int

func _on_enter(_args):
	bursts = 0

func _on_update(_delta):
	if bursts >= MAX_BURSTS and get_active_substate() == $Wait:
		change_state("Roll")
