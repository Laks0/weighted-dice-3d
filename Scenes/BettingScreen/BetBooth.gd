extends StaticBody3D
class_name BetBooth

var candidate : int = 0

func _ready():
	$Name.text = BetHandler.getCandidateName(candidate)
	$Name.modulate = BetHandler.getCandidateColor(candidate)

func _process(_delta):
	$Odds.text = "x" + str(BetHandler.getCandidateOdds(candidate))

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
