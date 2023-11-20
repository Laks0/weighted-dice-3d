extends Effect

@export var SpikesLayout : PackedScene

var layout : Node3D

func start():
	layout = SpikesLayout.instantiate()
	arena.add_child(layout)

func end():
	arena.remove_child(layout)
