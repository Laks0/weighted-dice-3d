extends Node3D

@export var fichaMesh : PackedScene
@export var fichaHeight : float = .05

@export var candidate = 0

## Altura de la que caen las fichas
@export var ceiling : float = 10

## chips[playerID] = [Fichas del player en el orden que se agregaron]
var chips : Dictionary
## La posición en y en la que va la próxima ficha
var y = 0

## Si se activa, la pila es solo para mostrar fichas y no representa ningún candidato
@export var isDisplay := false

func _ready():
	set_process(not isDisplay)
	
	if isDisplay:
		return
	
	$CandidateLabel.text = BetHandler.getCandidateName(candidate)
	$CandidateLabel.modulate = BetHandler.getCandidateColor(candidate)
	
	for playerId in PlayerHandler.getPlayersAliveById():
		chips[playerId] = []

func _process(_delta):
	$Odds.text = "x%s" % BetHandler.getCandidateOdds(candidate)

func addChip(playerId : int) -> void:
	var player := PlayerHandler.getPlayerById(playerId)
	var color = player.color
	
	var ficha : MeshInstance3D = fichaMesh.instantiate()
	
	ficha.get_surface_override_material(0).albedo_color = color
	ficha.position.y = ceiling
	
	var heightTween = create_tween().set_ease(Tween.EASE_IN)
	heightTween.tween_property(ficha, "position:y", y, .02*(ceiling - y))
	
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