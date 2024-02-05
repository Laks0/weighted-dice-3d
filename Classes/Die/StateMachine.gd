@tool
extends State

func _on_enter(_args):
	change_to_next_substate()

func _on_update(_delta):
	# Desabilita todo estado cuando alguien ganó
	if target.get_parent().getLivingMonigotes().size() == 0:
		disabled = true
