extends Node

@onready var monigote : Monigote = get_parent()
var arena : Arena
@onready var grabArea : Area3D = monigote.get_node("GrabArea")

func _ready():
	if monigote.get_parent() is Arena:
		arena = monigote.get_parent()
	
	monigote.beenGrabbed.connect(addEscapeMovement)
	grabArea.connect("body_entered", tryGrab)
	checkNewGrabs()

func _process(_delta):
	if not is_instance_valid(arena):
		return
	
	var objMonigote : Monigote = arena.getClosestMonigote(monigote.position, [monigote])
	
	if not is_instance_valid(objMonigote):
		return
	
	var monPos2d := Vector2(monigote.position.x, monigote.position.z)
	monigote._movementDir = Vector2.ZERO
	
	if monigote.grabbed:
		return
	
	if monigote.grabbing:
		var secondClosestMon : Monigote = arena.getClosestMonigote(monigote.position, [monigote, monigote.grabBody])
		if not is_instance_valid(secondClosestMon) or secondClosestMon.grabbed:
			monigote.grabDir = monPos2d.direction_to(Vector2.ZERO)
		else:
			var secondPos2d = Vector2(secondClosestMon.position.x, secondClosestMon.position.z)
			monigote.grabDir = monPos2d.direction_to(secondPos2d)
	
	if not (monigote.grabbed or monigote.grabbing):
		var objPos2d = Vector2(objMonigote.position.x, objMonigote.position.z)
		monigote._movementDir = monPos2d.direction_to(objPos2d)

func addEscapeMovement():
	monigote.escapeMovements += 1
	if not monigote.grabbed:
		return
	
	get_tree().create_timer(randf_range(.1,.2)).timeout.connect(addEscapeMovement)

# Cada segundo busca grabs nuevas por si se le pasaron en la señal
func checkNewGrabs():
	for body in grabArea.get_overlapping_bodies():
		tryGrab(body)
	
	await get_tree().create_timer(1).timeout
	checkNewGrabs()

func tryGrab(body : Node3D):
	if not monigote.canGrab():
		return
	if not body is Pushable:
		return
	var obj := body as Pushable
	
	# Delay aleatorio
	await get_tree().create_timer(randf_range(.1,.5)).timeout
	
	# Por si obj se eliminó entre que entró al área y el delay
	if not is_instance_valid(obj):
		return
	
	monigote.startGrab(obj)
	# Tiempo del grab aleatorio
	await get_tree().create_timer(randf_range(.7, 1.5)).timeout
	monigote.push()
