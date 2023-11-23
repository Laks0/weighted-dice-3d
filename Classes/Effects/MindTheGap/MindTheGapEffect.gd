extends Effect

@export var GapScene : PackedScene

const GAP_AMMOUNT = 5
var gaps : Array[Gap]

var padding = 1

func start():
	for _i in range(GAP_AMMOUNT):
		var gap : Gap = GapScene.instantiate()
		gaps.append(gap)
		
		var x = randf_range(-arena.WIDTH/2, arena.WIDTH/2)
		var z = randf_range(-arena.HEIGHT/2, arena.HEIGHT/2)
		
		gap.position = Vector3(x, Globals.SPRITE_HEIGHT, z)
		
		arena.add_child(gap)

func end():
	for gap in gaps:
		if is_instance_valid(gap):
			gap.delete()
	gaps.clear()
