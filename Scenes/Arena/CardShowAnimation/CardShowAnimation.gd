extends AnimationPlayer

var effects : Array
var environment : WorldEnvironment

func _ready():
	for i in range(6):
		var card : DisplayCard = get_node("Card%s" % (i+1))
		card.setEffect(i+1, effects[i].effectName, effects[i].cardTexture)
	
	play("ShowCards")
	environment.lightsOff()
	environment.fogOn()

func startExit():
	environment.lightsOn()
	environment.fogOff()
	
	var tween := create_tween()
	tween.tween_property($SpotLight3D, "light_energy", 0, .2)
