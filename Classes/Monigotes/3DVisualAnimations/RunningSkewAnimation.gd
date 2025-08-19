extends MonigoteAnimation3D

@export_range(0,.5) var skewLength := .1
@export var movementNode : Node3D

var maxSpeed : float

func _ready():
	play()

func physicsUpdate(_delta):
	var skewIntensity : float = movementNode.moveVelocity.x / movementNode.MAX_SPEED * skewLength
	resultBasis.y.y = 1 + abs(skewIntensity)
	resultBasis.x.y = skewIntensity
