extends Node

signal pickedNewBet
## Se llama cuando empieza la ronda de arena
signal betStarted

## Al principio de cada ronda se tiene que llamar startRound()
## settleBet() reparte las apuestas una vez determinado el candidato ganador
## se tiene que llamar mientras la arena sigue viva porque usa información de ahí

var bets : Array[Bet]

var currentBet : Bet
var _lastBet : Bet

@warning_ignore("shadowed_global_identifier")
var round : int = 0
var roundAmount : int = 4

var betOngoing := false

## La apuesta dummy que se usa la primera ronda
var emptyBet : Bet = preload("res://Autoload/Bets/Bet.gd").new()

# Automáticamente usa todas las apuestas en betPath
func _ready():
	var betPath := "res://Autoload/Bets/"
	for fileName in DirAccess.get_files_at(betPath):
		if fileName == "Bet.gd":
			continue
		if not fileName.ends_with(".gd"):
			continue
		bets.append(load(betPath+fileName).new())

## Empieza la ronda de arena
func startGame(arena : Arena):
	for p : PlayerHandler.Player in PlayerHandler.players:
		p.setRoundBonus(0)
	
	if currentBet == null:
		startRound()
	
	currentBet.startGame(arena)
	betOngoing = true
	betStarted.emit()

func endGame():
	betOngoing = false

func resetGame():
	round = 0
	if Debug.vars.onlyBet != null:
		round = 1
	currentBet = null
	_lastBet = null

## Empieza la ronda de apuestas
func startRound() -> void:
	round += 1
	
	if Debug.vars.onlyBet != null:
		currentBet = Debug.vars.onlyBet
		currentBet.startRound()
		pickedNewBet.emit()
		return
	if round != 1:
		SoundtrackHandler.playTrack(round)
	# Si se reelige la misma apuesta que antes hay solo un 5% de chances de dejarla
	while currentBet == _lastBet:
		currentBet = bets.pick_random()
		while not currentBet.canAppear():
			currentBet = bets.pick_random()
		
		if randf() < .2:
			break
	
	# En la primera ronda no hay apuestas
	if round == 1:
		currentBet = emptyBet
	
	_lastBet = currentBet
	
	currentBet.startRound()
	pickedNewBet.emit()

func resetRound() -> void:
	currentBet.startRound()

func getBetName() -> String:
	return currentBet.betName

func getBetDescription() -> String:
	return currentBet.betDescription

func getCandidates() -> Array:
	return currentBet.getCandidates()

func getWinnerCandidates() -> Array:
	return currentBet.getWinnerCandidates()

func getCandidatesOnFirst() -> Array:
	return currentBet.getCandidatesOnFirst()

func isCandidateWinning(candidate) -> bool:
	return currentBet.getCandidatesOnFirst().has(candidate)

func getWinnersText() -> String:
	return currentBet.getWinnersText()

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

func getScoreText(candidate) -> String:
	return currentBet.getScoreText(candidate)

## Responde si los candidatos de la apuesta actual se deben interpretar como jugadores
func areCandidatesPlayers() -> bool:
	return currentBet.betType in [Bet.BetType.EXCLUDE_SELF, Bet.BetType.ALL_PLAYERS]

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
		player.bank += player.roundBonus

func hasWon(res) -> bool:
	var d = currentBet.hasWon(res)
	return d

func arenaUpdate(delta):
	if not betOngoing:
		return
	currentBet.arenaUpdate(delta)

func getRandomBet() -> Bet:
	return bets.pick_random()
