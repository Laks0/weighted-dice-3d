extends HBoxContainer

@export var playerGrabDisplay : PackedScene

var arena : Arena

func start(_a : Arena):
	arena = _a
	for m in arena.getLivingMonigotes():
		var display = playerGrabDisplay.instantiate()
		display.monigote = m
		add_child(display)
