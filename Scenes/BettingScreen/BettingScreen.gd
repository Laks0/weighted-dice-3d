extends Node3D

@export var chipResource : PackedScene
@export var betBoothResource : PackedScene
@export var arenaScene : PackedScene

var _booths : Array[BetBooth]

var _boothSeparation = 2

func _ready():
	BetHandler.startRound()
	$BetName.text = BetHandler.getBetName()
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
	var players := PlayerHandler.getPlayersAlive()
	var startPos = _getBoothStartingPosition(len(players)) + Vector3.BACK * 4.5
	for p in players:
		var j = 0
		var pos = startPos + Vector3.RIGHT * 2 * i # La posición de las fichas
		
		# La label con el número de fichas
		var label = Label3D.new()
		label.text = str(p.bank)
		label.modulate = p.color
		label.position = pos + Vector3.BACK * .5 + Vector3.UP * .2
		label.billboard = true
		add_child(label)
		
		for b in p.bank:
			var chip : BettingChip = chipResource.instantiate()
			chip.setPlayer(p)
			chip.position = pos + Vector3(0, j * .1, 0)
			add_child(chip)
			j += 1
		
		i += 1

## La posición del primer booth dado n candidatos y separación _boothSeparation
func _getBoothStartingPosition(n : float) -> Vector3:
	var x = - _boothSeparation * (n-1) / 2
	return Vector3(x, 0, -2.5)

var _playersReady : int = 0

func _startGame():
	for player in PlayerHandler.getPlayersAlive():
		for booth in _booths:
			player.setBet(booth.getChips(player.id), booth.candidate)
	
	get_tree().change_scene_to_packed(arenaScene)

func onPlayerReady(body):
	if body is Monigote:
		_playersReady += 1
	
	if _playersReady == PlayerHandler.amountOfPlayersLeft():
		_startGame()

func onPlayerUnready(body):
	if body is Monigote:
		_playersReady -= 1
