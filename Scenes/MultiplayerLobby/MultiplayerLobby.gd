extends VBoxContainer

const ADDRESS = "127.0.0.1"
const PORT = 8000

var peer : ENetMultiplayerPeer

var playersConnected := {}
var playerInfo := {
	"name": "",
	"controller": 0,
	"ready": false
}

var clientJoined := false

func _ready():
	peer = ENetMultiplayerPeer.new()
	
	multiplayer.connected_to_server.connect(onConnectedToServer)
	multiplayer.connection_failed.connect(onConnectionFailed)
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	
	# Selector de controles
	$ControllerPick.add_item("Keyboard (WASD/Enter)", Controllers.KB)
	$ControllerPick.add_item("Keyboard alt. (Arrows/AltGr)", Controllers.KB2)
	for device in Input.get_connected_joypads():
		$ControllerPick.add_item("Gamepad %s" % device, device)

func _process(_delta):
	if not clientJoined:
		playerInfo["name"] = $NameField.text
		playerInfo["controller"] = $ControllerPick.get_selected_id()
		return
	
	#########################
	# Vista después de unirse
	#########################
	
	$NameField.visible = false
	$ControllerPick.visible = false
	$HostButton.visible = false
	$JoinButton.visible = false
	
	$ReadyPlayersLabel.visible = true
	$ReadyButton.visible = true
	
	$ReadyPlayersLabel.text = "Players ready: %s/%s" % [ 
		playersConnected.values().filter(func (info): return info["ready"]).size(),
		playersConnected.size()
	]

func onPeerConnected(id : int):
	registerPlayer.rpc_id(id, multiplayer.get_unique_id(), playerInfo)

func onPeerDisconnected(id : int):
	playersConnected.erase(id)

func onConnectedToServer():
	registerPlayer.rpc(multiplayer.get_unique_id(), playerInfo)
	clientJoined = true

func onConnectionFailed():
	print("Failed to connect")

@rpc("any_peer", "reliable", "call_local")
func registerPlayer(id, playerInfo):
	playersConnected[id] = playerInfo

@rpc("any_peer", "reliable", "call_local")
func playerReady(id):
	playersConnected[id]["ready"] = true
	
	if playersConnected.values().all(func (info): return info["ready"]):
		PlayerHandler.isGameOnline = true
		PlayerHandler.createAllOnlinePlayers(playersConnected)
		get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")

func _on_host_button_pressed():
	peer.create_server(PORT, 6)
	multiplayer.multiplayer_peer = peer
	registerPlayer(multiplayer.get_unique_id(), playerInfo)
	clientJoined = true

func _on_join_button_pressed():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_ready_button_pressed():
	playerReady.rpc(multiplayer.get_unique_id())
