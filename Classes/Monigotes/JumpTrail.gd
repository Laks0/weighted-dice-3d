@tool
extends GPUTrail3D

@export var mon : Monigote

func _ready():
	super()
	
	var playerColor : Color = mon.player.color
	texture.gradient.colors[0] = playerColor.lightened(.1)
	texture.gradient.colors[1] = playerColor.darkened(.9)

func onJumpStarted():
	restart()
	visible = true

func onJumpEnded():
	visible = false
