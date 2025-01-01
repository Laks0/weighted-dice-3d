extends Node

var vars := {
	"onlyBet" : null,
	"onlyEffect" : "",
	"skipCardAnimation" : false,
	"dontStartGame" : false,
	"dropAllChips" : false,
	"inmortalMonigotes" : false
}

func _ready():
	LimboConsole.register_command(_setVar, "set", "Cambia el valor de una variable de debug")
	LimboConsole.add_argument_autocomplete_source("set", 1, func(): return vars.keys())
	
	LimboConsole.register_command(_printVars, "printVars", "Imprime los nombres y valores de las variables de debug")

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

func _process(_delta):
	if Input.is_action_just_pressed("ui_mute_ost"):
		AudioServer.set_bus_mute(1, !AudioServer.is_bus_mute(1))
	if Input.is_action_just_pressed("ui_mute_sfx"):
		AudioServer.set_bus_mute(2, !AudioServer.is_bus_mute(2))
