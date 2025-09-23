extends Camera3D
class_name MultipleResCamera

@export var startGameAnimationTime : float = 1

@export var startCamera : Camera3D

## La rotación por defecto
var restRotation : Vector3
var restPosition : Vector3

func _ready():
	if not is_instance_valid(startCamera):
		return
	
	position = startCamera.global_position
	rotation_degrees = startCamera.rotation_degrees

func goToCamera(obj : Camera3D, time := .3) -> Tween:
	return moveTo(obj.global_position, obj.rotation_degrees.x, time)

func moveTo(newPos : Vector3, rotationDegreesX : float, time := .3) -> Tween:
	$wooshPlayer.playSound("wooshTrans")
	var transformTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	transformTween.tween_property(self, "rotation_degrees:x", rotationDegreesX, time)
	transformTween.parallel().tween_property(self, "global_position", newPos, time)
	return transformTween

func zoomTo(targetPos : Vector3, zoomDistance : float = 2.5, zoomTime : float = .5) -> Tween:
	var cameraDirection := get_camera_transform().basis.z
	
	var zoomTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	var zoomPos := targetPos + zoomDistance * cameraDirection
	zoomTween.tween_property(self, "position", zoomPos, zoomTime)
	
	return zoomTween

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

func getBillboardTransformForScreenPos(screenPos : Vector2, zDistance : float) -> Transform3D:
	var origin := project_position(screenPos, zDistance)
	var newBasis := Basis.looking_at(global_position - origin, basis.y)
	return Transform3D(newBasis, origin)

func _process(_delta):
	%GhostCamera.transform = transform
	if get_tree().get_nodes_in_group("Transparent3D").is_empty():
		$GhostViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	else:
		$GhostViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	
	$OutlineMesh2.visible = Debug.vars["pixelate"]
