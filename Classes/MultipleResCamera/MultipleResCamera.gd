extends Camera3D

## En grados
@export var showSlotRotationX : float = -47
@export var showSlotAnimationTime : float = .3

@export var startGameAnimationTime : float = 1

@export var betSceneCamera : Camera3D
@export var lobbyCamera : Camera3D

## La rotación por defecto
var restRotation : Vector3
var restPosition : Vector3

func _ready():
	restRotation = rotation_degrees
	restPosition = position
	
	if not is_instance_valid(betSceneCamera) or not is_instance_valid(lobbyCamera):
		return
	position = lobbyCamera.position
	rotation_degrees = lobbyCamera.rotation_degrees

func _process(_delta):
	%HiResCamera.position = position
	%HiResCamera.rotation = rotation
	%HiResCamera.fov = fov
	
	%LowResCamera.position = position
	%LowResCamera.rotation = rotation
	%LowResCamera.fov = fov
	
	%FullCamera.position = position
	%FullCamera.rotation = rotation
	%FullCamera.fov = fov

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
	moveTo(restPosition, restRotation.x)

func startBettingAnimation() -> void:
	moveTo(betSceneCamera.position, betSceneCamera.rotation_degrees.x)

func moveTo(newPos : Vector3, rotationDegreesX : float) -> void:
	var transformTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	transformTween.tween_property(self, "rotation_degrees:x", rotationDegreesX, startGameAnimationTime)
	transformTween.parallel().tween_property(self, "position", newPos, startGameAnimationTime)

func startShake(magnitude : float, time : float) -> void:
	var initialPos = position
	var elapsedTime := .0
	
	while elapsedTime < time:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0
		) * (time - elapsedTime) / time
		
		position = initialPos + offset
		elapsedTime += get_process_delta_time()
		await get_tree().process_frame
	
	position = initialPos
