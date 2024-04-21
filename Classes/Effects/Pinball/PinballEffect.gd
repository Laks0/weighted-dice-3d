extends Effect

@export var towerScene : PackedScene
@export var bouncersScene : PackedScene

@export var towerPositions : Array[Vector3] = [Vector3(-4,0,0), Vector3(4,0,0)]

var towers := []
var bouncers : Area3D

func start():
	for pos in towerPositions:
		var t = towerScene.instantiate()
		t.position = pos
		towers.append(t)
		arena.add_child(t)
	
	bouncers = bouncersScene.instantiate()
	arena.add_child(bouncers)
	
	arena.changeWallHue(Color.BLUE)

func end():
	for t in towers:
		t.queue_free()
	towers.clear()
	
	bouncers.queue_free()
	arena.changeWallHue(Color.WHITE)
