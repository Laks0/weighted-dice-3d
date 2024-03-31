extends Node

var lobbies = {}

var users := {}

var peer := WebSocketMultiplayerPeer.new()

func _ready():
	peer.peer_connected.connect(onPeerConnected)
	peer.peer_disconnected.connect(onPeerDisconnected)

func onPeerConnected(id):
	users[id] = {}
	_sendDataTo(id, {
		"type": MultiplayerHandler.ID,
		"id": id
	})

func onPeerDisconnected(id):
	users.erase(id)

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		parsePacket(peer.get_packet())

func parsePacket(packet : PackedByteArray):
	if packet == null:
		return
	
	var dataString := packet.get_string_from_utf8()
	var data : Dictionary = JSON.parse_string(dataString)
	
	if data.type == MultiplayerHandler.LOBBY_JOIN:
		joinLobby(data.userId, data.lobbyId, data.playerName)
	elif data.type == MultiplayerHandler.LOBBY_CREATE:
		createLobby(data.hostId, data.hostName)
	# Información que se pasa entre usuarios
	elif data.type == MultiplayerHandler.CANDIDATE or data.type == MultiplayerHandler.ANSWER ||\
			data.type == MultiplayerHandler.OFFER:
		print("Mensaje desde %s hasta %s" % [data.orgPeer, data.id])
		_sendDataTo(data.id, data)

func startServer(port : int):
	peer.create_server(port)
	print_debug("Servidor corriendo en el puerto %s" % port)

func joinLobby(userId, lobbyId, playerName : String = ""):
	if not lobbies.has(lobbyId):
		return
	
	lobbies[lobbyId].addPlayer(userId, playerName)
	
	for p in lobbies[lobbyId].players.keys():
		# Se conecta a todos los usuarios con todos los del lobby
		_sendDataTo(userId, {
			"type": MultiplayerHandler.USER_CONNECTED,
			"id": p
		})
		_sendDataTo(p, {
			"type": MultiplayerHandler.USER_CONNECTED,
			"id": userId
		})
		
		# Se actualiza la data local de lobby de todos los clientes
		_sendDataTo(p, {
			"type": MultiplayerHandler.LOBBY_INFO,
			"players": JSON.stringify(lobbies[lobbyId].players),
			"lobbyId": lobbyId,
			"hostId": lobbies[lobbyId].hostId
		})

func createLobby(hostId : int, hostName : String):
	# Generación del nombre del lobby
	var chars := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
	var lobbyId := ""
	for i in range(6):
		lobbyId += chars[randi() % chars.length()]
	
	lobbies[lobbyId] = Lobby.new(hostId, lobbyId)
	joinLobby(hostId, lobbyId, hostName)
	
	print("Lobby creado con id " + lobbyId)

func _sendDataTo(playerId : int, data : Dictionary):
	peer.get_peer(playerId).put_packet(JSON.stringify(data).to_utf8_buffer())
