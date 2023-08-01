extends Bet

func _init():
	betName = "Game Time"
	betType = BetType.GAME_TIME

func settle():
	if _arena.gameTime < 30:
		_result = GameTimes.FIRST_30
	elif _arena.gameTime > 60:
		_result = GameTimes.MORE_THAN_60
	else:
		_result = GameTimes.FROM_30_TO_60

func hasWon(candidate) -> bool:
	return candidate == _result

func getCandidateOdds(candidate) -> int:
	if candidate == GameTimes.FROM_30_TO_60:
		return 2
	
	return 3
