extends Bet
class_name MostGrabbedBet

func _init():
	betName = "Most Grabbed"
	betType = BetType.EXCLUDE_SELF
	_scoreOrder = Order.ASCENDING

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						_scores[body.player.id] += 1)
	
	super(arena)

func getCandidateOdds(candidate) -> int:
	var maxBank = PlayerHandler.getPlayersInOrder()[0].bank
	if PlayerHandler.getPlayerById(candidate).bank == maxBank:
		return 3
	return 2
