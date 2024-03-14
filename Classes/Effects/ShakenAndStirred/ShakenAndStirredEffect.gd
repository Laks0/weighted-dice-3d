extends Effect

@export var drinkScene : PackedScene
@export var drinksAmount : int = 3

func start():
	if not MultiplayerHandler.isAuthority():
		return
	
	for _i in range(drinksAmount):
		spawnDrink.rpc(arena.getRandomPosition())

@rpc("authority", "call_local", "reliable")
func spawnDrink(pos : Vector3):
	var drink = drinkScene.instantiate()
	drink.position = pos
	arena.add_child(drink, true)

func end():
	for drink in get_tree().get_nodes_in_group("Drinks"):
		drink.queue_free()
