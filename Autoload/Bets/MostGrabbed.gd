extends Bet
class_name MostGrabbedBet

var grabs : Dictionary
var maxGrabs : int = 0

func _init():
	betName = "Most Grabbed"
	betType = BetType.EXCLUDE_SELF

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		grabs[mon.player.id] = 0
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						grabs[body.player.id] += 1
					maxGrabs = max(maxGrabs, grabs[body.player.id]))
	
	super(arena)

func registerGrabs(monigote: Monigote):
	grabs[monigote.player.id] = monigote.grabs
	maxGrabs = max(monigote.grabs, maxGrabs)

func settle():
	_result = PlayerHandler.getPlayersAliveById()\
		.filter(func(id: int): return grabs[id] == maxGrabs)

func getCandidateOdds(candidate) -> int:
	var maxBank = PlayerHandler.getPlayersInOrder()[0].bank
	if PlayerHandler.getPlayerById(candidate).bank == maxBank:
		return 3
	return 2