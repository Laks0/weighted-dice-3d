extends Bet

func _init():
	betName = "First to die"
	betType = BetType.EXCLUDE_SELF

func settle():
	_result = _arena.firstToDie

func hasWon(candidate : int) -> bool:
	return candidate == _result
