extends Sprite3D

@export var idleTextures : Array[Texture2D]
@export var jumpingTextures : Array[Texture2D]

var id : int = 0

func _startIdle() -> void:
	texture = idleTextures[id]
	$IdleTimer.start(randf_range(.9, 3))

func _startJump() -> void:
	texture = jumpingTextures[id]
	$JumpingTimer.start(randf_range(.3, 1))

func _ready() -> void:
	id = randi_range(0, 7)
	_startIdle()
