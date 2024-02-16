extends Bet
class_name KingOfTheHillBet

## El tamaño de la zona en la que hay que estar
const HILL_RADIUS := 1

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Most time on the center"
	_scoreOrder = Order.ASCENDING

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.position.distance_to(Vector3(0, Globals.SPRITE_HEIGHT, 0)) < HILL_RADIUS:
			_scores[mon.player.id] += delta
