extends Effect

@export var PortalScene : PackedScene

var portal

func start():
	portal = PortalScene.instantiate()
	portal.position.y = .06
	arena.add_child(portal)
	
	var lightTween := get_tree().create_tween()
	lightTween.tween_property(arena.getMainLight(), "light_energy", .3, 1)
	lightTween.set_ease(Tween.EASE_OUT)

func end():
	if not is_instance_valid(portal):
		return
	portal.kill()
	var lightTween := get_tree().create_tween()
	lightTween.tween_property(arena.getMainLight(), "light_energy", 1, 1)
	lightTween.set_ease(Tween.EASE_OUT)
