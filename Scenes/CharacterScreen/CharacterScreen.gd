extends Control

func _ready():
	randomize()
	PlayerHandler.deleteAllPlayers()
	BetHandler.round = 0

func _on_start_pressed():
	for c in $GridContainer.get_children():
		if !c.added:
			continue
		
		PlayerHandler.createPlayer(c.controller, c.skin, c.nameEditor.text)
	
	get_tree().change_scene_to_file("res://Scenes/Arena/Arena2d.tscn")
