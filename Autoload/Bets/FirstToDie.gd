extends Bet
class_name FirstToDieBet

func _init():
	betName = "First to die"
	betType = BetType.EXCLUDE_SELF

func settle():
	_result = _arena.firstToDie

func hasWon(candidate : int) -> bool:
	return candidate == _result

func getCandidateOdds(candidate) -> int:
	var maxBank = PlayerHandler.getPlayersInOrder()[0].bank
	if PlayerHandler.getPlayerById(candidate).bank == maxBank:
		return 3
	return 2
