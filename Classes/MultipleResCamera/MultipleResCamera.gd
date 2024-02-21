extends Camera3D

@export var showSlotRotationX : float = -47
@export var showSlotAnimationTime : float = .3

## La rotación por defecto
var restRotation : Vector3

func _ready():
	restRotation = rotation_degrees

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
	var rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	rotationTween.tween_property(self, "rotation_degrees:x", restRotation.x, showSlotAnimationTime)
