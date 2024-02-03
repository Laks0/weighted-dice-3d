@tool
extends State

func _on_enter(_args):
	get_parent().change_to_next_substate()
