extends Bet
class_name FewerGrabsBet

func _init():
	betName = "Menos Agarres"
	betType = BetType.EXCLUDE_SELF
	_scoreOrder = Order.DESCENDING
	monigoteSignal = MonigoteSignal.JOKER_HAT
	
	betDescription = "¿Quién va a agarrar menos a los demás esta ronda?"
	_resultTextSingular = "%s agarró menos"
	_resultTextPlural = "%s agarraron menos"

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[mon.player.id] += 1)
	
	super(arena)
