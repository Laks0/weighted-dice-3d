extends Bet
class_name MostUsedAreaBet

func _init():
	betType = BetType.ARENA_SIDE
	betName = "Most Used Area"
	_scoreOrder = Order.ASCENDING

# Mientras más apuestan, menos vale. Si apuesta la mitad + 1 no vale nada
func getCandidateOdds(candidate: ArenaSide) -> int:
	var totalPlayers: int = PlayerHandler.getPlayersAlive().size()
	var bettingPlayers: int = 0
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		if player.getAmountBettedOn(candidate) > 0:
			bettingPlayers += 1
	return max(1, totalPlayers/2 - bettingPlayers + 2)

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.position.x < 0:
			_scores[ArenaSide.LEFT] += delta
		else:
			_scores[ArenaSide.RIGHT] += delta

