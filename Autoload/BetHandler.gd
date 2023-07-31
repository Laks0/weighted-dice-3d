extends Node

var bets : Array[Bet]

const firstToDie := preload("res://Autoload/Bets/FirstToDie.gd")

var currentBet : Bet

var round : int = 0

func _ready():
	bets = [
		firstToDie.new()
	]

func startGame(arena : Arena):
	if currentBet == null:
		startRound()
	
	currentBet.startGame(arena)

func startRound() -> void:
	round += 1
	
	currentBet = bets.pick_random()

func getCandidates():
	var allPlayers = PlayerHandler.getPlayersAliveById()
	
	match currentBet.betType:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return allPlayers
	
	return []

func canBet(playerId : int, candidate) -> bool:
	if currentBet.betType == Bet.BetType.EXCLUDE_SELF:
		return candidate != playerId
	
	return true

func getMinimunBet():
	return round * 2

func settleBet() -> void:
	currentBet.settle()

func hasWon(res) -> bool:
	return currentBet.hasWon(res)
