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
		playerPile.scale = Vector3.ONE * 1.3
		add_child(playerPile)
		
		piles[player.id] = playerPile
		
		i += 1
	reset()

func addChipToPlayer(id : int) -> void:
	piles[id].addChip(id)

func removeChipFromPlayer(id : int) -> void:
	piles[id].removeChip(id)

func reset():
	for pile in piles.values():
		pile.displayBank()
