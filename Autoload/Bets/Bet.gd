extends Node
class_name Bet

## Clase base para todas las apuestas
## La comunicación entre las apuestas y los datos de la arena tienen que ser
## hechos con la mínima intervención posible en cualquier objeto que no sea
## la propia apuesta.
## Cualquier script en res://Autoload/Bets se carga como una apuesta

enum BetType {
	EXCLUDE_SELF,
	ALL_PLAYERS,
	GAME_TIME,
	ARENA_SIDE
}

var _arena   : Arena
var _result
## El tipo de candidatos que toma la apuesta
var betType : BetType
## El nombre a mostrar en texto
var betName : String

## Se llama al final del ready de la arena
func startGame(arena : Arena):
	_arena = arena

## Se llama al final del update de arena. Evitar a menos que sea imposible
func arenaUpdate(_delta):
	pass

func settle():
	pass

func hasWon(candidate) -> bool:
	return candidate in _result

func getCandidateOdds(_candidate) -> int:
	return 2

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
