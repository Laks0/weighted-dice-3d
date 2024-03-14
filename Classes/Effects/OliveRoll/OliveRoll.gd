extends Effect

@export var oliveResource : PackedScene

const OLIVE_AMOUNT = 5

var olives : Array

func start():
	$Startup.play()
	
	if not MultiplayerHandler.isAuthority():
		return
	
	for _i in range(OLIVE_AMOUNT):
		var pos := arena.getRandomPosition(1, .2)
		spawnOlive.rpc(pos, randf_range(-PI, PI))

@rpc("authority", "reliable", "call_local")
func spawnOlive(pos : Vector3, rotation : float):
	var olive = oliveResource.instantiate()
	olive.position = pos
	olive.rotation.y = rotation
	arena.add_child(olive, true)
	
	olives.append(olive)

func end():
	for olive in olives:
		if not is_instance_valid(olive):
			continue
		olive.queue_free()
