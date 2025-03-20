extends Node3D

@export var monigote : Monigote
@export var animatedSprite : AnimatedSprite3D

func _ready():
	for c : MonigoteAnimation3D in get_children():
		c.mon = monigote
		c.animatedSprite = animatedSprite
