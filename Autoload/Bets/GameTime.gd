extends Bet
class_name GameTimeBet

var gameTime: float

var times : Array[float]

enum GameTime {FIRST, MIDDLE_LONG, MIDDLE_SHORT, LAST}

func _init():
	betName = "Tiempo de juego"
	betType = BetType.CUSTOM
	
	_resultTextSingular = "La partida duró %s"

func startRound():
	times = [0,0,0]
	var playersAlive := PlayerHandler.getPlayersAlive().size()
	times[0] = playersAlive * 5
	times[1] = playersAlive * 10
	times[2] = playersAlive * 10 + 5
 
func settle():
	if gameTime < times[0]:
		_result = GameTime.FIRST
	elif gameTime >= times[0] and gameTime < times[1]:
		_result = GameTime.MIDDLE_LONG
	elif gameTime >= times[1] and gameTime < times[2]:
		_result = GameTime.MIDDLE_SHORT
	else:
		_result = GameTime.LAST

func startGame(arena):
	gameTime = 0
	super(arena)

func arenaUpdate(delta):
	gameTime += delta

func hasWon(candidate) -> bool:
	return candidate == _result

func getCandidateOdds(candidate) -> int:
	if candidate == GameTime.MIDDLE_LONG or candidate == GameTime.LAST:
		return 2
	
	if candidate == GameTime.MIDDLE_SHORT:
		return 4
	
	return 3

func getCandidates() -> Array:
	return GameTime.values()

func getCandidateName(time : GameTime) -> String:
	match time:
		GameTime.FIRST: return "Menos de %ss" % times[0]
		GameTime.MIDDLE_LONG: return "Entre %ss y %ss" % [times[0], times[1]]
		GameTime.MIDDLE_SHORT: return "Entre %ss y %ss" % [times[1], times[2]]
		GameTime.LAST: return "Más de %ss" % times[2]
	return ""

func getCandidateColor(time : GameTime) -> Color:
	match time:
		GameTime.FIRST: return Color.GREEN
		GameTime.MIDDLE_LONG: return Color.GREEN_YELLOW
		GameTime.MIDDLE_SHORT: return Color.YELLOW
		GameTime.LAST: return Color.RED
	return Color.WHITE
