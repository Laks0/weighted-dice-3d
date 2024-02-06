extends Effect

@export var SpikesLayout : PackedScene

var layout : Node3D

func start():
	layout = SpikesLayout.instantiate()
	arena.add_child(layout)
	
	# Movimiento de los monigotes para que no se queden abajo de los pinchos
	# cuando spawnean
	var padding = 1
	for mon in arena.getLivingMonigotes():
		if mon.position.x > Globals.BOTTOM_CORNER.x - padding:
			mon.position.x -= padding
		if mon.position.z > Globals.BOTTOM_CORNER.z - padding:
			mon.position.z -= padding
		if mon.position.x < Globals.TOP_CORNER.x + padding:
			mon.position.x += padding
		if mon.position.z < Globals.TOP_CORNER.z + padding:
			mon.position.z += padding

func end():
	arena.remove_child(layout)
