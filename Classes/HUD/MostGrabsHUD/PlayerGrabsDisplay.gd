extends VBoxContainer

var monigote : Monigote

func _ready():
	$Name.text = monigote.player.name
	$Name.modulate = monigote.player.color

func _process(_delta):
	if !is_instance_valid(monigote):
		return

	# Este es un mal manejo de la información, pero todo esto es temporario
	$Grabs.text = str(BetHandler.currentBet.grabs[monigote.player.id])

