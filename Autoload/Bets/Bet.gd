extends Node
class_name Bet

## Clase base para todas las apuestas
## La comunicación entre las apuestas y los datos de la arena tienen que ser
## hechos con la mínima intervención posible en cualquier objeto que no sea
## la propia apuesta.
## Cualquier script en res://Autoload/Bets se carga como una apuesta
## Por defecto funciona declarando que los ganadores son los candidatos con mayor valor en _scores,
## para cualquier funcionamiento que no es de ese tipo se puede sobreescribir settle()

enum BetType {
	EXCLUDE_SELF,
	ALL_PLAYERS,
	GAME_TIME,
	ARENA_SIDE
}

## Un diccionario con puntajes para cada candidato. Ignorar si no tiene sentido para la apuesta
var _scores : Dictionary

enum Order {
	ASCENDING,
	DESCENDING
}

var _arena   : Arena
var _result
## El tipo de candidatos que toma la apuesta
var betType : BetType
## El nombre a mostrar en texto
var betName : String
## Orden de preferencia de los resultados de getScores, determina cómo va a ordenar getCandidatesInOrder
var _scoreOrder : Order = Order.ASCENDING

## Se llama al final del ready de la arena
func startGame(arena : Arena):
	_arena = arena

	for candidate in Bet.getCandidates(betType):
		_scores[candidate] = 0

## Se llama al final del update de arena. Evitar a menos que sea imposible
func arenaUpdate(_delta):
	pass

## Determina el ganador, por defecto usa _score y _scoreOrder
func settle():
	var winnerScore = _scores[getCandidatesInOrder()[0]]
	_result = Bet.getCandidates(betType).filter(func (candidate):
		return _scores[candidate] == winnerScore)

func hasWon(candidate) -> bool:
	return candidate in _result

func getCandidateOdds(_candidate) -> int:
	return 2

## Retorna los puntajes de cada candidato en la apuesta
func getScores() -> Dictionary:
	return _scores

## Retorna los candidatos en el orden de la apuesta
func getCandidatesInOrder() -> Array:
	var candidates: Array = Bet.getCandidates(betType)
	candidates.sort_custom(func (a, b):
		if _scoreOrder == Order.ASCENDING:
			return _scores[a] > _scores[b]
		return _scores[a] < _scores[b])

	return candidates

# Funciones estáticas

static func getCandidates(type : BetType) -> Array:
	var allPlayers = PlayerHandler.getPlayersAliveById()
	
	match type:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return allPlayers
		Bet.BetType.GAME_TIME:
			return GameTimes.values()
		Bet.BetType.ARENA_SIDE:
			return ArenaSide.values()
	
	return []

static func getCandidateName(type : BetType, candidate) -> String:
	match type:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return PlayerHandler.getPlayerById(candidate).name
		Bet.BetType.GAME_TIME:
			return _gameTimeName(candidate)
		Bet.BetType.ARENA_SIDE:
			return "Left" if candidate == ArenaSide.LEFT else "Right"
	
	return str(candidate)

static func getCandidateColor(type: BetType, candidate) -> Color:
	match type:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return PlayerHandler.getPlayerById(candidate).color
	
	return Color.PURPLE

enum GameTimes {
	FIRST_30,
	FROM_30_TO_60,
	MORE_THAN_60
}

static func _gameTimeName(time : GameTimes) -> String:
	match time:
		GameTimes.FIRST_30:
			return "<30s"
		GameTimes.FROM_30_TO_60:
			return "30s - 60s"
		GameTimes.MORE_THAN_60:
			return ">60s"
	return ""

enum ArenaSide {
	LEFT,
	RIGHT
}
