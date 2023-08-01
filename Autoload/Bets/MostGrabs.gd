extends Bet

func _init():
	betName = "Most Grabs"
	betType = BetType.ALL_PLAYERS

func settle():
	var monigotes : Array[Monigote] = _arena.monigotes
	
	var maxGrabs = 0
	for m in monigotes:
		if m.grabs >= maxGrabs:
			maxGrabs = m.grabs
	
	_result = monigotes.filter(func(mon : Monigote): return mon.grabs == maxGrabs) \
						.map(func (mon : Monigote): return mon.player.id)
