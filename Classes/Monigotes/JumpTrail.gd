@tool
extends GPUTrail3D

@export var mon : Monigote

func _ready():
	if not Engine.is_editor_hint():
		var playerColor : Color = mon.player.color
		texture.gradient.colors[0] = playerColor.lightened(.1)
		texture.gradient.colors[1] = playerColor.darkened(.9)
	
	super()

func _process(delta):
	if not Engine.is_editor_hint():
		var vel2d := Vector2(mon.velocity.x, mon.velocity.z).normalized()
		var angleToVertical = acos(vel2d.dot(Vector2.UP))
		if (angleToVertical >= 0 and angleToVertical < PI/4) or \
			(angleToVertical > .75*PI and angleToVertical <= PI): 
			rotation.z = PI/2
		else:
			rotation.z = 0
	
	super(delta)

func onJumpStarted():
	restart()
	visible = true

func onJumpEnded():
	visible = false
