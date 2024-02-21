extends Node3D

@export var halfWidth : float = 7
@export var chipPileScene : PackedScene

func _ready():
	var candidates := BetHandler.getCandidates()
	
	@warning_ignore("integer_division")
	var candidatesOnLeft : int = candidates.size() / 2
	var candidatesOnRight : int = candidates.size() - candidatesOnLeft
	
	for i in range(candidates.size()):
		var xPos : float
		
		var distanceBetweenLeft = halfWidth / (candidatesOnLeft + 2)
		var distanceBetweenRight = halfWidth / (candidatesOnRight + 2)
		
		if i < candidatesOnLeft:
			xPos = -halfWidth + (i+1) * distanceBetweenLeft
		else:
			xPos = i * distanceBetweenRight
		
		var chipPile = chipPileScene.instantiate()
		chipPile.position = Vector3(xPos,.15,-.6)
		chipPile.candidate = candidates[i]
		add_child(chipPile)
