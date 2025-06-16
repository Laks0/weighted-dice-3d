extends Bet

func _init():
	betName = "Tiempo quieto"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.TIME
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a estar más tiempo sin moverse?"
	_resultTextSingular = "%s estuvo más tiempo sin moverse"
	_resultTextPlural   = "%s estuvieron más tiempo sin moverse"

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.velocity.is_zero_approx():
			_scores[mon.player.id] += delta
