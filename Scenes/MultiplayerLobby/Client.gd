extends Node

signal joinedLobby

var peer := WebSocketMultiplayerPeer.new()
var rtcPeer := WebRTCMultiplayerPeer.new()

var lobby : Lobby = null

func _ready():
	multiplayer.connected_to_server.connect(func (): print("Conectado a servidor RTC"))
	multiplayer.peer_connected.connect(func (id): print("RTC peer conectado: %s" % id))
	multiplayer.peer_disconnected.connect(func (id): print("RTC peer desconectado: %s" % id))

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		parsePacket(peer.get_packet())

func parsePacket(packet : PackedByteArray):
	if packet == null:
		return
	
	var dataString := packet.get_string_from_utf8()
	var data : Dictionary = JSON.parse_string(dataString)
	
	if data.type == MultiplayerHandler.ID:
		rtcPeer.create_mesh(peer.get_unique_id())
		multiplayer.multiplayer_peer = rtcPeer
	
	elif data.type == MultiplayerHandler.LOBBY_INFO:
		if lobby == null:
			lobby = Lobby.new(data.hostId, data.lobbyId)
			joinedLobby.emit()
		lobby.parsePlayerData(data.players)
	
	elif data.type == MultiplayerHandler.USER_CONNECTED:
		createPeer(data.id)
	
	elif data.type == MultiplayerHandler.CANDIDATE:
		if not rtcPeer.has_peer(data.orgPeer):
			return
		print("Id %s got candidate: %s" % [peer.get_unique_id(), data.orgPeer])
		rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
	
	elif data.type == MultiplayerHandler.OFFER:
		if not rtcPeer.has_peer(data.orgPeer):
			return
		rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
	
	elif data.type == MultiplayerHandler.ANSWER:
		if not rtcPeer.has_peer(data.orgPeer):
			return
		rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)

func connectToServer(ip : String):
	peer.create_client(ip)
	print_debug("Cliente corriendo en la dirección: " + ip)

func joinLobby(lobbyId, playerName : String):
	_broadcastData({
		"type": MultiplayerHandler.LOBBY_JOIN,
		"lobbyId": lobbyId,
		"userId": peer.get_unique_id(),
		"playerName": playerName
	})

func createLobby(playerName : String = ""):
	_broadcastData({
		"type": MultiplayerHandler.LOBBY_CREATE,
		"hostId": peer.get_unique_id(),
		"hostName": playerName
	})

# WebRTC
func createPeer(id):
	if id == peer.get_unique_id():
		return
	
	var connection := WebRTCPeerConnection.new()
	connection.initialize({
		# Stun server de Google
		"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]
	})
	connection.session_description_created.connect(offerCreated.bind(id))
	connection.ice_candidate_created.connect(iceCandidateCreated.bind(id))
	
	rtcPeer.add_peer(connection, id)
	
	if id < rtcPeer.get_unique_id():
		connection.create_offer()

func offerCreated(type, data, id):
	if not rtcPeer.has_peer(id):
		return
	
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)

func iceCandidateCreated(midName, indexName, sdpName, id):
	_broadcastData({
		"id": id,
		"orgPeer": peer.get_unique_id(),
		"type": MultiplayerHandler.CANDIDATE,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName
	})

func sendOffer(id, data):
	_broadcastData({
		"id": id,
		"orgPeer": peer.get_unique_id(),
		"type": MultiplayerHandler.OFFER,
		"data": data
	})

func sendAnswer(id, data):
	_broadcastData({
		"id": id,
		"orgPeer": peer.get_unique_id(),
		"type": MultiplayerHandler.ANSWER,
		"data": data
	})

func _broadcastData(data):
	peer.put_packet(JSON.stringify(data).to_utf8_buffer())

@rpc("any_peer", "call_local", "reliable")
func playerReady():
	lobby.setPlayerReady(multiplayer.get_remote_sender_id())
