extends Bet
class_name MostGrabbedBet

func _init():
	betName = "Más agarrado"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.JOKER_HAT
	_prizeOnFirst = true
	
	betDescription = "¿Qué jugador va a ser el más agarrado por los demás esta ronda?"
	_resultTextSingular = "%s fue el más agarrado"
	_resultTextPlural   = "%s fueron los más agarrados"
	
	_rowInDefaultSlotWheelImage = 6
	
	videoGuide.file = ("res://Scenes/NewBetShow/BetGuides/BetGuide_MasAgarrado.ogv")

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[body.player.id] += 1)
	
	super(arena)
