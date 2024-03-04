extends Effect

@export var PortalScene : PackedScene

var portal

func start():
	portal = PortalScene.instantiate()
	portal.position.y = .06
	arena.add_child(portal)

func end():
	if not is_instance_valid(portal):
		return
	portal.kill()
