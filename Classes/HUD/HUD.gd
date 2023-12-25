extends Control
class_name ArenaHUD

@export var arena : Arena

func _ready():
	arena.connect("effectStarted", effectStarted)
	
	if BetHandler.currentBet is MostGragsBet:
		$MostGrabsDisplay.start(arena)
		$MostGrabsDisplay.visible = true

func effectStarted(effect : Effect):
	$EffectName.text = effect.effectName
	
	var tween = create_tween()
	tween.tween_property($EffectName, "modulate", Color.WHITE, .5)
	tween.tween_interval(2)
	tween.tween_property($EffectName, "modulate", Color.TRANSPARENT, .5)
