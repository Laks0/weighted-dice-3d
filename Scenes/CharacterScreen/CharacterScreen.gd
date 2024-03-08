extends Control

@export var characterSettingScene : PackedScene

@export var wheelScene : PackedScene
@export var wheelSpaceWidth := 7.4
## El tiempo que tarda en dar una rotación las ruedas
@export var wheelRotationTime = .5
@export var font : Font

func _ready():
	randomize()
	PlayerHandler.deleteAllPlayers()
	BetHandler.round = 0

func _createPlayers():
	var allSkins = PlayerHandler.Skins.values()
	for c in $Settings.get_children():
		var skin = allSkins.pick_random()
		allSkins.erase(skin)
		PlayerHandler.createPlayer(c.controller, skin, c.playerName)
		c.queue_free()

func _startGame():
	_createPlayers()
	$Label.queue_free()
	
	var players = PlayerHandler.getPlayersAlive()
	var spaceBetweenWheels = wheelSpaceWidth / (players.size() + 1)
	for i in range(players.size()):
		var player := PlayerHandler.getPlayerByIndex(i)
		var wheel : SlotWheel = wheelScene.instantiate()
		wheel.imageOnFaces = SlotWheel.Faces.SKINS
		wheel.position.x = -wheelSpaceWidth/2 + (i+1) * spaceBetweenWheels
		%SubViewport.add_child(wheel)
		wheel.showFace(player.id, i + 4, wheelRotationTime * (i+4))
		
		var playerNameLabel := Label3D.new()
		playerNameLabel.font = font
		playerNameLabel.render_priority = 2
		playerNameLabel.outline_render_priority = 1
		playerNameLabel.text = player.name
		playerNameLabel.position.y = -1
		playerNameLabel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		playerNameLabel.position.x = wheel.position.x
		add_child(playerNameLabel)
		
		var monigoteNameLabel := Label3D.new()
		monigoteNameLabel.render_priority = 2
		monigoteNameLabel.outline_render_priority = 1
		monigoteNameLabel.font = font
		monigoteNameLabel.position.y = 1
		monigoteNameLabel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		monigoteNameLabel.modulate = player.color
		monigoteNameLabel.position.x = wheel.position.x
		add_child(monigoteNameLabel)
		
		wheel.showAnimationFinished.connect(func ():
			monigoteNameLabel.text = PlayerHandler.getSkinName(player.id)
			
			if i == players.size() - 1:
				await get_tree().create_timer(2).timeout
				get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn"))

func _process(_delta):
	var playersReady = $Settings.get_children()\
		.filter(func (selector : CharacterSetting): return selector.playerReady)\
		.size()
	
	if playersReady == $Settings.get_child_count() and $Settings.get_child_count() > 0:
		_startGame()

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
