extends Control
class_name ArenaHUD

@export var arena : Arena
var time = 0.0

func _ready():
	arena.connect("effectStarted", effectStarted)
	
	if BetHandler.currentBet is GameTimeBet:
		$GameTime.visible = true
		return
	
	if BetHandler.currentBet is MostUsedAreaBet:
		$SidesTime.visible = true
		return
	
	$AttDisplay.start(arena)
	$AttDisplay.visible = true

func effectStarted(effect : Effect):
	$EffectName.text = effect.effectName
	
	var tween = create_tween()
	tween.tween_property($EffectName, "modulate", Color.WHITE, .5)
	tween.tween_interval(2)
	tween.tween_property($EffectName, "modulate", Color.TRANSPARENT, .5)

func _process(delta):
	time += delta
	$GameTime.text = "%04.1f" % time
	
	if BetHandler.currentBet is MostUsedAreaBet:
		$SidesTime/Left.text = "%04.1f" % BetHandler.currentBet.usage[Bet.ArenaSide.LEFT]
		$SidesTime/Right.text = "%04.1f" % BetHandler.currentBet.usage[Bet.ArenaSide.RIGHT]
