extends Node3D

@export var fichaMesh : PackedScene
@export var fichaHeight : float = .1

@export var candidate = 0

func _ready():
	$CandidateLabel.text = BetHandler.getCandidateName(candidate)
	$CandidateLabel.modulate = BetHandler.getCandidateColor(candidate)
	
	var y = 0
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		for _i in range(player.bets[candidate]):
			var ficha : MeshInstance3D = fichaMesh.instantiate()
			
			ficha.get_surface_override_material(0).albedo_color = player.color
			ficha.position.y = y
			ficha.rotation.y = randf_range(-2*PI, 2*PI)
			ficha.scale *= 1.2
			
			add_child(ficha)
			
			y += fichaHeight
