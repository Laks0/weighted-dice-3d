extends Effect

@export var stickAmount : int = 1
@export var stickScene : PackedScene

@export var ball8Scene : PackedScene
var ball8 : CharacterBody3D

var sticks : Array[Node3D]

func start():
	ball8 = ball8Scene.instantiate()
	ball8.set_physics_process(false)
	arena.add_child(ball8)
	
	sticks.clear()
	for _i in range(stickAmount):
		if not MultiplayerHandler.isAuthority():
			break
		
		spawnStick.rpc(arena.getRandomPosition(1, .3))
	
	$AnimationPlayer.play("BallEnter")
	$AnimationPlayer.animation_finished.connect(func (_anim): ball8.set_physics_process(true))
	
	$SpotLight3D.visible = true
	$SpotLight3D.light_energy = 0
	create_tween().tween_property($SpotLight3D, "light_energy", 11, .2)

@rpc("authority", "call_local", "reliable")
func spawnStick(pos : Vector3):
	var stick = stickScene.instantiate()
	stick.position = pos
	sticks.append(stick)
	arena.add_child(stick, true)

func _process(_delta):
	if not is_instance_valid(ball8):
		return
	
	if $AnimationPlayer.is_playing():
		ball8.position = $BallAnimationPos.position
	
	var targetDir = $SpotLight3D.position.direction_to(ball8.position)
	var targetBasis = Basis.looking_at(targetDir)
	$SpotLight3D.basis = $SpotLight3D.basis.slerp(targetBasis, .1)

func end():
	if is_instance_valid(ball8):
		ball8.queue_free()
	
	for s in sticks:
		s.queue_free()
	
	var tween := create_tween()
	tween.tween_property($SpotLight3D, "light_energy", 0, .2)
	tween.tween_callback(func(): $SpotLight3D.visible = false)
