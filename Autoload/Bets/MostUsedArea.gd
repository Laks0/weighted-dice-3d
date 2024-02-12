extends Bet
class_name MostUsedAreaBet

func _init():
	betType = BetType.ARENA_SIDE
	betName = "Most Used Area"

var usage : Dictionary

func startGame(arena):
	usage = {
		ArenaSide.LEFT: 0,
		ArenaSide.RIGHT: 0
	}

	super(arena)

# Mientras más apuestan, menos vale. Si apuesta la mitad + 1 no vale nada
func getCandidateOdds(candidate: ArenaSide) -> int:
	var totalPlayers: int = PlayerHandler.getPlayersAlive().size()
	var bettingPlayers: int = 0
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		if player.bets[candidate] > 0:
			bettingPlayers += 1
	return max(1, totalPlayers/2 - bettingPlayers + 2)

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.position.x < 0:
			usage[ArenaSide.LEFT] += delta
		else:
			usage[ArenaSide.RIGHT] += delta

func settle():
	var maxUsage = max(usage[ArenaSide.LEFT], usage[ArenaSide.RIGHT])
	_result = ArenaSide.values().filter(func (side: ArenaSide): return usage[side] == maxUsage)

