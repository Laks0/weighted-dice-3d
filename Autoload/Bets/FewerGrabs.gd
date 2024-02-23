extends Bet
class_name FewerGrabsBet

func _init():
	betName = "Fewer Grabs"
	betType = BetType.EXCLUDE_SELF
	_scoreOrder = Order.DESCENDING

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[mon.player.id] += 1)
	
	super(arena)
