extends Bet

var crown : CharacterBody3D

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Agarrar la corona"
	_scoreOrder = Order.ASCENDING
	monigoteSignal = MonigoteSignal.CROWN
	
	_resultTextSingular = "%s agarró más la corona"
	_resultTextPlural = "%s agarraron más la corona"

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
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
