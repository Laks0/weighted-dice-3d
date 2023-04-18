extends Control

func effectStarted(effectName : String):
	$EffectName.text = effectName
	
	var tween = create_tween()
	tween.tween_property($EffectName, "modulate", Color.WHITE, .5)
	tween.tween_interval(2)
	tween.tween_property($EffectName, "modulate", Color.TRANSPARENT, .5)
