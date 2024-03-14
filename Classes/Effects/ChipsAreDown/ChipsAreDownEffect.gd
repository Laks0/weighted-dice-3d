extends Effect

@export var chipResource : PackedScene

func start():
	$Cooldown.start()

func end():
	for c in get_tree().get_nodes_in_group("Chips"):
		c.queue_free()
	$Cooldown.stop()

func createChip():
	if not MultiplayerHandler.isAuthority():
		return
	
	spawnChip.rpc(arena.getRandomPosition())

@rpc("authority", "reliable", "call_local")
func spawnChip(pos : Vector3):
	var chip = chipResource.instantiate()
	
	chip.position = pos
	chip.position.y = 10
	
	arena.add_child(chip, true)
