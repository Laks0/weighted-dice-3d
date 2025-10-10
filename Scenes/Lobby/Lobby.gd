extends Node3D
class_name Briefcase

signal stageFinished

@export var inputDisplayScene : PackedScene

@export var maletin_abre : AudioStreamWAV
@export var maletin_cierra : AudioStreamWAV

@export var readyChipScene : PackedScene

@export var mainCamera : MultipleResCamera

@export var _monigotePositions : Array[Marker3D]
var _monigotes : Array[Monigote]
var _isInsideBriefcase : Dictionary[int, bool]
var _onPartitionsStage := true

var _isReady : Dictionary[int, bool]

func _ready():
	if Debug.vars.skipLobby:
		await get_tree().physics_frame
		end()
		return
	
	_spawnMonigotes()
	$Interior/AnimationPlayer.animation_finished.connect(func (_a):
		$Interior/PlayerInsideDetector.monitoring = true
		for mon in _monigotes:
			mon.unfreeze())
	
	mainCamera.global_transform = $ExteriorCamera.global_transform
	
	var i = 0
	for id in PlayerHandler.getPlayersAliveById():
		var chip = readyChipScene.instantiate()
		chip.position = Vector3(0, .3, -2.5 + i)
		chip.playerId = id
		add_child(chip)
		
		_isReady[id] = false
		
		var area : Area3D = $ChipAreas.get_child(id)
		area.body_entered.connect(func (body):
			if body != chip or body.grabbed:
				return
			_isReady[id] = true
			area.get_node("ReadyLabel").visible = true)
		area.body_exited.connect(func (body):
			if body != chip:
				return
			_isReady[id] = false
			area.get_node("ReadyLabel").visible = false)
		var label : Label3D = area.get_node("PlayerName")
		label.text = PlayerHandler.getPlayerById(id).name
		label.modulate = PlayerHandler.getSkinColor(id)
		label.visible = true
		
		i += 1
	
	$Maletin/AnimationPlayer.play("Cube_003Action_002")
	$Maletin/AudioStreamPlayer.stream = maletin_abre
	mainCamera.global_transform = $ExteriorCamera.global_transform
	$Interior/AnimationPlayer.play("RaisePartitions")

func _spawnMonigotes() -> void:
	_monigotes = PlayerHandler.instantiatePlayers()
	for i in range(_monigotes.size()):
		var mon : Monigote = _monigotes[i]
		add_child(mon)
		mon.freeze()
		mon.stopBeingGrabbed()
		mon.animatedSprite.showName()
		_isInsideBriefcase[mon.player.id] = false
		
		var jumpHint :Sprite3D= inputDisplayScene.instantiate()
		_monigotePositions[i].add_child(jumpHint)
		var direction : float = sign((global_position - _monigotePositions[i].global_position).x)
		jumpHint.position = Vector3(0,.1,-direction)
		jumpHint.rotation.x = -PI/2
		jumpHint.rotation.y = PI/2
		jumpHint.setBindingOnControllersAction("jump", mon.player.inputController)

func _physics_process(_delta: float) -> void:
	if _onPartitionsStage and $Interior/AnimationPlayer.is_playing():
		for i in range(_monigotes.size()):
			_monigotes[i].global_position = _monigotePositions[i].global_position
	
	var allReady = _isReady.values().all(func (v): return v)
	if allReady and not $Maletin/AnimationPlayer.is_playing():
		_startExitAnimation()

func _removePartitions():
	_onPartitionsStage = false
	await mainCamera.goToCamera($InteriorCamera).finished
	$Interior.queue_free()

func onBodyEnteredBriefcase(body: Node3D) -> void:
	if body is Monigote:
		_isInsideBriefcase[body.player.id] = true
		body.resumeBeingGrabbed()
		if _isInsideBriefcase.values().all(func (v : bool): return v):
			_removePartitions()

func _startExitAnimation():
	mainCamera.goToCamera($ExteriorCamera)
	$Maletin/AnimationPlayer.play_backwards("Cube_003Action_002")
	await $Maletin/AnimationPlayer.animation_finished
	end()

func end():
	stageFinished.emit()
	queue_free()
