extends VBoxContainer

var clientJoined := false

var arenaScene = preload("res://Scenes/Arena/Arena.tscn")

func _ready():
	# Selector de controles
	$ControllerPick.add_item("Keyboard (WASD/Enter)", Controllers.KB)
	$ControllerPick.add_item("Keyboard alt. (Arrows/AltGr)", Controllers.KB2)
	for device in Input.get_connected_joypads():
		$ControllerPick.add_item("Gamepad %s" % device, device)
	
	# Señales del cliente
	$Client.joinedLobby.connect(func (): clientJoined = true)

func _process(_delta):
	if not clientJoined:
		return
	
	#########################
	# Vista después de unirse
	#########################
	
	$NameField.visible = false
	$ControllerPick.visible = false
	$HostButton.visible = false
	$Lobby.visible = false
	$StartClient.visible = false
	$StartServer.visible = false
	
	$ReadyPlayersLabel.visible = true
	$LobbyIdLabel.visible = true
	$ReadyButton.visible = true
	
	$LobbyIdLabel.text = "Lobby id: %s" % $Client.lobby.lobbyId
	$ReadyPlayersLabel.text = "Players ready: %s/%s" % [$Client.lobby.playersReady(),
													$Client.lobby.playersConnected()]
	
	$StartButton.visible = $Client.lobby.areAllPlayersReady() and \
						   $Client.lobby.hostId == $Client.peer.get_unique_id()

func _on_host_button_pressed():
	MultiplayerHandler.localController = $ControllerPick.get_selected_id()
	$Client.createLobby($NameField.text)

func _on_join_button_pressed():
	MultiplayerHandler.localController = $ControllerPick.get_selected_id()
	$Client.joinLobby(%LobbyId.text, $NameField.text)

func _on_start_server_pressed():
	$Server.startServer(9999)

func _on_start_client_pressed():
	$Client.connectToServer("ws://127.0.0.1:9999")

func _on_ready_button_pressed():
	$Client.playerReady.rpc()

# Señal desde el host para empezar el juego
func _on_start_button_pressed():
	MultiplayerHandler.createAllPlayers($Client.lobby)
	startArena.rpc()

@rpc("any_peer", "reliable", "call_local")
func startArena():
	visible = false
	
	if MultiplayerHandler.isAuthority():
		get_parent().add_child(arenaScene.instantiate())
