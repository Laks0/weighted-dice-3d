extends Node3D
class_name ChipHolder

@export var chipPileScene : PackedScene

var piles : Dictionary

func _ready():
	var i := 0
	for player in PlayerHandler.getPlayersAlive():
		var playerPile = chipPileScene.instantiate()
		playerPile.isDisplay = true
		playerPile.playerIdDisplay = player.id
		playerPile.position = $PilePositions.get_children()[i].position
		add_child(playerPile)
		
		for _l in range(player.bank):
			playerPile.addChip(player.id)
		
		piles[player.id] = playerPile
		
		i += 1

func addChipToPlayer(id : int) -> void:
	piles[id].addChip(id)

func removeChipFromPlayer(id : int) -> void:
	piles[id].removeChip(id)
