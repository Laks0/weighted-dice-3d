extends Effect

@export var PortalScene : PackedScene

var portal

@export var time := 20.0

func start():
	portal = PortalScene.instantiate()
	portal.position.y = .06
	arena.add_child(portal)
	
	await get_tree().create_timer(time).timeout
	effectFinished.emit()

func end():
	if not is_instance_valid(portal):
		return
	portal.kill()
