extends Bet
class_name KingOfTheHillBet

## El tamaño de la zona en la que hay que estar
const HILL_RADIUS := 1

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Most time on the center"

var times   : Dictionary
var maxTime : float = 0

func startGame(arena: Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		times[mon.player.id] = 0

	super(arena)

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.position.distance_to(Vector3(0, Globals.SPRITE_HEIGHT, 0)) < HILL_RADIUS:
			times[mon.player.id] += delta
			maxTime = max(maxTime, times[mon.player.id])

func settle():
	_result = PlayerHandler.getPlayersAliveById()\
			.filter(func(id:int): return times[id] == maxTime)
