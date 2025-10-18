extends Area3D

@export var playerId : int
@export var _attractionHeight : float = .6
var _attractionPosition : Vector3

signal playerReady
signal playerUnready

func _ready() -> void:
	if PlayerHandler.getPlayerById(playerId) == null:
		queue_free()
		return
	
	$PlayerName.text = PlayerHandler.getPlayerById(playerId).name
	_attractionPosition = global_position + Vector3.UP * _attractionHeight

func _bodyIsPlayerChip(body : Node3D) -> bool:
	if not body is ReadyChip:
		return false
	var chip := body as ReadyChip
	if chip.playerId != playerId:
		return false
	return true

var _hasChip := false

func _takePosessionOfChip(chip : Node3D):
	await get_tree().create_timer(.05).timeout
	if chip.grabbed or not overlaps_body(chip):
		return
	chip.customMovement = true
	if not _hasChip:
		var t := create_tween()
		t.tween_property(chip, "global_position", _attractionPosition, .1)
		t.tween_callback(func ():
			if _hasChip: playerReady.emit())
	_hasChip = true

func _releaseChip(chip : Node3D):
	chip.customMovement = false
	_hasChip = false
	playerUnready.emit()

func _process(_delta: float) -> void:
	for body : Node3D in get_overlapping_bodies():
		if not _bodyIsPlayerChip(body):
			continue
		
		if body.grabbed:
			_releaseChip(body)
		else:
			_takePosessionOfChip(body)

func _onBodyEntered(body: Node3D) -> void:
	if _bodyIsPlayerChip(body):
		if body.grabbed:
			return
		_takePosessionOfChip(body)

func _onBodyExited(body: Node3D) -> void:
	if _bodyIsPlayerChip(body):
		_releaseChip(body)
