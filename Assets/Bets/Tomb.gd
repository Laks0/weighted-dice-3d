extends Node3D

@export var thumbnails : Array[Texture]
var number : int = 1
var player : int = 0

func _ready():
	$Number.text = "%s°" % number
	$Face.texture = thumbnails[player]
