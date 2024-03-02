extends Effect

@export var oliveResource : PackedScene

const OLIVE_AMOUNT = 5

var olives : Array

func start():
	$Startup.play()
	
	for _i in range(OLIVE_AMOUNT):
		var pos := arena.getRandomPosition(1, .2)
		
		var olive = oliveResource.instantiate()
		olive.position = pos
		arena.add_child(olive)
		
		olives.append(olive)

func end():
	for olive in olives:
		if not is_instance_valid(olive):
			continue
		olive.queue_free()
