extends Node3D

var playersInArea := [.0,.0,.0,.0]

@onready var sprites : Dictionary = {
	MostUsedAreaBet.ArenaSide.BOTTOM_RIGHT: $SESprite,
	MostUsedAreaBet.ArenaSide.TOP_RIGHT: $NESprite,
	MostUsedAreaBet.ArenaSide.BOTTOM_LEFT: $SWSprite,
	MostUsedAreaBet.ArenaSide.TOP_LEFT: $NWSprite,
}

func _process(_delta):
	var totalPlayers : float = PlayerHandler.getPlayersAlive().size()
	$SE.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.BOTTOM_RIGHT] / (totalPlayers+4)
	$SW.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.BOTTOM_LEFT] / (totalPlayers+4)
	$NE.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.TOP_RIGHT] / (totalPlayers+4)
	$NW.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.TOP_LEFT] / (totalPlayers+4)
	
	for i in MostUsedAreaBet.ArenaSide.values():
		sprites[i].visible = BetHandler.getScores()[i] == \
				BetHandler.getScores()[BetHandler.getCandidatesInOrder()[0]]
