extends Node

## Al principio de cada ronda se tiene que llamar startRound()
## settleBet() reparte las apuestas una vez determinado el candidato ganador
## se tiene que llamar mientras la arena sigue viva porque usa información de ahí

var bets : Array[Bet]

var currentBet : Bet

@warning_ignore("shadowed_global_identifier")
var round : int = 0
var roundAmount : int = 4

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

## Empieza la ronda de apuestas
func startRound() -> void:
	round += 1
	
	currentBet = bets.pick_random()

func getBetName() -> String:
	return currentBet.betName

func getCandidates() -> Array:
	return Bet.getCandidates(currentBet.betType)

func getCandidateName(candidate) -> String:
	return Bet.getCandidateName(currentBet.betType, candidate)

func getCandidateColor(candidate) -> Color:
	return Bet.getCandidateColor(currentBet.betType, candidate)

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
	if currentBet.betType == Bet.BetType.EXCLUDE_SELF:
		return candidate != playerId
	
	return true

func getMinimunBet():
	return 1 #round * 2

## La cantidad de fichas que ganó el jugador con sus apuestas esta ronda
func getPlayerBetWinnings(playerId : int) -> int:
	var player := PlayerHandler.getPlayerById(playerId)
	var res : int = 0
	for candidate in getCandidates():
		var odds = getCandidateOdds(candidate)
		if (hasWon(candidate)):
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
		player.bank += getPlayerBetWinnings(player.id)
		if player.id == winnerId:
			player.bank += getRoundPrize()

func hasWon(res) -> bool:
	return currentBet.hasWon(res)

func arenaUpdate(delta):
	currentBet.arenaUpdate(delta)
