extends AnimationPlayer

var effects : Array

func _ready():
	for i in range(6):
		var card : DisplayCard = get_node("Card%s" % (i+1))
		card.setEffect(i+1, effects[i].effectName, effects[i].cardTexture)
	
	play("ShowCards")
