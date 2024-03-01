extends Bet
class_name SecondToDieBet

var dead : int

var tomb : Node3D

func _init():
	betName = "Second to die"
	betType = BetType.EXCLUDE_SELF
	
	_result = 0

func hasWon(candidate : int) -> bool:
	return candidate == _result

func getCandidateOdds(candidate) -> int:
	var maxBank = PlayerHandler.getPlayersInOrder()[0].bank
	if PlayerHandler.getPlayerById(candidate).bank == maxBank:
		return 3
	return 2

func startGame(arena : Arena):
	for mon : Monigote in arena.getLivingMonigotes():
		mon.connect("died", monigoteDied.bind(mon))
	
	dead = 0
	super(arena)

func monigoteDied(monigote : Monigote):
	if dead == 1:
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

func canAppear() -> bool:
	return PlayerHandler.getPlayersAlive().size() > 2
