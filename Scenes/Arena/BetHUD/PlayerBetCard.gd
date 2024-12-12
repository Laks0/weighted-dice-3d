extends VBoxContainer
class_name PlayerBetCard

var player : PlayerHandler.Player = null

func setPlayer(id : int):
	$TextureRect.texture.region.position.x = id * $TextureRect.texture.region.size.x
	player = PlayerHandler.getPlayerById(id)
	$NameLabel.text = player.name

func _process(_delta):
	if player == null:
		return
	
	if BetHandler.getScores().has(player.id):
		var isWinning = BetHandler.getCandidatesOnFirst().has(player.id)
		$TextureRect.modulate.v = 1 if isWinning else .5
