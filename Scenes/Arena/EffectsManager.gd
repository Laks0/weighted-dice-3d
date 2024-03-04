extends Node

## Efectos que van en los números del 1 al 5
@export var regularEffects : Array[PackedScene]
## Efectos que van en el 6
@export var specialEffects : Array[PackedScene]

func pickEffects():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	var pickedEffects : Array[PackedScene]
	for _i in range(5):
		var pickedEffect : PackedScene = regularEffects.pick_random()
		while pickedEffects.has(pickedEffect):
			pickedEffect = regularEffects.pick_random()
		pickedEffects.append(pickedEffects)
		add_child(pickedEffect.instantiate())
	
	add_child(specialEffects.pick_random().instantiate())
