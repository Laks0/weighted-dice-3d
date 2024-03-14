extends AnimationPlayer

var effects : Array

func _ready():
	for i in range(6):
		while effects[i] == null:
			await get_tree().process_frame
		
		get_node_or_null("Card%s/EffectName" % i).text = "%s. %s" % [i+1, effects[i].effectName]
	
	play("ShowCards", -1, .7)
