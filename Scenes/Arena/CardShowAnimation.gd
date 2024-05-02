extends AnimationPlayer

var effects : Array
var arena : Arena

func _ready():
	for i in range(6):
		var card : DisplayCard = get_node("Card%s" % (i+1))
		card.setEffect(i+1, effects[i].effectName, effects[i].cardTexture)
	
	play("ShowCards")
	arena.lightsOff()
	arena.fogOn()

func startExit():
	arena.lightsOn()
	arena.fogOff()
	
	var tween := create_tween()
	tween.tween_property($SpotLight3D, "light_energy", 0, .2)
