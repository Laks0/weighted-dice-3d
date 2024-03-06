extends Camera3D

## En grados
@export var showSlotRotationX : float = -47
@export var showSlotAnimationTime : float = .3

@export var startGameAnimationTime : float = 1

@export var betSceneCamera : Camera3D
@export var lobbyCamera : Camera3D
@export var leaderboardCamera : Camera3D

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

func showSlotMachine() -> void:
	var rotationTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	rotationTween.tween_property(self, "rotation_degrees:x", showSlotRotationX, showSlotAnimationTime)

func returnToArena() -> void:
	var transformTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	transformTween.tween_property(self, "rotation_degrees:x", restRotation.x, showSlotAnimationTime)

func startLeaderboardAnimation() -> Tween:
	return moveTo(leaderboardCamera.position, leaderboardCamera.rotation_degrees.x)

func startGameAnimation() -> Tween:
	return moveTo(restPosition, restRotation.x)

func startBettingAnimation() -> Tween:
	return moveTo(betSceneCamera.position, betSceneCamera.rotation_degrees.x)

func moveTo(newPos : Vector3, rotationDegreesX : float) -> Tween:
	var transformTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	transformTween.tween_property(self, "rotation_degrees:x", rotationDegreesX, startGameAnimationTime)
	transformTween.parallel().tween_property(self, "position", newPos, startGameAnimationTime)
	return transformTween

func zoomTo(targetPos : Vector3) -> void:
	var zoomTime : float = .5
	var zoomTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	zoomTween.tween_property(self, "rotation_degrees:x", -90, zoomTime)
	zoomTween.parallel()\
		.tween_property(self, "position", Vector3(targetPos.x, targetPos.y + 3, targetPos.z), zoomTime)

func startShake(magnitude : float, time : float) -> void:
	var elapsedTime := .0
	
	while elapsedTime < time:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0
		) * (time - elapsedTime) / time
		
		v_offset = offset.x
		h_offset = offset.y
		elapsedTime += get_process_delta_time()
		await get_tree().process_frame
	
	v_offset = 0
	h_offset = 0
