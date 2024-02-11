extends Bet
class_name FewerGrabsBet

var grabs : Dictionary
var minGrabs : int = 10000

func _init():
	betName = "Fewer Grabs"
	betType = BetType.ALL_PLAYERS

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("died", registerGrabs.bind(mon))
	
	super(arena)

func registerGrabs(monigote: Monigote):
	grabs[monigote.player.id] = monigote.grabs
	minGrabs = min(monigote.grabs, minGrabs)

func settle():
	for mon : Monigote in _arena.getLivingMonigotes():
		registerGrabs(mon)
	
	_result = PlayerHandler.getPlayersAliveById()\
		.filter(func(id: int): return grabs[id] == minGrabs)
