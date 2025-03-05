extends Bet
class_name KingOfTheHillBet

var hill : Sprite3D

## El tamaño de la zona en la que hay que estar
const HILL_RADIUS := 1

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Rey de la colina"
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.TIME
	monigoteSignal = MonigoteSignal.CROWN
	
	_resultTextSingular = "%s fue el rey de la colina"
	_resultTextPlural = "%s fueron reyes de la colina"

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if mon.position.distance_to(Vector3(0, Globals.SPRITE_HEIGHT, 0)) < HILL_RADIUS:
			_scores[mon.player.id] += delta

func startGame(arena : Arena):
	hill = load("res://Assets/Bets/Hill.tscn").instantiate()
	arena.add_child(hill)
	super(arena)

func settle():
	if is_instance_valid(hill):
		hill.queue_free()
	super()
