extends Control

@export var LeaderboardEntryScene : PackedScene

var gameEnded := false

func _ready():
	if BetHandler.round == BetHandler.roundAmount or PlayerHandler.getPlayersAlive().size() <= 1:
		gameEnded = true
		$Title.text = "GAME SETTLED"
		$Title.modulate = Color.ORANGE
		$NextRound.text = "Play again"
	else:
		$Title.text = "ROUND " + str(BetHandler.round)
	
	var winner := PlayerHandler.getPlayerById(BetHandler.lastWinner)
	$Winner.text = "Round winner: " + winner.name
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
	if gameEnded:
		get_tree().change_scene_to_file("res://Scenes/CharacterScreen/CharacterScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/BettingScreen/BettingScreen.tscn")
