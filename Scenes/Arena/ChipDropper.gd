extends Node

@export var dropChance := .25 # Las probabilidades de un drop en una ronda

@export var chipDrop : PackedScene
@onready var arena : Arena = get_parent()

func onGameStarted():
	if randf() > dropChance and not DebugVars.dropAllChips:
		return
	
	# La ficha va a aparecer entre el segundo 5 y el 15
	var time := 5 + 10 * randf()
	if DebugVars.dropAllChips:
		time = 0
	
	await get_tree().create_timer(time).timeout
	if not arena.gameRunning:
		return
	
	var chip := chipDrop.instantiate()
	chip.bonus = BetHandler.round
	chip.position = arena.getRandomPosition(1, 0)
	arena.add_child(chip)
	
	arena.gameEnded.connect(func (_winner):
		if not is_instance_valid(chip):
			return
		chip.queue_free())
