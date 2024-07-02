extends Control

@export var startScene : PackedScene

func _ready():
	for i in range(BetHandler.bets.size()):
		var bet : Bet = BetHandler.bets[i]
		$DebugVars/OnlyBet.add_item(bet.betName, i)
		var idx = $DebugVars/OnlyBet.get_item_index(i)
		$DebugVars/OnlyBet.set_item_metadata(idx, bet)

func _on_start_button_pressed():
	SfxHandler.playSound("buttonSelect")
	SoundtrackHandler.playTrack()
	
	DebugVars.skipCardAnimation = $DebugVars/SkipCards.button_pressed
	DebugVars.dontStartGame = $DebugVars/DontStartGame.button_pressed
	
	if $DebugVars/OnlyBet.selected != 0:
		DebugVars.onlyBet = $DebugVars/OnlyBet.get_selected_metadata()
	
	if $DebugVars/StraightToArena.button_pressed:
		PlayerHandler.createDebugPlayers($DebugVars/PlayerN.value)
		DebugVars.straigtToArena = true
		get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")
		return
	
	get_tree().change_scene_to_packed(startScene)
