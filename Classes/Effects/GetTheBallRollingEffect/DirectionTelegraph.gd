extends RayCast3D
class_name Ball8TrajectoryCalculator

class BallTrajectoryPoint:
	var position : Vector3
	var nextDirection : Vector3
	var nextSpeed : float
	
	func _init(calculator : Ball8TrajectoryCalculator):
		position = calculator.global_position
		nextDirection = calculator.target_position
		nextSpeed = max(0.0, calculator.currentSpeed)

signal trajectoryCalculated(trajectory : Array[BallTrajectoryPoint])

var points : Array[BallTrajectoryPoint]

## Se usa para calcular el radio de la bola, tiene que tener una SphereShape3D
@export var ballCollisionShape : CollisionShape3D
@onready var radius : float = ballCollisionShape.shape.radius

var _friction : float

var calculating := false

var currentSpeed : float = 0

func startCalculating(initialDirection : Vector3, initialSpeed : float, friction : float):
	target_position = initialDirection.normalized() * radius
	_friction = friction
	points = []
	calculating = true
	currentSpeed = initialSpeed

func _endCalculation():
	calculating = false
	points.push_back(BallTrajectoryPoint.new(self))
	trajectoryCalculated.emit(points)
	position = Vector3.ZERO

func _physics_process(_delta):
	if not calculating:
		return
	
	if currentSpeed <= 0:
		_endCalculation()
		return
	
	if (not is_colliding()) or (not get_collider().is_in_group("Walls")):
		position += target_position
		var secondsInStep := target_position.length() / currentSpeed
		currentSpeed -= secondsInStep * _friction
		return
	
	# Encontró una pared
	
	var contactPoint  := get_collision_point()
	var contactNormal := get_collision_normal()
	
	# La posición correcta según el radio de la pelota
	global_position = contactPoint - target_position
	target_position = target_position.bounce(contactNormal)
	
	points.push_back(BallTrajectoryPoint.new(self))
