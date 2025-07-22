@tool
extends GPUTrail3D

@export var mon : Monigote

func _ready():
	super()
	
	var playerColor : Color = mon.player.color
	texture.gradient.colors[0] = playerColor.lightened(.1)
	texture.gradient.colors[1] = playerColor.darkened(.9)

func _process(delta):
	super(delta)

func onJumpStarted():
	var vel2d := mon.unclampedVelocity.normalized()
	var angleToVertical = acos(vel2d.dot(Vector2.UP))
	if (angleToVertical >= 0 and angleToVertical < PI/4) or \
		(angleToVertical > .75*PI and angleToVertical <= PI): 
		rotation.z = PI/2
	else:
		rotation.z = 0
	
	restart()
	visible = true

func onJumpEnded():
	visible = false
