extends Node

## Al principio de cada ronda se tiene que llamar startRound()
## settleBet() reparte las apuestas una vez determinado el candidato ganador
## se tiene que llamar mientras la arena sigue viva porque usa información de ahí

var bets : Array[Bet]

var currentBet : Bet
var _lastBet : Bet

@warning_ignore("shadowed_global_identifier")
var round : int = 0
var roundAmount : int = 4

var inArena := false

# Automáticamente usa todas las apuestas en betPath
func _ready():
	var betPath := "res://Autoload/Bets/"
	for fileName in DirAccess.get_files_at(betPath):
		if fileName == "Bet.gd":
			continue
		
		bets.append(load(betPath+fileName).new())

## Empieza la ronda de arena
func startGame(arena : Arena):
	if currentBet == null:
		startRound()
	
	currentBet.startGame(arena)
	inArena = true

## Empieza la ronda de apuestas
func startRound() -> void:
	round += 1
	
	if DebugVars.onlyBet != null:
		currentBet = DebugVars.onlyBet
		currentBet.startRound()
		return
	
	# Si se reelige la misma apuesta que antes hay solo un 5% de chances de dejarla
	while currentBet == _lastBet:
		currentBet = bets.pick_random()
		while not currentBet.canAppear():
			currentBet = bets.pick_random()
		
		if randf() < .2:
			break
	_lastBet = currentBet
	
	currentBet.startRound()
	
	if PlayerHandler.isGameOnline and multiplayer.get_unique_id() == 1:
		_syncBet.rpc(currentBet.betName, round)

@rpc("authority", "reliable")
func _syncBet(betName : String, currentRound : int):
	currentBet = bets.filter(func (bet : Bet): return bet.betName == betName)[0]
	round = currentRound
	currentBet.startRound()

func getBetName() -> String:
	return currentBet.betName

func getCandidates() -> Array:
	return currentBet.getCandidates()

func getWinnerCandidates() -> Array:
	return currentBet.getWinnerCandidates()

func getCandidateName(candidate) -> String:
	return currentBet.getCandidateName(candidate)

func getCandidateColor(candidate) -> Color:
	return currentBet.getCandidateColor(candidate)

func getCandidateOdds(candidate) -> int:
	return currentBet.getCandidateOdds(candidate)

func getCandidatesInOrder() -> Array:
	return currentBet.getCandidatesInOrder()

func getScores() -> Dictionary:
	return currentBet.getScores()

func getCandidateScore(candidate) -> float:
	if not currentBet.getScores().has(candidate):
		return 0
	return currentBet.getScores()[candidate]

func canBet(playerId : int, candidate) -> bool:
	return currentBet.canBet(playerId, candidate)

func getMinimunBet():
	return 1 #round * 2

## La cantidad de fichas que ganó el jugador con sus apuestas esta ronda
func getPlayerBetWinnings(playerId : int) -> int:
	var player := PlayerHandler.getPlayerById(playerId)
	var res : int = 0
	for candidate in getWinnerCandidates():
		var odds = getCandidateOdds(candidate)
		res += player.getAmountBettedOn(candidate) * odds
	return res

## Cuántas fichas gana el sobreviviente de la ronda
func getRoundPrize() -> int:
	return round * 2

## Determina el resultado de la apuesta y premia/castiga a los jugadores
func settleBet(winnerId : int) -> void:
	# Settle
	currentBet.settle()
	
	for player in PlayerHandler.getPlayersAlive():
		player.bank -= player.getTotalBets()
		# Por si acaso
		player.bank = max(player.bank, 0)
		player.bank += getPlayerBetWinnings(player.id)
		if player.id == winnerId:
			player.bank += getRoundPrize()
	inArena = false

func hasWon(res) -> bool:
	var d = currentBet.hasWon(res)
	return d

func arenaUpdate(delta):
	currentBet.arenaUpdate(delta)
