extends Node3D

@export var chipResource : PackedScene

var candidatePlayers : Array
var monigotes : Array[Monigote]

func _ready():
	BetHandler.startRound()
	var candidates : Array = BetHandler.getCandidates()
	
	var labels = $Labels.get_children()
	
	# Por ahora asumo que siempre son jugadores
	# Agarra las ids y las transforma en el objeto Player
	candidatePlayers = candidates.map(func (id : int): return PlayerHandler.getPlayerById(id))
	
	for i in len(candidatePlayers):
		labels[i].text = candidatePlayers[i].name
		labels[i].modulate = candidatePlayers[i].color
	
	monigotes = PlayerHandler.instantiatePlayers(self)
	for m in monigotes:
		m.makeInvincible()
	
	var i = 0
	for p in PlayerHandler.getPlayersAlive():
		var pos = Vector3(i * 2, .4, 2)
		var chip : BettingChip = chipResource.instantiate()
		chip.setPlayer(p)
		chip.position = pos
		add_child(chip)
		
		i += 1
