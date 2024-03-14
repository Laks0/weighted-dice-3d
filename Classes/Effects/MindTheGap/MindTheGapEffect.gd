extends Effect

@export var GapScene : PackedScene

const GAP_AMMOUNT = 5
var gaps : Array[Gap]

var padding = 1

func start():
	$Startup.play()
	if not MultiplayerHandler.isAuthority():
		return
	
	for _i in range(GAP_AMMOUNT):
		spawnGap.rpc(arena.getRandomPosition(1, 0.1))

@rpc("authority", "call_local", "reliable")
func spawnGap(pos : Vector3):
	var gap : Gap = GapScene.instantiate()
	gap.position = pos
	gaps.append(gap)
	arena.add_child(gap, true)

func end():
	for gap in gaps:
		if is_instance_valid(gap):
			gap.delete()
	gaps.clear()
