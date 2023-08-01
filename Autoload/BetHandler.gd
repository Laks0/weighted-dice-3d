extends Node

var bets : Array[Bet]

const firstToDie := preload("res://Autoload/Bets/FirstToDie.gd")
const mostGrabs := preload("res://Autoload/Bets/MostGrabs.gd")

var currentBet : Bet

var round : int = 0

func _ready():
	bets = [
		firstToDie.new(),
		mostGrabs.new(),
	]

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

func getCandidates():
	var allPlayers = PlayerHandler.getPlayersAliveById()
	
	match currentBet.betType:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return allPlayers
	
	return []

func getCandidateOdds(candidate) -> int:
	return currentBet.getCandidateOdds(candidate)

func canBet(playerId : int, candidate) -> bool:
	if currentBet.betType == Bet.BetType.EXCLUDE_SELF:
		return candidate != playerId
	
	return true

func getMinimunBet():
	return round * 2

## Determina el resultado de la apuesta y premia/castiga a los jugadores
func settleBet(winnerId : int) -> void:
	currentBet.settle()
	
	for player in PlayerHandler.getPlayersAlive():
		for candidate in getCandidates():
			var odds = getCandidateOdds(candidate)
			player.bank -= player.getAmountBettedOn(candidate)
			if (hasWon(candidate)):
				player.bank += player.getAmountBettedOn(candidate) * odds
		
		if player.id == winnerId:
			player.bank += round * 2

func hasWon(res) -> bool:
	return currentBet.hasWon(res)
