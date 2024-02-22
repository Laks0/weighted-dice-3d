extends Camera3D

## En grados
@export var showSlotRotationX : float = -47
@export var showSlotAnimationTime : float = .3

@export var bettingScreenPosition : Vector3
## En grados
@export var bettingScreenRotationX : float
@export var startGameAnimationTime : float = 1

## La rotación por defecto
var restRotation : Vector3
var restPosition : Vector3

func _ready():
	restRotation = rotation_degrees
	restPosition = position
	
	position = bettingScreenPosition
	rotation_degrees.x = bettingScreenRotationX

func _process(_delta):
	%HiResCamera.position = position
	%HiResCamera.rotation = rotation
	
	%LowResCamera.position = position
	%LowResCamera.rotation = rotation
	
	%FullCamera.position = position
	%FullCamera.rotation = rotation

func getHiResTexture() -> ViewportTexture:
	return $HiResViewport.get_texture()

func getLowResTexture() -> ViewportTexture:
	return $LowResViewport.get_texture()

func getFullTexture() -> ViewportTexture:
	return $FullViewport.get_texture()

func showSlotMachine() -> void:
	var rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	rotationTween.tween_property(self, "rotation_degrees:x", showSlotRotationX, showSlotAnimationTime)

func returnToArena() -> void:
	var transformTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	transformTween.tween_property(self, "rotation_degrees:x", restRotation.x, showSlotAnimationTime)

func startGameAnimation() -> void:
	var transformTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	transformTween.tween_property(self, "rotation_degrees:x", restRotation.x, startGameAnimationTime)
	transformTween.parallel().tween_property(self, "position", restPosition, startGameAnimationTime)
