extends Node

enum Bets {
	FirstToDie,
	MostGrabs,
	GameTime,
	LastEffect
}

# Tipos de resultados posibles
enum Candidates {
	AllPlayers,
	ExcludeSelf,
	Time,
	DieResult
}
var candidates : int

var currentBet   : int
var currentRound : int = 0

const MAX_ROUNDS = 4

func startRandomBet():
	currentBet = randi() % len(Bets)
	
	if currentBet == Bets.MostGrabs:
		candidates = Candidates.AllPlayers
	elif currentBet == Bets.FirstToDie:
		candidates = Candidates.ExcludeSelf
	elif currentBet == Bets.GameTime:
		candidates = Candidates.Time
	elif currentBet == Bets.LastEffect:
		candidates = Candidates.DieResult

# +apuesta * odds si gana la apuesta general
# +apuesta si gana la partida
# -apuesta si no gana nada
func settleBet(lastStandingId : int):
	var betResults : PackedInt32Array
	
	if currentBet == Bets.MostGrabs:
		betResults = mostGrabsSettle()
	elif currentBet == Bets.FirstToDie:
		betResults = firstToDieSettle()
	elif currentBet == Bets.GameTime:
		betResults = gameTimeSettle()
	elif currentBet == Bets.LastEffect:
		betResults = lastEffectSettle()
	
	for player in PlayerHandler.players:
		if !player.isStillPlaying():
			continue
		
		var expectedResult = player.bettingOn
		if player.id != lastStandingId and not expectedResult in betResults:
			player.bank -= player.betAmount
			continue

		if player.id == lastStandingId:
			player.bank += player.betAmount

		var odds = 2
		if expectedResult in betResults:
			player.bank += player.betAmount * odds
	
	# Resetear los contadores
	for player in PlayerHandler.players:
		player.grabs = 0
	PlayerHandler.firstToDie = -1

func getCurrentBetName() -> String:
	return Bets.keys()[currentBet]

func getCandidates(playerId : int):
	var ids := []
	for p in PlayerHandler.players:
		if p.isStillPlaying():
			ids.append(p.id)
	
	if candidates == Candidates.AllPlayers:
		return ids
	if candidates == Candidates.ExcludeSelf:
		ids.erase(playerId)
		return ids
	if candidates == Candidates.Time:
		return [10, 20, 30, 40, 50, 60, 70, 80]
	if candidates == Candidates.DieResult:
		return [1, 2, 3, 4, 5, 6]

func areCandidatesPlayers() -> bool:
	return candidates == Candidates.AllPlayers or candidates == Candidates.ExcludeSelf

func nextRound():
	currentRound += 1

	for player in PlayerHandler.players:
		player.usingPower = false

func resetRounds():
	currentRound = 0

func getMinimunBet() -> int:
	return currentRound * 2

#### Funciones de Settle ####

## MostGrabs ##
func mostGrabsSettle() -> PackedInt32Array:
	var maxGrabs = 0
	for player in PlayerHandler.players:
		if player.grabs >= maxGrabs:
			maxGrabs = player.grabs
	
	var winners : PackedInt32Array = []
	for player in PlayerHandler.players:
		if player.grabs == maxGrabs:
			winners.append(player.id)
	return winners

func firstToDieSettle() -> PackedInt32Array:
	return [PlayerHandler.firstToDie] as PackedInt32Array

var gameTime : int
func gameTimeSettle() -> PackedInt32Array:
	var times  : PackedInt32Array = []
	for p in PlayerHandler.players:
		times.append(p.bettingOn)
	
	var winner : PackedInt32Array = []
	
	var minDistance : int = 10000
	for c in times:
		var dist = abs(gameTime - c)
		if dist > minDistance:
			continue
		minDistance = dist
		winner = [c]

	return winner

var lastEffect : int
func lastEffectSettle() -> PackedInt32Array:
	return [lastEffect] as PackedInt32Array
