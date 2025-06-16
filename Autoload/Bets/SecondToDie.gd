extends Bet
class_name SecondToDieBet

var dead : int

var tomb : Node3D

func _init():
	betName = "Segundo en morir"
	betType = BetType.EXCLUDE_SELF
	_prizeOnFirst = true
	
	_result = 0
	
	betDescription = "¿Quién va a ser la segunda persona en morir esta ronda?"
	_resultTextSingular = "%s murió segundo"

func hasWon(candidate : int) -> bool:
	return candidate == _result

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("died", monigoteDied.bind(mon))
	
	dead = 0
	super(arena)

func monigoteDied(monigote : Monigote):
	if dead == 1:
		_result = monigote.player.id
		
		tomb = load("res://Assets/Bets/Tomb.tscn").instantiate()
		tomb.number = 2
		tomb.player = monigote.player.id
		tomb.position = monigote.position
		tomb.position.y = 0
		monigote.get_parent().add_child(tomb)
	dead += 1

func settle():
	tomb.queue_free()

func canAppear() -> bool:
	return PlayerHandler.getPlayersAlive().size() > 2

func getCandidatesOnFirst() -> Array:
	if dead <= 1:
		return getCandidates()
	return [_result]
