extends Control
class_name ArenaHUD

@export var arena : Arena
var time = 0.0

func _ready():
	arena.connect("effectStarted", effectStarted)
	
	if BetHandler.currentBet is MostGrabsBet or BetHandler.currentBet is LeastGrabsBet:
		$MostGrabsDisplay.start(arena)
		$MostGrabsDisplay.visible = true
	elif BetHandler.currentBet is GameTimeBet:
		$GameTime.visible = true

func effectStarted(effect : Effect):
	$EffectName.text = effect.effectName
	
	var tween = create_tween()
	tween.tween_property($EffectName, "modulate", Color.WHITE, .5)
	tween.tween_interval(2)
	tween.tween_property($EffectName, "modulate", Color.TRANSPARENT, .5)

func _process(delta):
	time += delta
	$GameTime.text = "%04.1f" % time
