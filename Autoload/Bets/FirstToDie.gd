extends Bet
class_name FirstToDieBet

var dead : int

var tomb : Node3D

func _init():
	betName = "Primero en morir"
	betType = BetType.EXCLUDE_SELF
	_prizeOnFirst = true
	
	betDescription = "¿Quién va a morir primero esta ronda?"
	_resultTextSingular = "%s murió primero"
	
	_rowInDefaultSlotWheelImage = 1
	
	videoGuide.file = "res://Scenes/NewBetShow/BetGuides/BetGuide_PrimeroEnMorir.ogv"

func hasWon(candidate : int) -> bool:
	return candidate == _result

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("died", monigoteDied.bind(mon))
	
	dead = 0
	super(arena)

func monigoteDied(monigote : Monigote):
	if dead == 0:
		_result = monigote.player.id
		
		tomb = load("res://Assets/Bets/Tomb.tscn").instantiate()
		tomb.number = 1
		tomb.player = monigote.player.id
		tomb.position = monigote.position
		tomb.position.y = 0
		monigote.get_parent().add_child(tomb)
	dead += 1

func settle():
	tomb.queue_free()

func getCandidatesOnFirst() -> Array:
	if dead == 0:
		return getCandidates()
	return [_result]
