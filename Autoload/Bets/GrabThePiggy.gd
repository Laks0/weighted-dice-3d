extends Bet

var crown : CharacterBody3D

func _init():
	betType = BetType.ALL_PLAYERS
	betName = "Agarrar el chanchito"
	_scoreOrder = Order.ASCENDING
	_scoreType = ScoreType.INT
	monigoteSignal = MonigoteSignal.CROWN
	
	betDescription = "¿Quién va a sacar más monedas del chanchito?"
	_resultTextSingular = "%s sacó más del chanchito"
	_resultTextPlural = "%s sacaron más del chanchito"
	
	_rowInDefaultSlotWheelImage = 2
	
	videoGuide.file = "res://Scenes/NewBetShow/BetGuides/BetGuide_AgarrarElChanchito.ogv"

func startGame(arena : Arena):
	crown = load("res://Assets/Bets/PiggyBank.tscn").instantiate()
	crown.position = arena.getRandomPosition()
	arena.add_child(crown)
	
	crown.coinOut.connect(func (holder : Monigote):
		_scores[holder.player.id] += 1)
	
	super(arena)

func settle():
	if is_instance_valid(crown):
		crown.queue_free()
	super()
