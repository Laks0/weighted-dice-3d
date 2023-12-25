extends VBoxContainer

var monigote : Monigote

func _ready():
	$Name.text = monigote.player.name
	$Name.modulate = monigote.player.color

func _process(_delta):
	if !is_instance_valid(monigote):
		return
	
	$Grabs.text = str(monigote.grabs)
