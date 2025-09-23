extends Control

signal finished

@onready var controllerId : int = Controllers.KB

func setControllerId(id : int):
	for c : GamepadSelectButton in $HBoxContainer.get_children():
		c.controller = id
	
	controllerId = id

func finish():
	for c : GamepadSelectButton in $HBoxContainer.get_children():
		c.unfocus()
	finished.emit()
