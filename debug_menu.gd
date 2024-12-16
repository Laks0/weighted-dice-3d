extends Control
var is_in_arena = false

func _ready() -> void:
	visible = false
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("ui_debug"):
	#	toggleMenu()


func toggleMenu():
	if !visible:
		visible = true
		get_tree().paused = true
	else:
		visible = false
		get_tree().paused = false

func goToLobby():
	PlayerHandler.createDebugPlayers(%CantidadJugadores.selected+1)
	DebugVars.straigthToArena = true
	get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")

func _on_delobby_button_up() -> void:
	goToLobby()

func _on_dearena_button_up() -> void:
	goToLobby()


func _on_spawn_button_button_up() -> void:
	pass # Replace with function body.

func _on_kill_button_button_up() -> void:
	for player in PlayerHandler.getPlayersAlive():
		var lista := $PanelContainer/VBoxContainer/MatarMonigote/ListaMonigotes
		if player.name == lista.get_item_text(lista.selected):
			player.die()


func _on_win_button_button_up() -> void:
	pass # Replace with function body.


func _on_skip_cards_button_up() -> void:
	pass # Replace with function body.


func _on_inmortals_button_up() -> void:
	pass # Replace with function body.


func _on_pausar_dado_button_up() -> void:
	pass # Replace with function body.


func _on_chipdrops_button_up() -> void:
	pass # Replace with function body.


func _on_kill_button_up() -> void:
	pass # Replace with function body.


func _on_PausarDado_button_up() -> void:
	pass # Replace with function body.


func _on_pausardado_button_up() -> void:
	pass # Replace with function body.


func _on_chipdrop_button_up() -> void:
	pass # Replace with function body.
