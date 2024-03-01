extends Bet
class_name MostGrabsBet

func _init():
	betName = "Most Grabs"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[mon.player.id] += 1)
	
	super(arena)

