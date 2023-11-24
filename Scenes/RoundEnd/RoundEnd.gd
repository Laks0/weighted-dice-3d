extends Control

@export var LeaderboardEntryScene : PackedScene

func _ready():
	$Title.text = "ROUND " + str(BetHandler.round)
	var winner := PlayerHandler.getPlayerById(BetHandler.lastWinner)
	$Winner.text = "Winner: " + winner.name
	$Winner.modulate = winner.color
	
	var board = PlayerHandler.getPlayersInOrder()
	for i in range(board.size()):
		var player : PlayerHandler.Player = board[i]
		var entry : LeaderboardEntry = LeaderboardEntryScene.instantiate()
		entry.setup(player, i+1)
		$Leaderboard.add_child(entry)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		_on_next_round_pressed()

func _on_next_round_pressed():
	get_tree().change_scene_to_file("res://Scenes/BettingScreen/BettingScreen.tscn")
