extends Control

@export var characterSettingScene : PackedScene

var arenaScene := preload("res://Scenes/Arena/Arena.tscn")

var gameStarted := false

func _ready():
	randomize()
	PlayerHandler.deleteAllPlayers()
	BetHandler.round = 0

func _getActiveSettings() -> Array[CharacterSetting]:
	var res : Array[CharacterSetting] = []
	for space in $Settings.get_children():
		for child in space.get_children():
			if child is CharacterSetting:
				res.append(child)
	return res

func _startGame():
	for setting in _getActiveSettings():
		setting.allReady()
	$Label.queue_free()
	for space in $Settings.get_children():
		space.color.a = 0
	
	gameStarted = true
	
	# Animaciones de cada jugador
	var allSkins = PlayerHandler.Skins.values()
	for c in _getActiveSettings():
		var skin = allSkins.pick_random()
		allSkins.erase(skin)
		PlayerHandler.createPlayer(c.controller, skin, c.playerName)
		
		%Scene3D.chooseMonigote(skin, c.global_position + c.size/2)
		await %Scene3D.finishedAnimation
	
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_packed(arenaScene)

func _process(_delta):
	var allPlayersReady : bool = _getActiveSettings().all(func (selector): 
		return selector.playerReady)
	
	if allPlayersReady and _getActiveSettings().size() > 0 and not $Countdown.visible:
		_startContdown()
	if (not allPlayersReady) and $Countdown.visible:
		_stopCountdown()

func _addPlayerSetting(device : int):
	if _getActiveSettings().size() >= PlayerHandler.MAX_PLAYERS:
		return
	
	for setting in _getActiveSettings():
		if setting.controller == device and device != Controllers.AI:
			return
	
	SfxHandler.playSound("controllerLogin")
	
	var newSetting = characterSettingScene.instantiate()
	newSetting.controller = device
	for space in $Settings.get_children():
		if space.get_child_count() == 0:
			space.add_child(newSetting)
			break

var countdownTween : Tween
func _startContdown():
	$Countdown.visible = true
	$Countdown.scale = Vector2.ZERO
	
	countdownTween = create_tween()
	
	for i in range(5, 0, -1):
		countdownTween.tween_callback(func(): $Countdown.text = str(i))
		countdownTween.tween_property($Countdown, "scale", Vector2.ONE, .2)
		countdownTween.tween_property($Countdown, "scale", Vector2.ZERO, .8)
	countdownTween.tween_callback(_startGame)

func _stopCountdown():
	countdownTween.stop()
	$Countdown.visible = false

func _input(event):
	if gameStarted or not event.is_pressed():
		return
	
	if event is InputEventKey:
		if event.is_action_pressed("grab_mouse"):
			_addPlayerSetting(Controllers.KB)
		if event.is_action_pressed("grab_kb2"):
			_addPlayerSetting(Controllers.KB2)
	if event is InputEventJoypadButton:
		# yqs
		await get_tree().process_frame
		_addPlayerSetting(event.device)
