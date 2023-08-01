extends Node
class_name Bet

enum BetType {
	EXCLUDE_SELF,
	ALL_PLAYERS,
	GAME_TIME
}

var _arena   : Arena
var _result
var betType : BetType
var betName : String

func init():
	pass

func startGame(arena : Arena):
	_arena = arena

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
	
	return []

static func getCandidateName(type : BetType, candidate) -> String:
	match type:
		Bet.BetType.ALL_PLAYERS, Bet.BetType.EXCLUDE_SELF:
			return PlayerHandler.getPlayerById(candidate).name
		Bet.BetType.GAME_TIME:
			return _gameTimeName(candidate)
	
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
