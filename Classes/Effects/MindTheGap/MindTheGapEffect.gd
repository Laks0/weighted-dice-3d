extends Effect

@export var GapScene : PackedScene

const GAP_AMMOUNT = 5
var gaps : Array[Gap]

var padding = 1

func start():
	$Startup.play()
	for _i in range(GAP_AMMOUNT):
		var gap : Gap = GapScene.instantiate()
		gaps.append(gap)
		
		gap.position = arena.getRandomPosition(1, 0.1)
		
		arena.add_child(gap)

func end():
	for gap in gaps:
		if is_instance_valid(gap):
			gap.delete()
	gaps.clear()
