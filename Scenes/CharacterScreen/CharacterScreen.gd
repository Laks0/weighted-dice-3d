extends Control

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
	for c in $GridContainer.get_children():
		if !c.added:
			c.queue_free()
			continue
		
		var skin = allSkins.pick_random()
		allSkins.erase(skin)
		PlayerHandler.createPlayer(c.controller, skin, c.nameEditor.text)
		
		c.queue_free()

func _on_start_pressed():
	_createPlayers()
	$Start.queue_free()
	
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
		playerNameLabel.set_layer_mask_value(2, true)
		playerNameLabel.set_layer_mask_value(1, false)
		playerNameLabel.text = player.name
		playerNameLabel.position.y = -1
		playerNameLabel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		playerNameLabel.position.x = wheel.position.x
		add_child(playerNameLabel)
		
		var monigoteNameLabel := Label3D.new()
		monigoteNameLabel.set_layer_mask_value(2, true)
		monigoteNameLabel.set_layer_mask_value(1, false)
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
				get_tree().change_scene_to_file("res://Scenes/Arena/Arena2d.tscn"))

func _process(_delta):
	%HiResTexture.texture = %MultipleResCamera.getHiResTexture()
	%HiResTexture.material.set_shader_parameter("fullTexture", %MultipleResCamera.getFullTexture())
	%HiResTexture.material.set_shader_parameter("lowTexture", %MultipleResCamera.getLowResTexture())
