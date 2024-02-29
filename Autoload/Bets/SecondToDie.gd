extends Bet
class_name SecondToDieBet

var dead : int

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
	dead += 1

func settle():
	pass

func canAppear() -> bool:
	return PlayerHandler.getPlayersAlive().size() > 2
