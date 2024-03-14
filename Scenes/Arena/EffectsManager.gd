extends Node

## Efectos que van en los números del 1 al 5
@export var regularEffects : Array[PackedScene]
## Efectos que van en el 6
@export var specialEffects : Array[PackedScene]

func pickEffects():
	if not MultiplayerHandler.isAuthority():
		return
	
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	var idxs : Array = []
	
	var pickedEffects : Array[PackedScene] = []
	for _i in range(5):
		var pickedEffect : PackedScene = regularEffects.pick_random()
		while pickedEffects.has(pickedEffect):
			pickedEffect = regularEffects.pick_random()
		pickedEffects.append(pickedEffect)
		add_child(pickedEffect.instantiate())
		idxs.append(regularEffects.find(pickedEffect))
	
	var specialIdx = randi() % specialEffects.size()
	add_child(specialEffects[specialIdx].instantiate())
	
	if MultiplayerHandler.isAuthority():
		_syncEffects.rpc(idxs, specialIdx)

@rpc("authority", "reliable", "call_remote")
func _syncEffects(idxs : Array, specialIdx : int):
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	for idx in idxs:
		add_child(regularEffects[idx].instantiate())
	add_child(specialEffects[specialIdx].instantiate())
	
	get_parent().effects = get_children()
	for e in get_children():
		e.create(get_parent())
