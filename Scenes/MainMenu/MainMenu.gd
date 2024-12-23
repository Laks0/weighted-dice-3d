extends Control

@export var startScene : PackedScene
var dijoTimba := false

func _ready():
	DebugMenu.is_in_arena = false
	SoundtrackHandler.playTrack()
	for i in range(BetHandler.bets.size()):
		var bet : Bet = BetHandler.bets[i]
		$DebugVars/OnlyBet.add_item(bet.betName, i)
		var idx = $DebugVars/OnlyBet.get_item_index(i)
		$DebugVars/OnlyBet.set_item_metadata(idx, bet)
	
	# Conseguir los efectos
	var i : int = 0
	for dir in DirAccess.get_directories_at("res://Classes/Effects"):
		for file in DirAccess.get_files_at("res://Classes/Effects/%s" % dir):
			if not file.contains("Effect.tscn"):
				continue
			
			$DebugVars/OnlyEffect.add_item(file.trim_suffix("Effect.tscn"), i)
			var idx = $DebugVars/OnlyEffect.get_item_index(i)
			$DebugVars/OnlyEffect.set_item_metadata(idx, "res://Classes/Effects/%s/%s" % [dir, file])
			i += 1
	
	var tween := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($GameName, "position:y", -50, 2).as_relative()
	tween.tween_property($GameName, "position:y", 50, 2).as_relative()
	await get_tree().create_timer(1).timeout
	Narrator.get_node("VOX").volume_db = -5
	if !dijoTimba:
		Narrator.playBank("menu_titulo")
func _on_start_button_pressed():
	Narrator.get_node("VOX").volume_db = -3
	Narrator.playBank("menu_timba")
	dijoTimba = true
	await get_tree().create_timer(1.5).timeout
	SfxHandler.playSound("buttonSelect")
	
	DebugVars.skipCardAnimation = $DebugVars/SkipCards.button_pressed
	DebugVars.dontStartGame = $DebugVars/DontStartGame.button_pressed
	DebugVars.dropAllChips = $DebugVars/DropAllChips.button_pressed
	DebugVars.inmortalMonigotes = $DebugVars/InmortalMonigotes.button_pressed
	
	if $DebugVars/OnlyBet.selected != 0:
		DebugVars.onlyBet = $DebugVars/OnlyBet.get_selected_metadata()
	
	if $DebugVars/OnlyEffect.selected != 0:
		DebugVars.onlyEffect = $DebugVars/OnlyEffect.get_selected_metadata()
	
	if $DebugVars/StraightToArena.button_pressed:
		PlayerHandler.createDebugPlayers($DebugVars/PlayerN.value)
		DebugVars.straigthToArena = true
		get_tree().change_scene_to_file("res://Scenes/Arena/Arena.tscn")
		return
	
	get_tree().change_scene_to_packed(startScene)

var _leaving := false
func _input(event):
	if _leaving:
		return
	if event.is_action_pressed("ui_debug"):
		#DebugMenu.toggleMenu()
		$DebugVars.visible = !$DebugVars.visible
	elif event.is_pressed() and not event is InputEventMouse:
		var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property($StartText, "position:x", -500, .5)
		_on_start_button_pressed()
		_leaving = true
