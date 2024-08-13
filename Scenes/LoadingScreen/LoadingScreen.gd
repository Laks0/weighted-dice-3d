extends Control

@export var monigotePos : Vector3
@export var monigoteScene : PackedScene

@export_dir var factsFile : String

func _ready():
	var mon = monigoteScene.instantiate()
	mon.player = PlayerHandler.Player.new("", 0, PlayerHandler.Skins.values().pick_random())
	%SubViewport.add_child(mon)
	mon.freeze()
	mon.dance()
	mon.position = monigotePos
	
	if not FileAccess.file_exists(factsFile):
		return
	
	var dataFile = FileAccess.open(factsFile, FileAccess.READ)
	var facts = JSON.parse_string(dataFile.get_as_text())
	
	var skinName = PlayerHandler.getSkinName(mon.player.id)
	
	$FunFact.text = "Dato curioso: %s" % facts[skinName].pick_random()
