extends Bet
class_name TimeUnderDieBet

var _linePointerScene := preload("res://Classes/LinePointer/LinePointer.tscn")
var _linePointers : Dictionary[int, Node3D]

func _init():
	betName = "Tiempo bajo el dado"
	betType = BetType.ALL_PLAYERS
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.TIME
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a estar más tiempo abajo del dado?"
	_resultTextSingular = "%s estuvo más abajo del dado"
	_resultTextPlural = "%s estuvieron más abajo del dado"
	
	_rowInDefaultSlotWheelImage = 8
	
	videoGuide.file = ("res://Scenes/NewBetShow/BetGuides/BetGuide_TiempoBajoElDado.ogv")

func startGame(arena : Arena):
	super(arena)
	for mon in arena.getLivingMonigotes():
		var line = _linePointerScene.instantiate()
		_linePointers[mon.player.id] = line
		line.setWidth(.01)
		line.setSpeed(30)
		mon.add_child(line)
		line.visible = false

func arenaUpdate(delta):
	if not is_instance_valid(_arena.die):
		return
	
	var die : Die = _arena.die
	var dieFlatPosition := Vector2(die.global_position.x, die.global_position.z)
	for mon : Monigote in _arena.getLivingMonigotes():
		var monFlatPosition := Vector2(mon.global_position.x, mon.global_position.z)
		if mon.global_position.y < _arena.die.global_position.y and\
			dieFlatPosition.distance_squared_to(monFlatPosition) < .5:
			_scores[mon.player.id] += delta
			_linePointers[mon.player.id].visible = true
			var to := mon.global_position * Vector3(1,0,1) + die.global_position * Vector3.UP
			_linePointers[mon.player.id].point(mon.global_position, to)
		else:
			_linePointers[mon.player.id].visible = false
