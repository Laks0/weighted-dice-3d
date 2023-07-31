extends Node3D

@export var chipResource : PackedScene
@export var betBoothResource : PackedScene

var _booths : Array[BetBooth]

var _boothSeparation = 2

func _ready():
	BetHandler.startRound()
	var candidates : Array = BetHandler.getCandidates()
	
	var startingPos = _getBoothStartingPosition(len(candidates))
	var i = 0
	for c in candidates:
		var booth : BetBooth = betBoothResource.instantiate()
		booth.candidate = c
		booth.position = startingPos + Vector3.RIGHT * _boothSeparation * i
		_booths.append(booth)
		add_child(booth)
		i += 1
	
	var monigotes := PlayerHandler.instantiatePlayers(self)
	for m in monigotes:
		m.makeInvincible()
	
	_setupChips()

func _setupChips():
	var i = 0
	for p in PlayerHandler.getPlayersAlive():
		var pos = Vector3(i * 2, .4, 2)
		var chip : BettingChip = chipResource.instantiate()
		chip.setPlayer(p)
		chip.position = pos
		add_child(chip)
		
		i += 1

## La posición del primer booth dado n candidatos y separación _boothSeparation
func _getBoothStartingPosition(n : float) -> Vector3:
	var x = - _boothSeparation * (n-1) / 2
	return Vector3(x, 0, -2.5)
