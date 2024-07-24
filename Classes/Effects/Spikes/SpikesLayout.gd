extends Node3D

func _ready():
	for c in get_children():
		for spike : Spike in c.get_children():
			spike.set_disable_mode(CollisionObject3D.DISABLE_MODE_REMOVE)

## 0 = este, 3 = sur
func spawnSpikes(dir : int) -> void:
	dir = dir % 4
	
	var spikes : Node = get_children()[dir]
	
	# Warning
	var attackPosition : Vector3 = spikes.position
	var warningPosition := attackPosition
	var displacement := .7
	if dir == 0:
		warningPosition += Vector3(1,0,0) * displacement
	elif dir == 1:
		warningPosition += Vector3(0,0,-1) * displacement
	elif dir == 2:
		warningPosition += Vector3(-1,0,0) * displacement
	elif dir == 3:
		warningPosition += Vector3(0,0,1) * displacement
	
	spikes.visible = true
	spikes.position = warningPosition
	await get_tree().create_timer(.5).timeout
	
	# Ataque
	create_tween().tween_property(spikes, "position", attackPosition, .05)
	spikes.set_process_mode(Node.PROCESS_MODE_INHERIT)
	
	$SpikeSound.play()

## 0 = este, 3 = sur
func despawnSpikes(dir : int) -> void:
	dir = dir % 4
	
	get_children()[dir].set_process_mode(Node.PROCESS_MODE_DISABLED)
	get_children()[dir].visible = false
