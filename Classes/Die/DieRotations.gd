extends Node3D
class_name DieRotations

@onready var die : Die = get_parent()

func getTransformHavingRolled(i : int) -> Transform3D:
	var faceOneDirection : Vector3
	var faceFourDirection : Vector3
	
	if i == 1:
		faceOneDirection  = Vector3.UP
		faceFourDirection = Vector3.FORWARD
	elif i == 2:
		faceOneDirection  = Vector3.FORWARD
		faceFourDirection = Vector3.LEFT
	elif i == 3:
		faceOneDirection  = Vector3.FORWARD
		faceFourDirection = Vector3.DOWN
	elif i == 4:
		faceOneDirection  = Vector3.FORWARD
		faceFourDirection = Vector3.UP
	elif i == 5:
		faceOneDirection  = Vector3.FORWARD
		faceFourDirection = Vector3.RIGHT
	elif i == 6:
		faceOneDirection  = Vector3.DOWN
		faceFourDirection = Vector3.FORWARD
	
	faceOneDirection *= 3
	faceFourDirection *= 3
	
	return die.transform.looking_at(to_global(faceOneDirection), faceFourDirection)

func setRotationToFace(i : int):
	die.transform = getTransformHavingRolled(i)
