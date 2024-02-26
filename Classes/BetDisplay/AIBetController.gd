extends Node

@onready var betDisplay : BetDisplaySimple = get_parent()

func _process(_delta):
	for player in PlayerHandler.getPlayersAlive():
		if player.inputController != Controllers.AI:
			continue

		if not betDisplay.isReady[player.id]:
			betDisplay.playerReady(player.id)
