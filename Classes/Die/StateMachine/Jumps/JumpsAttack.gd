@tool
extends State

@export_range(10,100) var UP_FORCE : int = 50
## La fuerza en la dirección del monigote más cercano
@export_range(10,100) var DIR_FORCE : int = 30

func _on_enter(_args):
	var dir2d := target._getClosestMonigoteDirection()
	target.throw(Vector3(dir2d.x, 0, dir2d.y) * DIR_FORCE
	+ Vector3.UP * UP_FORCE)
