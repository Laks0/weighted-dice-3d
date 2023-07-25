extends Node
class_name Bet

enum BetType {
	EXCLUDE_SELF,
	ALL_PLAYERS
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
