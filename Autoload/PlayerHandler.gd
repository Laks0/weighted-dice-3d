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
	
	var roundBonus : int = 0 # Fichas de bonus que puede ganar en una ronda
	
	var grabs : int = 0 # Para el resultado de MostGrabs
	
	var soundBites : Dictionary
	
	func _init(_name : String, _inputController :int = Controllers.KB,_id : int = Skins.RED):
		name = _name
		inputController = _inputController
		id = _id

		color = PlayerHandler.getSkinColor(id)
		
		if name == "":
			name = PlayerHandler.getSkinName(id)
		
		_createBite("hit")
		_createBite("dead")
		_createBite("grab")
		_createBite("jump")
		_createBite("throwc")
		_createBite("thrown")
		_createBite("salute")
		_createBite("victory")
	
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
		if bets.size() == 0:
			return 0
		return bets.values().reduce(func (accum, number): return accum + number)
	
	func isStillPlaying() -> bool:
		return bank >= BetHandler.getMinimunBet()
	
	func setRoundBonus(bonus : int) -> void:
		roundBonus = bonus
	
	func _createBite(category : String) -> void:
		soundBites[category] = AudioStreamRandomizer.new()
		var bitePath := "res://Assets/SFX/Bites/"
		var prefix := "bite_" + PlayerHandler.getSkinName(id).to_lower() + "_" + category
		for fileName : String in DirAccess.get_files_at(bitePath):
			if not (fileName.begins_with(prefix) and fileName.ends_with(".wav.import")):
				continue
			var newStream = ResourceLoader.load(bitePath+fileName.trim_suffix(".import"))
			if newStream != null:
				soundBites[category].add_stream(soundBites[category].streams_count, newStream)
	
	func getBiteStream(category : String) -> AudioStreamRandomizer:
		return soundBites[category]

var players : Array[Player] = []
var MAX_PLAYERS = 6

func createPlayer(controller : int, id : int, _name : String = ""):
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

func getPlayerByController(controllerId : int) -> Player:
	return players.filter(func (p : Player): return p.inputController == controllerId)[0]

func getPlayerByName(playerName : String) -> Player:
	var list := players.filter(func (p : Player): return p.name == playerName)
	if list.size() == 0:
		return null
	return list[0]

func getPlayerIndex(player : Player) -> int:
	return getPlayersAlive().find(player)

## Devuelve una lista con los jugadores ordenados de mayor a menor cantidad de fichas incluyendo a los que ya perdieron
func getPlayersInOrder() -> Array[Player]:
	var list : Array[Player] = []
	
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

func getWinningPlayers() -> Array[Player]:
	var maxBank = getPlayersInOrder()[0].bank
	return players.filter(func(p : Player): return p.bank == maxBank)

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
