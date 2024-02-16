extends Bet
class_name GameTimeBet

func _init():
	betName = "Game Time"
	betType = BetType.GAME_TIME

var gameTime: float

func settle():
	if gameTime < 30:
		_result = GameTimes.FIRST_30
	elif gameTime > 60:
		_result = GameTimes.MORE_THAN_60
	else:
		_result = GameTimes.FROM_30_TO_60

func startGame(arena):
	gameTime = 0
	super(arena)

func arenaUpdate(delta):
	gameTime += delta

func hasWon(candidate) -> bool:
	return candidate == _result

func getCandidateOdds(candidate) -> int:
	if candidate == GameTimes.FROM_30_TO_60:
		return 2
	
	return 3
