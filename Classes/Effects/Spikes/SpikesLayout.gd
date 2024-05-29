extends Node3D

func _ready():
	for c in get_children():
		for spike : Spike in c.get_children():
			spike.set_disable_mode(CollisionObject3D.DISABLE_MODE_REMOVE)

## 0 = este, 3 = sur
func spawnSpikes(dir : int) -> void:
	dir = dir % 4
	
	get_children()[dir].set_process_mode(Node.PROCESS_MODE_INHERIT)
	get_children()[dir].visible = true
	
	$SpikeSound.play()

## 0 = este, 3 = sur
func despawnSpikes(dir : int) -> void:
	dir = dir % 4
	
	get_children()[dir].set_process_mode(Node.PROCESS_MODE_DISABLED)
	get_children()[dir].visible = false
