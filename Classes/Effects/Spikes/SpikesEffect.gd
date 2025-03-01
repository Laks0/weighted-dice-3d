extends Effect

@export var SpikesLayout : PackedScene

var layout : Node3D

var dir
var spikesOut := false

func start():
	layout = SpikesLayout.instantiate()
	arena.add_child(layout)
	
	dir = 0
	
	$SpikeTime.start()

func spikeTimeout():
	if spikesOut:
		layout.despawnSpikes(dir)
		spikesOut = false
		return
	
	dir = (dir + 1) % 4
	layout.spawnSpikes(dir)
	
	spikesOut = true

func end():
	$SpikeTime.stop()
	if is_instance_valid(layout):
		layout.queue_free()
