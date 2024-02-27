extends Node

@onready var monigoteResource := preload("res://Classes/Monigotes/Monigote.tscn")

enum Skins {RED, BLUE, YELLOW, GREEN, ORANGE, PURPLE}

class Player:
	var id : int
	var name : String
	var inputController : int
	var bank : int = 5
	var bets : Dictionary
	var color : Color
	
	var grabs : int = 0 # Para el resultado de MostGrabs
	
	# Variables para visualizar cambios en el leaderboard
	var oldBank : int
	var oldRank : int
	
	func _init(_name : String,_inputController :int = Controllers.KB,_id : int = Skins.RED):
		name = _name
		inputController = _inputController
		id = _id

		if id == Skins.RED:
			color = Color(1,0,0)
		elif id == Skins.BLUE:
			color = Color(.1,.1,1)
		elif id == Skins.YELLOW:
			color = Color(1,1,0)
		elif id == Skins.GREEN:
			color = Color(0,.7,.3)
		elif id == Skins.PURPLE:
			color = Color(0.5,.25,.5)
		elif id == Skins.ORANGE:
			color = Color(1,.5,.3)
	
	func setBet(amount : int, candidate : int):
		bets[candidate] = amount
	
	func increaseBet(candidate : int):
		bets[candidate] += 1
	
	func decreaseBet(candidate : int):
		bets[candidate] -= 1
	
	func getAmountBettedOn(candidate : int):
		if not bets.has(candidate):
			return 0
		
		return bets[candidate]
	
	func isStillPlaying() -> bool:
		return bank >= BetHandler.getMinimunBet()

var players : Array[Player] = []
var MAX_PLAYERS = 6

func createPlayer(controller : int, id : int, _name : String):
	if len(players) >= MAX_PLAYERS:
		return

	players.append(Player.new(_name, controller, id))

func instantiatePlayers() -> Array[Monigote]:
	var monigotes : Array[Monigote] = []
	for player in getPlayersAlive():
		var monigote := monigoteResource.instantiate() as Monigote
		
		monigote.player = player
		
		monigotes.append(monigote)
	
	return monigotes

func getPlayerById(id : int) -> Player:
	for p in players:
		if p.id == id:
			return p

	return null

func getPlayerByIndex(index : int) -> Player:
	return players[index]

func getPlayerIndex(player : Player) -> int:
	return getPlayersAlive().find(player)

## Devuelve una lista con los jugadores ordenados de mayor a menor cantidad de fichas
func getPlayersInOrder() -> Array:
	var list = []
	
	# Selection sort
	for _i in range(len(players)):
		var maxBank = -100
		for p in players:
			if p in list:
				continue

			if p.bank > maxBank:
				maxBank = p.bank

		for p in players:
			if p.bank == maxBank:
				list.append(p)

	return list

func amountOfPlayersLeft() -> int:
	var left = 0
	
	for p in players:
		if p.isStillPlaying():
			left += 1

	return left

var firstToDie : int = -1

func getPlayersAlive() -> Array[Player]:
	return players.filter(func(p : Player): return p.isStillPlaying())

func getPlayersAliveById() -> Array:
	return getPlayersAlive().map(func(p: Player): return p.id)

func deleteAllPlayers():
	players = []

func resetAllPlayers():
	for i in range(len(players)):
		var p : Player = players[i]
		players[i] = Player.new(p.name, p.inputController, p.id)

func getSkinName(skin : Skins) -> String:
	match skin:
		Skins.RED:    return "Tomi"
		Skins.BLUE:   return "Fran"
		Skins.YELLOW: return "Pedro"
		Skins.GREEN:  return "Juan"
		Skins.ORANGE: return "Male"
		Skins.PURPLE: return "Marta"
	return ""
