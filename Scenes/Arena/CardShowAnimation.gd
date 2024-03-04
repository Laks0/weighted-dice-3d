extends AnimationPlayer

var effects : Array

func _ready():
	for i in range(6):
		get_node_or_null("Card%s/EffectName" % i).text = "%s. %s" % [i+1, effects[i].effectName]
	
	play("ShowCards", -1, .5)
