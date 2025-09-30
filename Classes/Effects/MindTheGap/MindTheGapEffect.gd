extends Effect

@export var GapScene : PackedScene

const GAP_AMMOUNT = 6
var gaps : Array[Gap]

var padding = 1

func start():
	var positions := arena.sampleRandomPositions(GAP_AMMOUNT)
	for pos in positions:
		$Open.pitch_scale *= 1.15
		$Open.play()
		var gap : Gap = GapScene.instantiate()
		gaps.append(gap)
		
		gap.position = pos
		
		arena.add_child(gap)
		await get_tree().create_timer(0.2).timeout

func end():
	for gap in gaps:
		if is_instance_valid(gap):
			gap.delete()
	gaps.clear()
