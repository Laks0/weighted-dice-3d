extends Bet
class_name GameTimeBet

var gameTime: float

var times : Array[float]

enum GameTime {FIRST, MIDDLE_LONG, MIDDLE_SHORT, LAST}

func _init():
	betName = "Tiempo de juego"
	betType = BetType.CUSTOM
	
	betDescription = "¿Cuánto va a durar esta ronda?"
	_resultTextSingular = "La partida duró %s"

func startRound():
	times = [0,0,0]
	var playersAlive := PlayerHandler.getPlayersAlive().size()
	times[0] = playersAlive * 10
	times[1] = playersAlive * 20
	times[2] = playersAlive * 20 + 10
 
func settle():
	_result = getCandidatesOnFirst()[0]

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

func getCandidatesOnFirst() -> Array:
	if gameTime < times[0]:
		return [GameTime.FIRST]
	elif gameTime >= times[0] and gameTime < times[1]:
		return [GameTime.MIDDLE_LONG]
	elif gameTime >= times[1] and gameTime < times[2]:
		return [GameTime.MIDDLE_SHORT]
	
	return [GameTime.LAST]

func getCandidates() -> Array:
	return GameTime.values()

func getCandidateName(time : GameTime) -> String:
	match time:
		GameTime.FIRST: return "Menos de %.0fs" % times[0]
		GameTime.MIDDLE_LONG: return "Entre %.0fs y %.0fs" % [times[0], times[1]]
		GameTime.MIDDLE_SHORT: return "Entre %.0fs y %.0fs" % [times[1], times[2]]
		GameTime.LAST: return "Más de %.0fs" % times[2]
	return ""

func getCandidateColor(time : GameTime) -> Color:
	match time:
		GameTime.FIRST: return Color("#F7A315")
		GameTime.MIDDLE_LONG: return Color("#27CD74")
		GameTime.MIDDLE_SHORT: return Color("#E11A4C")
		GameTime.LAST: return Color("#FF4000")
	return Color.WHITE
