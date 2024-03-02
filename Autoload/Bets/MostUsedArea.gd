extends Bet
class_name MostUsedAreaBet

var areaUse : Node3D

func _init():
	betType = BetType.CUSTOM
	betName = "Most Used Area"
	_scoreOrder = Order.ASCENDING

enum ArenaSide {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

func startGame(arena : Arena):
	areaUse = load("res://Assets/Bets/AreaUse.tscn").instantiate()
	arena.add_child(areaUse)
	
	super(arena)

# Mientras más apuestan, menos vale. Si apuesta la mitad + 1 no vale nada
func getCandidateOdds(candidate: ArenaSide) -> int:
	var totalPlayers: int = PlayerHandler.getPlayersAlive().size()
	var bettingPlayers: int = 0
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		if player.getAmountBettedOn(candidate) > 0:
			bettingPlayers += 1
	return max(1, totalPlayers/2 - bettingPlayers + 2)

func arenaUpdate(delta):
	areaUse.playersInArea = [.0,.0,.0,.0]
	for mon : Monigote in _arena.getLivingMonigotes():
		var currentArea : ArenaSide
		if mon.position.x < 0 && mon.position.z < 0:
			currentArea = ArenaSide.TOP_LEFT
		elif mon.position.x < 0:
			currentArea = ArenaSide.BOTTOM_LEFT
		elif mon.position.x > 0 && mon.position.z > 0:
			currentArea = ArenaSide.BOTTOM_RIGHT
		else:
			currentArea = ArenaSide.TOP_RIGHT
		_scores[currentArea] += delta
		areaUse.playersInArea[currentArea] += 1

# Ningún jugador puede apostar a más de un candidato
func canBet(playerId : int, candidate) -> bool:
	var player := PlayerHandler.getPlayerById(playerId)
	return player.getTotalBets() == 0 or player.bets[candidate] != 0

func getCandidates() -> Array:
	return ArenaSide.values()

func getCandidateName(side : ArenaSide) -> String:
	match side:
		ArenaSide.TOP_RIGHT: return "Top right"
		ArenaSide.TOP_LEFT: return "Top left"
		ArenaSide.BOTTOM_RIGHT: return "Bottom right"
		ArenaSide.BOTTOM_LEFT: return "Bottom left"
	return ""

func settle():
	if is_instance_valid(areaUse):
		areaUse.queue_free()
	
	super()
