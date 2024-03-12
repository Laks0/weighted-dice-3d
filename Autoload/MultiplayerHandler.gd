extends Node

var isGameOnline := false

func isAuthority() -> bool:
	return (not isGameOnline) or multiplayer.is_server()
