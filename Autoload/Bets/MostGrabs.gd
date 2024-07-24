extends Bet
class_name MostGrabsBet

func _init():
	betName = "Más agarres"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN
	
	_resultTextSingular = "%s agarró más"
	_resultTextPlural = "%s agarraron más"

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[mon.player.id] += 1)
	
	super(arena)

