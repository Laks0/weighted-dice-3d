extends Node

var straigtToArena : bool = false

var onlyBet : Bet = null
var onlyEffect : String = ""

var skipCardAnimation : bool = false

var dontStartGame := false

var dropAllChips := false

var inmortalMonigotes := false

func _process(delta):
	if Input.is_action_just_pressed("ui_mute_ost"):
		AudioServer.set_bus_mute(1, !AudioServer.is_bus_mute(1))
	if Input.is_action_just_pressed("ui_mute_sfx"):
		AudioServer.set_bus_mute(2, !AudioServer.is_bus_mute(2))
