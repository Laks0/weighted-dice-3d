extends HBoxContainer
class_name LeaderboardEntry

@export var up : CompressedTexture2D
@export var down : CompressedTexture2D
@export var nil : CompressedTexture2D

func setup(player: PlayerHandler.Player, pos : int):
	var bankDif = player.bank - player.oldBank
	var posDif = pos - player.oldRank
	
	$Pos.text = str(pos) + ". "

	$Name.text = player.name
	$Name.modulate = player.color

	var changePrefix : String
	if bankDif >= 0:
		changePrefix = "+"
	$Change.text = " (" + changePrefix + str(bankDif) + ")"
	if bankDif > 0:
		$Change.modulate = Color.GREEN
	elif bankDif < 0:
		$Change.modulate = Color.RED

	$Bank.text = str(player.bank)

	if posDif < 0:
		$Trend.texture = up
	elif posDif > 0:
		$Trend.texture = down
	else:
		$Trend.texture = nil
