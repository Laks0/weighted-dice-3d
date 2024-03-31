extends RefCounted
class_name Lobby

var lobbyId : String
var hostId : int
var players : Dictionary = {}

func _init(host : int, id : String = ""):
	hostId = host
	lobbyId = id

func addPlayer(id : int, name : String = "") -> void:
	players[id] = {
		"name": name,
		"id": id,
		"ready": false
	}

func playersReady() -> int:
	return players.values().filter(func (p): return p["ready"]).size()

func areAllPlayersReady() -> bool:
	return players.values().all(func (p): return p["ready"])

func playersConnected() -> int:
	return players.size()

func setPlayerReady(id : int) -> void:
	players[id]["ready"] = true

func parsePlayerData(data : String) -> void:
	# Hay que hacerlo de esta manera porque por defecto las claves de un JSON son strings
	for p in JSON.parse_string(data).values():
		var id : int = p["id"]
		players[id] = p

func getPlayerNames() -> Dictionary:
	var res := {}
	for p in players.values():
		res[p.id] = p.name
	return res
