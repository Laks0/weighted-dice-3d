extends Bet
class_name MostGrabbedBet

func _init():
	betName = "Most Grabbed"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.JOKER_HAT
	_prizeOnFirst = true

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[body.player.id] += 1)
	
	super(arena)
