extends Node

var vars := {
	"onlyBet" : null,
	"onlyEffect" : "",
	"onlyEffectNumber": 0,
	"skipCardAnimation" : false,
	"skipLobby" : false,
	"dontStartGame" : false,
	"dropAllChips" : false,
	"inmortalMonigotes" : false
}

func _ready():
	LimboConsole.register_command(_setVar, "set", "Cambia el valor de una variable de debug. Para ver variables posibles usar listarVars")
	LimboConsole.add_argument_autocomplete_source("set", 1, func(): return vars.keys())
	
	LimboConsole.register_command(_printVars, "listarVars", "Imprime los nombres y valores de las variables de debug")
	
	LimboConsole.register_command(_killMonigote, "matarMonigote", "Matar a un monigote que exista, si no se pasa una skin se mata a todos")
	LimboConsole.add_argument_autocomplete_source("matarMonigote", 1, func ():
		return get_tree().get_nodes_in_group("Monigotes")\
			.map(func(m : Monigote): return m.player.name)
	)
	
	LimboConsole.register_command(newGame, "nuevaPartida", "Empieza una nueva partida generando una cantidad de jugadores")
	
	LimboConsole.register_command(_setNewBet, "unicaApuesta", "Establece una apuesta como la única posible y empieza la partida desde la ronda 1")
	LimboConsole.add_argument_autocomplete_source("unicaApuesta", 1, func ():
		return BetHandler.bets.map(func(b : Bet): return b.betName))
	LimboConsole.register_command(_listBets, "listarApuestas", "Lista los nombres de apuesta posibles")
	
	LimboConsole.register_command(_printEffects, "listarEfectos", "Los nombres de los efectos")
	LimboConsole.register_command(_setOnlyEffect, "unicoEfecto", "Pone un efecto como el único posible (para la lista de posibles usar listarEfectos)")
	LimboConsole.add_argument_autocomplete_source("unicoEfecto", 1, func(): return _getEffectList())
	
	LimboConsole.register_command(_setBank, "cambiarFichas", "Camba las fichas de un jugador")
	LimboConsole.add_argument_autocomplete_source("cambiarFichas", 1, func ():
		return PlayerHandler.getPlayersAlive().map(func (p): return p.name)
	)
	
	LimboConsole.register_command(_changeRound, "cambiarRonda", "Cambia la ronda actual de la partida")

func _setVar(varName : String, val):
	if varName == "onlyBet" or varName == "onlyEffect":
		LimboConsole.error("Esta variable se cambia desde otro comando")
		return
	vars[varName] = val

func _printVars():
	for k in vars.keys():
		if k == "onlyBet" and vars[k] != null:
			LimboConsole.info(k + ": " + vars[k].betName)
			continue
		LimboConsole.info(k + ": " + str(vars[k]))

func _killMonigote(playerName : String = ""):
	var monigotes := get_tree().get_nodes_in_group("Monigotes")
	var aMatar := monigotes.filter(func(m : Monigote): 
		return m.player.name == playerName)
	
	if aMatar.size() != 0:
		aMatar[0].die()
		return
	for m : Monigote in monigotes:
		m.die()

func newGame(players : int, skipLobby := true, skipCards := true, dontStartGame := false):
	PlayerHandler.deleteAllPlayers()
	_createDebugPlayers(players)
	vars.skipCardAnimation = skipCards
	vars.skipLobby = skipLobby
	vars.dontStartGame = dontStartGame
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen/LoadingScreen.tscn")
	LimboConsole.close_console()

func _createDebugPlayers(amount : int) -> void:
	amount = min(6, amount)
	var skins = PlayerHandler.Skins.values()
	for i in range(amount):
		var skin = skins.pick_random()
		skins.erase(skin)
		var controller = Controllers.KB
		if i == 1:
			controller = Controllers.KB2
		
		PlayerHandler.createPlayer(controller, skin)

func _setNewBet(betName : String):
	for b : Bet in BetHandler.bets:
		if b.betName != betName:
			continue
		vars.onlyBet = b
		break

func _listBets():
	for b : Bet in BetHandler.bets:
		LimboConsole.info(b.betName)

func _getEffectList() -> Array[String]:
	var arr : Array[String] = []
	for dir in DirAccess.get_directories_at("res://Classes/Effects"):
		for file in DirAccess.get_files_at("res://Classes/Effects/%s" % dir):
			if not file.contains("Effect"):
				continue
			arr.push_back(file.split("Effect")[0])
			break
	return arr

func _printEffects():
	for s in _getEffectList():
		LimboConsole.info(s)

func _setOnlyEffect(effectName : String, dieNumber : int = 1):
	if dieNumber >= 1 and dieNumber <= 6:
		Debug.vars.onlyEffectNumber = dieNumber - 1
	
	for dir in DirAccess.get_directories_at("res://Classes/Effects"):
		for file in DirAccess.get_files_at("res://Classes/Effects/%s" % dir):
			if file.begins_with(effectName) and file.ends_with(".tscn"):
				vars.onlyEffect = "res://Classes/Effects/" + dir + "/" + file
				return

func _setBank(playerName : String, newBank : int):
	var player := PlayerHandler.getPlayerByName(playerName)
	if player == null:
		LimboConsole.error("No existe un jugador que se llame %s" % playerName)
		return
	player.bank = newBank

func _changeRound(round : int):
	BetHandler.round = round

func _process(_delta):
	if Input.is_action_just_pressed("ui_mute_ost"):
		AudioServer.set_bus_mute(1, !AudioServer.is_bus_mute(1))
	if Input.is_action_just_pressed("ui_mute_sfx"):
		AudioServer.set_bus_mute(2, !AudioServer.is_bus_mute(2))
