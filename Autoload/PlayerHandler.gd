extends Node

@onready var monigoteResource := preload("res://Classes/Monigotes/Monigote.tscn")

enum Skins {RED, BLUE, YELLOW, GREEN}

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
			color = Color(0,0,1)
		elif id == Skins.YELLOW:
			color = Color(1,1,0)
		elif id == Skins.GREEN:
			color = Color(0,1,0)
	
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

func createPlayer(controller : int, id : int, _name : String):
	var MAX_PLAYERS = 4
	if len(players) >= MAX_PLAYERS:
		return

	players.append(Player.new(_name, controller, id))

func instantiatePlayers(parent) -> Array[Monigote]:
	var i = 0
	@warning_ignore("unassigned_variable")
	var monigotes : Array[Monigote]
	for player in getPlayersAlive():
		var monigote := monigoteResource.instantiate() as Monigote
		
		monigote.player   = player
		monigote.position = Vector3((i+1) -5, Globals.SPRITE_HEIGHT, 1)
		
		monigotes.append(monigote)
		parent.add_child(monigote)
		i += 1
	
	return monigotes

func getPlayerById(id : int) -> Player:
	for p in players:
		if p.id == id:
			return p

	return null

func getPlayerByIndex(index : int) -> Player:
	return players[index]

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

