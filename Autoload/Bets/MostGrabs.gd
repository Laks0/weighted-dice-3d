extends Bet
class_name MostGrabsBet

func _init():
	betName = "Más agarres"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a agarrar más a los demás esta ronda?"
	_resultTextSingular = "%s agarró más"
	_resultTextPlural = "%s agarraron más"
	
	_rowInDefaultSlotWheelImage = 5
	
	videoGuide.file = ("res://Scenes/NewBetShow/BetGuides/BetGuide_MasAgarres.ogv")

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[mon.player.id] += 1)
	
	super(arena)
