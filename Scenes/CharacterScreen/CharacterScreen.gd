extends Control

func _ready():
	randomize()

func _on_start_pressed():
	PlayerHandler.deleteAllPlayers()
	for c in $GridContainer.get_children():
		if !c.added:
			continue
		
		PlayerHandler.createPlayer(c.controller, c.skin, c.nameEditor.text)
	
	get_tree().change_scene_to_file("res://Scenes/BettingScreen/BettingScreen.tscn")
