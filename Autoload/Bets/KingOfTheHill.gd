extends Bet
class_name KingOfTheHillBet

var hill : Sprite3D
var hillGlobalPosition := Vector3.ZERO

## El tamaño de la zona en la que hay que estar
const HILL_RADIUS := 1

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Rey de la colina"
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.TIME
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a permanecer más tiempo en la colina?"
	_resultTextSingular = "%s fue el rey de la colina"
	_resultTextPlural = "%s fueron reyes de la colina"
	
	_rowInDefaultSlotWheelImage = 4
	
	videoGuide.file = "res://Scenes/NewBetShow/BetGuides/BetGuide_ReyDeLaColina.ogv"

func arenaUpdate(delta):
	for mon : Monigote in _arena.getLivingMonigotes():
		if _getDistanceToHillFor(mon) < HILL_RADIUS:
			_scores[mon.player.id] += delta

func startGame(arena : Arena):
	hill = load("res://Assets/Bets/Hill.tscn").instantiate()
	arena.add_child(hill)
	hillGlobalPosition = hill.global_position
	super(arena)

func settle():
	if is_instance_valid(hill):
		hill.queue_free()
	super()

func _getDistanceToHillFor(monigote : Monigote):
	var target := monigote.global_position * Vector3(0,1,0) + hillGlobalPosition * Vector3(1,0,1)
	return monigote.global_position.distance_to(target)
