extends Node

@onready var monigote : Monigote = get_parent()
@onready var arena : Arena = monigote.get_parent()

func _process(_delta):
	var objMonigote : Monigote = arena.getClosestMonigote(monigote.position, monigote)

	if not is_instance_valid(objMonigote):
		return

	var objPos2d = Vector2(objMonigote.position.x, objMonigote.position.z)
	var monPos2d = Vector2(monigote.position.x, monigote.position.z)
	monigote._movementDir = monPos2d.direction_to(objPos2d)
