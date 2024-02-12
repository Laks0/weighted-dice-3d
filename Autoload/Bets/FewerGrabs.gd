extends Bet
class_name FewerGrabsBet

var grabs : Dictionary
var minGrabs : int = 10000

func _init():
	betName = "Fewer Grabs"
	betType = BetType.ALL_PLAYERS

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		grabs[mon.player.id] = 0
		mon.connect("grab",\
				func (body : Node):
					if body is Monigote:
						grabs[mon.player.id] += 1
					minGrabs = min(minGrabs, grabs[mon.player.id]))
	
	super(arena)

func registerGrabs(monigote: Monigote):
	grabs[monigote.player.id] = monigote.grabs
	minGrabs = min(monigote.grabs, minGrabs)

func settle():
	_result = PlayerHandler.getPlayersAliveById()\
		.filter(func(id: int): return grabs[id] == minGrabs)
