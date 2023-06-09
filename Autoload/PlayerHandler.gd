extends Node

enum Skins {RED, BLUE, YELLOW, GREEN}

class Player:
	var id : int
	var name : String
	var inputController : int
	var bank : int = 10
	var betAmount : int = 0
	var bettingOn
	var color : Color
	
	var grabs : int = 0 # Para el resultado de MostGrabs

	const MAX_POWERS : int  = 2
	var powersUsed : int  = 0
	var usingPower : bool = false
	
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

	func setBet(amount : int, expect : int):
		betAmount = amount
		bettingOn = expect
	
	func isStillPlaying() -> bool:
		return bank >= BetHandler.getMinimunBet()

	func usePower():
		if powersUsed >= MAX_POWERS:
			return

		powersUsed += 1
		usingPower = true

var players = []

func createPlayer(controller : int, id : int, _name : String):
	var MAX_PLAYERS = 4
	if len(players) >= MAX_PLAYERS:
		return

	players.append(Player.new(_name, controller, id))

func getPlayerById(id : int) -> Player:
	for p in players:
		if p.id == id:
			return p

	return null

func getPlayerByIndex(index : int) -> Player:
	return players[index]

func getPlayersInOrder() -> Array:
	var list = []
	
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

func deleteAllPlayers():
	players = []

func resetAllPlayers():
	for i in range(len(players)):
		var p : Player = players[i]
		players[i] = Player.new(p.name, p.inputController, p.id)

