extends Control

@export var monigotePos : Vector3
@export var monigoteScene : PackedScene

@export_dir var factsFile : String

@export_dir var arenaPath : String

@onready var arenaScene := ResourceLoader.load_threaded_request(arenaPath)

func _ready():
	var mon = monigoteScene.instantiate()
	mon.player = PlayerHandler.Player.new("", Controllers.KB, PlayerHandler.Skins.values().pick_random())
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

func _process(_delta):
	var progress = []
	var status := ResourceLoader.load_threaded_get_status(arenaPath, progress)
	
	$ProgressBar.value = floor(progress[0] * 100)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(1).timeout
		var arena : PackedScene = ResourceLoader.load_threaded_get(arenaPath)
		get_tree().change_scene_to_packed(arena)
		return
	if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		push_error("Error al cargar la escena")
