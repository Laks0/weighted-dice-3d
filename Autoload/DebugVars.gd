extends Node

var straigthToArena : bool = false

var onlyBet : Bet = null
var onlyEffect : String = ""

var skipCardAnimation : bool = false

var dontStartGame := false

var dropAllChips := false

var inmortalMonigotes := false
func _switchInmortal(v : bool):
	inmortalMonigotes = v

func _ready():
	LimboConsole.register_command(_switchInmortal, "monigotesInmortales", "Cambia la inmortalidad de los monigotes")

func _process(_delta):
	if Input.is_action_just_pressed("ui_mute_ost"):
		AudioServer.set_bus_mute(1, !AudioServer.is_bus_mute(1))
	if Input.is_action_just_pressed("ui_mute_sfx"):
		AudioServer.set_bus_mute(2, !AudioServer.is_bus_mute(2))
