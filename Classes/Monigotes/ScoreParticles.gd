extends Node3D

@export var scoreParticle : PackedScene

@onready var mon : Monigote = get_parent()

var lastScore: float = 0

func _process(_delta):
	if mon.stageHandler.currentStage != StageHandler.Stages.ARENA:
		return
	
	if not BetHandler.currentBet.betType in [Bet.BetType.EXCLUDE_SELF, Bet.BetType.ALL_PLAYERS]:
		return
	
	var newScore = BetHandler.getCandidateScore(mon.player.id)
	if floori(newScore) != floori(lastScore):
		emitScore(floori(newScore))
	lastScore = newScore

func emitScore(n : int):
	var particle = scoreParticle.instantiate()
	add_child(particle)
	
	particle.draw_pass_1.material.albedo_color = mon.player.color
	particle.draw_pass_1.text = str(n)
	
	particle.emitting = true
	
	particle.connect("finished", particle.queue_free)
