extends Effect

@export var oliveResource : PackedScene

const OLIVE_AMMOUNT = 5

func start():
	for _i in range(OLIVE_AMMOUNT):
		var pos := Globals.getRandomArenaPosition()
		
		var olive = oliveResource.instantiate()
		olive.position = pos
		arena.add_child(olive)
