extends Bet
class_name MostGrabsBet

var grabs : Dictionary
var maxGrabs : int = 0

func _init():
	betName = "Most Grabs"
	betType = BetType.ALL_PLAYERS

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		grabs[mon.player.id] = 0
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						grabs[mon.player.id] += 1
					maxGrabs = max(maxGrabs, grabs[mon.player.id]))
	
	super(arena)

func registerGrabs(monigote: Monigote):
	grabs[monigote.player.id] = monigote.grabs
	maxGrabs = max(monigote.grabs, maxGrabs)

func settle():
	_result = PlayerHandler.getPlayersAliveById()\
		.filter(func(id: int): return grabs[id] == maxGrabs)
