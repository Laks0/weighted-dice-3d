extends Effect

@export var drinkScene : PackedScene
@export var drinksAmount : int = 3

func start():
	for _i in range(drinksAmount):
		var drink = drinkScene.instantiate()
		drink.position = arena.getRandomPosition()
		arena.add_child(drink)

func end():
	for drink in get_tree().get_nodes_in_group("Drinks"):
		drink.queue_free()
