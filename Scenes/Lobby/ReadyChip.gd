extends Pushable
class_name ReadyChip

@export var playerId : int = 0

var monigote : Monigote

func _ready():
	$FichaMesh.get_surface_override_material(0).albedo_color = PlayerHandler.getSkinColor(playerId)

func canBeGrabbed(grabber) -> bool:
	if grabber is Monigote and grabber.player.id != playerId:
		return false
	elif grabber is Monigote:
		monigote = grabber
	
	return super(grabber)
