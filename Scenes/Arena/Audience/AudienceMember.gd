extends Sprite3D

@onready var idleXPosition = texture.region.position.x
@onready var jumpingXPosition = texture.region.position.x + texture.region.size.x * 4

func _startIdle() -> void:
	texture.region.position.x = idleXPosition
	$IdleTimer.start(randf_range(.9, 3))

func _startJump() -> void:
	texture.region.position.x = jumpingXPosition
	$JumpingTimer.start(randf_range(.3, 1))

func _ready() -> void:
	texture.region.position.y += texture.region.size.y * randi_range(0, 9)
	_startIdle()
