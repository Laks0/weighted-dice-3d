extends StaticBody3D
class_name BetBooth

var candidate : int = 0

func _ready():
	# DEBUG. Por ahora asumo que todos los candidatos son jugadores
	var player : PlayerHandler.Player = PlayerHandler.getPlayerById(candidate)
	$Name.text = player.name
	$Name.modulate = player.color

## La cantidad de fichas que puso un jugador dado en el candidato del booth
func getChips(playerId : int) -> int:
	if !BetHandler.canBet(playerId, candidate):
		return 0
	
	var overlapingBodies = $Area3D.get_overlapping_bodies()
	var chips = 0
	for body in overlapingBodies:
		if not body is BettingChip:
			continue
		
		var chip := body as BettingChip
		if chip.getPlayerId() == playerId \
			and BetHandler.canBet(playerId, candidate):
			chips += 1
	
	return chips
