extends Control

var loadingScene := preload("res://Scenes/LoadingScreen/LoadingScreen.tscn")

var gameStarted := false

func _ready():
	Narrator.playBank("charselscreen")
	randomize()
	PlayerHandler.deleteAllPlayers()
	BetHandler.round = 0
	
	for s1 : CharacterSetting in $Settings.get_children():
		for s2 : CharacterSetting in $Settings.get_children():
			if s1 == s2:
				continue
			
			s1.keyboardStartedEdittingController.connect(s2.onOtherKeyboardStartedEditting)
			s1.keyboardStoppedEdittingController.connect(s2.onOtherKeyboardStoppedEditting)

func _getActiveSettings() -> Array[Node]:
	return $Settings.get_children().filter(func (c): return c.isActive())

func _startGame():
	for setting in $Settings.get_children():
		setting.allReady()
	
	gameStarted = true
	
	# Animaciones de cada jugador
	var allSkins = PlayerHandler.Skins.values()
	for c in _getActiveSettings():
		var skin = allSkins.pick_random()
		allSkins.erase(skin)
		PlayerHandler.createPlayer(c.getController(), skin, c.playerName)
		
		%Scene3D.chooseMonigote(skin, c.global_position + c.size/2)
		await %Scene3D.finishedAnimation
	
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_packed(loadingScene)

func _process(_delta):
	var allPlayersReady : bool = _getActiveSettings().all(func (selector): 
		return selector.isReady())
	
	if allPlayersReady and _getActiveSettings().size() > 1 and not $Countdown.visible:
		_startContdown()
	if (not allPlayersReady) and $Countdown.visible:
		_stopCountdown()
	
	for setting in $Settings.get_children():
		setting.devicesWaiting = _getDevicesWaiting()

func _isDeviceActive(device : int) -> bool:
	return _getActiveSettings().any(func(c): return c.getController() == device)

func _getDevicesWaiting() -> Array[int]:
	var allDevices = Input.get_connected_joypads()
	allDevices.append(Controllers.KB)
	allDevices.append(Controllers.KB2)
	return allDevices.filter(func (id : int): return not _isDeviceActive(id))

func _addPlayerSetting(device : int):
	if _isDeviceActive(device):
		return
	
	for s : CharacterSetting in $Settings.get_children():
		if not s.isActive():
			s.activate(device)
			s.get_node("Login").play()
			break
	

var countdownTween : Tween
func _startContdown():
	$Countdown.visible = true
	$Countdown.scale = Vector2.ZERO
	
	countdownTween = create_tween()
	
	for i in range(3, 0, -1):
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
		if event.is_action_pressed("ui_ok_d%s"%event.device):
			_addPlayerSetting(event.device)
