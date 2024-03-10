extends Control

@export var characterSettingScene : PackedScene

func _ready():
	randomize()
	PlayerHandler.deleteAllPlayers()
	BetHandler.round = 0


func _startGame():
	$Label.queue_free()
	
	# Animaciones de cada jugador
	var allSkins = PlayerHandler.Skins.values()
	for c in $Settings.get_children():
		var skin = allSkins.pick_random()
		allSkins.erase(skin)
		PlayerHandler.createPlayer(c.controller, skin, c.playerName)
		
		%Scene3D.chooseMonigote(skin, c.global_position + c.size/2)
		await %Scene3D.finishedAnimation
	
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")

func _process(_delta):
	var allPlayersReady : bool = $Settings.get_children().all(func (selector): 
		return selector.playerReady)
	
	if allPlayersReady and $Settings.get_child_count() > 0:
		_startGame()
		for setting in $Settings.get_children():
			setting.allReady()

func _addPlayerSetting(device : int):
	SfxHandler.playSound("controllerLogin")
	if $Settings.get_child_count() >= PlayerHandler.MAX_PLAYERS:
		return
	
	for setting in $Settings.get_children():
		if setting.controller == device and device != Controllers.AI:
			return
	
	var newSetting = characterSettingScene.instantiate()
	newSetting.controller = device
	$Settings.add_child(newSetting)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("grab_mouse"):
			_addPlayerSetting(Controllers.KB)
		if event.is_action_pressed("grab_kb2"):
			_addPlayerSetting(Controllers.KB2)
	if event is InputEventJoypadButton:
		_addPlayerSetting(event.device)

func _on_add_ai_button_pressed():
	_addPlayerSetting(Controllers.AI)
