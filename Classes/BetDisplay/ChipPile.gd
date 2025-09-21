extends Node3D
class_name ChipPile

@export var fichaMesh : PackedScene
@export var fichaHeight : float = .08

## Solo si isDisplay es false
@export var candidate = 0
## Solo si isDisplay es true
@export var playerIdDisplay = 0

## Altura de la que caen las fichas
@export var ceiling : float = 5

## chips[playerID] = [Fichas del player en el orden que se agregaron]
var chips : Dictionary
## La posición en y en la que va la próxima ficha
var y = 0

## Si se activa, la pila es solo para mostrar fichas y no representa ningún candidato
@export var isDisplay := false

func _ready():
	for playerId in PlayerHandler.getPlayersAliveById():
		chips[playerId] = []
	
	if isDisplay:
		$ChipNumberDisplay.modulate = PlayerHandler.getPlayerById(playerIdDisplay).color
		$ChipNumberDisplay.billboard = BaseMaterial3D.BILLBOARD_ENABLED

func _process(_delta):
	if isDisplay:
		$ChipNumberDisplay.text = str(chips[playerIdDisplay].size())

func addChip(playerId : int, withAnimation : bool = true) -> void:
	var player := PlayerHandler.getPlayerById(playerId)
	var color = player.color
	
	var ficha : MeshInstance3D = fichaMesh.instantiate()
	
	ficha.get_surface_override_material(0).albedo_color = color
	if withAnimation:
		ficha.position.y = ceiling
		
		var heightTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		heightTween.tween_property(ficha, "position:y", y, .05*(ceiling - y))
		heightTween.tween_callback(func(): $AudioStreamPlayer.play())
	else:
		ficha.position.y = y
	
	if randf() < .3:
		ficha.rotation.y += randf_range(-PI/10, PI/10)
	
	add_child(ficha)
	chips[playerId].append(ficha)
	
	y += fichaHeight

func removeChip(playerId : int) -> void:
	if chips[playerId].size() == 0:
		return
	
	var toRemove = chips[playerId].back()
	
	var removedY = toRemove.position.y
	
	chips[playerId].erase(toRemove)
	toRemove.queue_free()
	
	y -= fichaHeight
	for id in PlayerHandler.getPlayersAliveById():
		for chip in chips[id]:
			if chip.position.y < removedY:
				continue
			var heightTween = create_tween().set_ease(Tween.EASE_IN)
			heightTween.tween_property(chip, "position:y", chip.position.y-fichaHeight, .02*(fichaHeight))
			heightTween.tween_callback(func():$AudioStreamPlayer.play())

## Pone la cantidad de fichas de la pila en el banco del jugador de playerIdDisplay (solo si isDisplay == true)
func displayBank():
	if not isDisplay:
		return
	
	clearChips()
	
	for _i in PlayerHandler.getPlayerById(playerIdDisplay).bank:
		addChip(playerIdDisplay, false)

func clearChips():
	y = 0
	for id : int in chips.keys():
		for chip in chips[id]:
			chip.queue_free()
		chips[id] = []

func setLabelVisibility(value : bool) -> void:
	$ChipNumberDisplay.visible = value
