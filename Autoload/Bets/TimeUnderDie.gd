extends Bet
class_name TimeUnderDieBet

func _init():
	betName = "Tiempo bajo el dado"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a estar más tiempo abajo del dado?"
	_resultTextSingular = "%s estuvo más abajo del dado"
	_resultTextPlural = "%s estuvieron más abajo del dado"

func arenaUpdate(delta):
	if not is_instance_valid(_arena.die):
		return
	
	var dieFlatPosition := Vector2(_arena.die.global_position.x, _arena.die.global_position.z)
	for mon : Monigote in _arena.getLivingMonigotes():
		var monFlatPosition := Vector2(mon.global_position.x, mon.global_position.z)
		if mon.global_position.y < _arena.die.global_position.y and\
			dieFlatPosition.distance_squared_to(monFlatPosition) < .5:
			_scores[mon.player.id] += delta
