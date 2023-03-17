extends RichTextLabel

func _ready():
	var players = PlayerHandler.getPlayersInOrder()

	for player in players:
		var color = player.color.to_html(false) 
		if not player.isStillPlaying():
			color = "aaa"

		text += "[color=#" + color + "]"
		text += player.name
		text += "[/color]: "
		text += str(player.bank) + "\n"

