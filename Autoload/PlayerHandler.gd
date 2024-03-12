extends Node

signal playersSynced

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
	
	var multiplayerId : int
	
	func _init(_name : String, _inputController :int = Controllers.KB,_id : int = Skins.RED, _multiplayerId : int = -1):
		name = _name
		inputController = _inputController
		id = _id
		multiplayerId = _multiplayerId
		
		color = PlayerHandler.getSkinColor(id)
		
		if name == "":
			name = PlayerHandler.getSkinName(id)
	
	func setBet(amount : int, candidate : int):
		bets[candidate] = amount
	
	func increaseBet(candidate : int):
		bets[candidate] += 1
	
	func decreaseBet(candidate : int):
		bets[candidate] -= 1
	
	func getAmountBettedOn(candidate : int) -> int:
		if not bets.has(candidate):
			return 0
		
		return bets[candidate]
	
	func getTotalBets() -> int:
		return bets.values().reduce(func (accum, number): return accum + number)
	
	func isStillPlaying() -> bool:
		return bank >= BetHandler.getMinimunBet()

var players : Array[Player] = []
var MAX_PLAYERS = 6

func createPlayer(controller : int, id : int, _name : String = "", multiplayerId : int = 1):
	if len(players) >= MAX_PLAYERS:
		return

	players.append(Player.new(_name, controller, id, multiplayerId))

func instantiatePlayers() -> Array[Monigote]:
	var monigotes : Array[Monigote] = []
	for player in getPlayersAlive():
		var monigote := monigoteResource.instantiate() as Monigote
		
		monigote.name = str(player.id)
		
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

## Devuelve una lista con los jugadores ordenados de mayor a menor cantidad de fichas incluyendo a los que ya perdieron
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

## Dado un diccionario de peers crea jugadores para todos los peers con una skin asignada.
## Espera un diccionario donde las claves son la id del cliente y las definiciones tienen
## campos "name" y "controller". Solo llamar esta función si ya está armado el sistema de conexión
func createAllOnlinePlayers(connectedPlayers : Dictionary):
	# Solo la puede llamar la autoridad
	if not multiplayer.is_server():
		return
	
	var data : Dictionary = {}
	var allSkins = Skins.values()
	for id in connectedPlayers.keys():
		var playerInfo = connectedPlayers[id]
		var randomSkin = allSkins.pick_random()
		allSkins.erase(randomSkin)
		data[id] = {
			"controller": playerInfo["controller"],
			"skin": randomSkin,
			"name": playerInfo["name"],
			"id": id
		}
	
	_syncPlayers.rpc(data)

@rpc("authority", "reliable", "call_local")
func _syncPlayers(playersData : Dictionary):
	deleteAllPlayers()
	for data in playersData.values():
		createPlayer(data["controller"], data["skin"], data["name"], data["id"])
	playersSynced.emit()

func getSkinName(skin : Skins) -> String:
	match skin:
		Skins.RED:    return "Tomi"
		Skins.BLUE:   return "Fran"
		Skins.YELLOW: return "Pedro"
		Skins.GREEN:  return "Juan"
		Skins.ORANGE: return "Male"
		Skins.PURPLE: return "Marta"
	return ""

var skinColors = {
	Skins.RED: Color(1,0,0),
	Skins.BLUE: Color(.1,.1,1),
	Skins.YELLOW: Color(1,1,0),
	Skins.GREEN: Color(0,.7,.3),
	Skins.ORANGE: Color(1,.5,.3),
	Skins.PURPLE: Color(0.5,.25,.5)
}

func getSkinColor(skin : Skins) -> Color:
	return skinColors[skin]

func createDebugPlayers(amount : int) -> void:
	var skins = Skins.values()
	for i in range(amount):
		var skin = skins.pick_random()
		skins.erase(skin)
		var controller = Controllers.AI
		if i == 0:
			controller = Controllers.KB
		elif i == 1:
			controller = Controllers.KB2
		
		createPlayer(controller, skin)
