extends Control

@export var settingScene: PackedScene

func _ready():
	BetHandler.nextRound()

	if BetHandler.currentRound > BetHandler.MAX_ROUNDS or PlayerHandler.amountOfPlayersLeft() <= 1:
#		get_tree().change_scene_to_file("res://Escenas/EndScreen/EndScreen.tscn")
		print("Fin")

	$Round.text = "Round " + str(BetHandler.currentRound) + "/" + str(BetHandler.MAX_ROUNDS)
	BetHandler.startRandomBet()
	$CurrentBet.text = BetHandler.getCurrentBetName()
	
	for player in PlayerHandler.players:
		if !player.isStillPlaying():
			continue
		
		var settingInstance = settingScene.instantiate()
		settingInstance.player = player
		
		$HBoxContainer.add_child(settingInstance)

func _process(_delta):
	# Acción de usar el power
	for player in PlayerHandler.players:
		var controllAction = Controllers.controllers[player.inputController]["grab"]
		if Input.is_action_just_pressed(controllAction):
			player.usePower()

func _on_Start_pressed():
	for betSetting in $HBoxContainer.get_children():
		betSetting.player.setBet(betSetting.bet, betSetting.candidate)
	
	get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")
