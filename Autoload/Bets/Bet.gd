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
	CUSTOM
}

## Un diccionario con puntajes para cada candidato. Ignorar si no tiene sentido para la apuesta
var _scores : Dictionary

enum Order {
	ASCENDING,
	DESCENDING,
	NO_SCORE
}

var _arena   : Arena
var _result
## El tipo de candidatos que toma la apuesta
var betType : BetType
## El nombre a mostrar en texto
var betName : String
## Orden de preferencia de los resultados de getScores, determina cómo va a ordenar getCandidatesInOrder
var _scoreOrder : Order = Order.NO_SCORE

enum MonigoteSignal {
	CROWN,
	JOKER_HAT,
	NONE
}
var monigoteSignal : MonigoteSignal = MonigoteSignal.NONE

## Se llama al principio de la ronda
func startRound():
	pass

## Se llama al final del ready de la arena
func startGame(arena : Arena):
	_arena = arena

	for candidate in getCandidates():
		_scores[candidate] = 0

## Se llama al final del update de arena. Evitar a menos que sea imposible
func arenaUpdate(_delta):
	pass

## Determina el ganador, por defecto usa _score y _scoreOrder
func settle():
	var winnerScore = _scores[getCandidatesInOrder()[0]]
	_result = getCandidates().filter(func (candidate):
		return _scores[candidate] == winnerScore)

func hasWon(candidate) -> bool:
	return _result.has(candidate)

func getCandidateOdds(_candidate) -> int:
	return 2

## Determina si un jugador puede apostar a un candidato, se puede reescribir
func canBet(playerId : int, candidate) -> bool:
	if betType == BetType.EXCLUDE_SELF:
		return candidate != playerId
	
	return true

## Retorna los puntajes de cada candidato en la apuesta
func getScores() -> Dictionary:
	return _scores

## Retorna los candidatos en el orden de la apuesta
func getCandidatesInOrder() -> Array:
	var candidates: Array = getCandidates()
	candidates.sort_custom(func (a, b):
		if _scoreOrder == Order.ASCENDING:
			return _scores[a] > _scores[b]
		return _scores[a] < _scores[b])

	return candidates

func getWinnerCandidates() -> Array:
	if _result is Array:
		return _result
	else:
		return [_result]

## Si es posible que la apuesta aparezca ahora
func canAppear() -> bool:
	return true

## Por defecto los candidatos son los jugadores vivos
func getCandidates() -> Array:
	return PlayerHandler.getPlayersAliveById()

func getCandidateName(candidate) -> String:
	return PlayerHandler.getPlayerById(candidate).name

func getCandidateColor(candidate) -> Color:
	if [Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF].has(betType):
			return PlayerHandler.getPlayerById(candidate).color
	
	return Color.RED
