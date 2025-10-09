extends Bet
class_name MostJumpsBet

func _init():
	betName = "Más saltos"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a saltar más esta ronda?"
	_resultTextSingular = "%s saltó más"
	_resultTextPlural = "%s saltaron más"
	
	_rowInDefaultSlotWheelImage = 7
	
	videoGuide.file = ("res://Scenes/NewBetShow/BetGuides/BetGuide_MasSaltos.ogv")

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.jumping.jumpStarted.connect(func ():
			_scores[mon.player.id] += 1)
	
	super(arena)
