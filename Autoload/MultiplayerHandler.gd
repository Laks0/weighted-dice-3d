extends Node

var isGameOnline := false
var hostId : int

func isAuthority() -> bool:
	return (not isGameOnline) or multiplayer.get_unique_id() == hostId

## El control que usa el jugador local, hay que setearlo antes de crear los jugadores
var localController : int = 0

# Tipos de mensaje
enum {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY_JOIN,
	LOBBY_CREATE,
	LOBBY_INFO,
	CANDIDATE,
	OFFER,
	ANSWER,
	CHECK_IN
}

## Dado un diccionario de peers crea jugadores para todos los peers con una skin asignada.
## Espera un lobby con la data de los jugadores.
## El control que usan los jugadores se decide después localmente.
## Solo llamar esta función si ya está armado el sistema de conexión
func createAllPlayers(lobby : Lobby):
	var connectedPlayers := lobby.getPlayerNames()
	hostId = lobby.hostId
	set_multiplayer_authority(hostId)
	if not isAuthority():
		return
	
	var data : Dictionary = {}
	var allSkins = PlayerHandler.Skins.values()
	for id in connectedPlayers.keys():
		var playerName = connectedPlayers[id]
		var randomSkin = allSkins.pick_random()
		allSkins.erase(randomSkin)
		data[id] = {
			"skin": randomSkin,
			"name": playerName,
			"id": id
		}
	
	_syncPlayers.rpc(data, hostId)

@rpc("any_peer", "reliable", "call_local")
func _syncPlayers(playersData : Dictionary, host : int):
	hostId = host
	PlayerHandler.deleteAllPlayers()
	for data in playersData.values():
		# Todos los jugadores están marcados como que usan el mismo control
		PlayerHandler.createPlayer(localController, data["skin"], data["name"], data["id"])
