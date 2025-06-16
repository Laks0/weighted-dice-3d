extends Bet

var crown : CharacterBody3D

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Agarrar la corona"
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.TIME
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a sostener por más tiempo la corona?"
	_resultTextSingular = "%s agarró más la corona"
	_resultTextPlural = "%s agarraron más la corona"

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if not is_instance_valid(mon.grabBody):
			continue
		if mon.grabbing and mon.grabBody is CrownGrab:
			_scores[mon.player.id] += delta

func startGame(arena : Arena):
	crown = load("res://Assets/Bets/CrownGrab.tscn").instantiate()
	crown.position = arena.getRandomPosition()
	arena.add_child(crown)
	super(arena)

func settle():
	if is_instance_valid(crown):
		crown.queue_free()
	super()
