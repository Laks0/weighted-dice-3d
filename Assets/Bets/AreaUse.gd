extends Node3D

var playersInArea := [.0,.0,.0,.0]

func _process(_delta):
	var totalPlayers : float = PlayerHandler.getPlayersAlive().size()
	$SE.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.BOTTOM_RIGHT] / (totalPlayers+4)
	$SW.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.BOTTOM_LEFT] / (totalPlayers+4)
	$NE.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.TOP_RIGHT] / (totalPlayers+4)
	$NW.transparency = 1 - playersInArea[MostUsedAreaBet.ArenaSide.TOP_LEFT] / (totalPlayers+4)
