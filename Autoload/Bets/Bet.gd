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

## Si el que va primero devuelve triple y el resto doble
var _prizeOnFirst := false
var _secondaryPrize : int

## Los textos para anunciar el resultado de la apuesta. Debe tener un %s donde va el resultado
var _resultTextSingular : String = "El resultado de la apuesta es: %s"
var _resultTextPlural   : String = "Los resultados de la apuesta son: %s"

var betDescription : String = "Apostar al candidato que te de la gana"

enum MonigoteSignal {
	CROWN,
	JOKER_HAT,
	NONE
}
var monigoteSignal : MonigoteSignal = MonigoteSignal.NONE

## Para determinar las apuestas con prizeOnFirst
var _maxBank : int = 0

enum ScoreType {
	INT,
	TIME,
	CUSTOM
}

var _scoreType = ScoreType.INT

func _pickSecondaryPrize():
	var pickablePlayers := PlayerHandler.getPlayersAlive()\
		.filter(func (p : PlayerHandler.Player): return p.bank < _maxBank)
	
	if pickablePlayers.size() == 0:
		_secondaryPrize = -1
		return
	
	_secondaryPrize = pickablePlayers.pick_random().id

## Se llama al principio de la ronda
func startRound():
	_maxBank = PlayerHandler.getPlayersInOrder()[0].bank
	if _prizeOnFirst:
		_pickSecondaryPrize()
	
	for candidate in getCandidates():
		_scores[candidate] = 0

## Se llama al final del ready de la arena
func startGame(arena : Arena):
	_arena = arena

## Se llama al final del update de arena. Evitar a menos que sea imposible
func arenaUpdate(_delta):
	pass

## Determina el ganador, por defecto usa _score y _scoreOrder
func settle():
	_result = getCandidatesOnFirst()

func hasWon(candidate) -> bool:
	return _result.has(candidate)

func getCandidateOdds(candidate) -> int:
	if _prizeOnFirst and PlayerHandler.getPlayerById(candidate).bank == _maxBank:
		return 4
	if _prizeOnFirst and candidate == _secondaryPrize:
		return 3
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

## Retorna los candidatos que están ganando la apuesta
func getCandidatesOnFirst() -> Array:
	if _scoreOrder == Order.NO_SCORE:
		return []
	
	var winnerScore = _scores[getCandidatesInOrder()[0]]
	return getCandidates().filter(func (candidate):
		return _scores[candidate] == winnerScore)

func getWinnerCandidates() -> Array:
	if _result is Array:
		return _result
	else:
		return [_result]

func getWinnersText() -> String:
	if getWinnerCandidates().size() == 1:
		return _resultTextSingular % getCandidateName(getWinnerCandidates()[0])
	
	var lista := ""
	var i := 0
	for candidate in getWinnerCandidates():
		if i != 0:
			lista += ", " if getWinnerCandidates().size() != 2 else " "
		if i == getWinnerCandidates().size() - 1:
			lista += "y "
		lista += getCandidateName(candidate)
		i += 1
	
	return _resultTextPlural % lista

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

func usesScore() -> bool:
	return _scoreOrder != Order.NO_SCORE

func getScoreText(candidate) -> String:
	if (not usesScore()) or (not _scores.has(candidate)):
		return ""
	
	if _scoreType == ScoreType.INT:
		return str(int(_scores[candidate]))
	
	if _scoreType == ScoreType.TIME:
		return "%.1f" % _scores[candidate]
	
	return ""
