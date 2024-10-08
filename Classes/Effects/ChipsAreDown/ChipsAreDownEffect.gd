extends Effect

@export var chipResource : PackedScene

func start():
	$Cooldown.start()

func end():
	$Cooldown.stop()

func createChip():
	var chip = chipResource.instantiate()
	
	chip.position = arena.getRandomPosition()
	chip.position.y = 10
	
	arena.add_child(chip)
