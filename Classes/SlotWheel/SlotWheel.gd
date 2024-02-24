extends MeshInstance3D
class_name SlotWheel

enum Faces {NONE, NUMBERS, SKINS}
@export var imageOnFaces : Faces

signal showAnimationFinished

func _ready():
	if imageOnFaces == Faces.NUMBERS:
		$Numbers.visible = true
	elif imageOnFaces == Faces.SKINS:
		$Skins.visible = true

func rotateTo(n : int) -> void:
	var currentN := _getWheelCurrentFace()
	
	if n == currentN:
		return
	
	if n < currentN:
		rotation.x = rotation.x - 2*PI
	
	var rotationTween := create_tween()
	rotationTween.tween_property(self, "rotation:x", _getFaceRotation(n), .1)

## Las ruedas empiezan en PI/10 y giran PI/5 por cada número
func _getWheelCurrentFace() -> int:
	return floori((rotation.x + PI/10) / (-PI/5))

func _getFaceRotation(n : int) -> float:
	return -PI/10 + n*(PI/5)

func showFace(face : int, rotations : int, time : float) -> void:
	var rotationTween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	rotationTween.tween_property(self, "rotation:x", _getFaceRotation(face) + 2*PI*rotations, time)
	rotationTween.tween_callback(func (): rotation.x -= 2*PI*rotations)
	rotationTween.tween_callback(emit_signal.bind("showAnimationFinished"))
