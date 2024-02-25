extends CharacterBody3D
class_name Pushable

## Se emite cuando se escapa de un grab
signal escaped()

@export_range(0, 3) var maxGrabTime  : float = 1
@export             var grabDistance : float = .3

@export var maxPushForce : float = 20 ## La fuerza máxima a la que _es empujado_
@export var failedPushFactor : float = .3 ## El factor de la fuerza máxima que se usa cuando el objeto agarrado se escapa

@export var affectedByGravity : bool = false

var grabbing   := false
var grabbed    := false
var grabDir    := Vector2.RIGHT
var grabBody   : Pushable
var pushFactor : float = 0

var color := Color.WHITE

var timer : Timer = Timer.new() # Timer para el grab

func _ready():
	timer.one_shot = true
	add_child(timer)

func canBeGrabbed(_grabber) -> bool:
	return true

func canGrab() -> bool:
	return not grabbed

func onGrabbed():
	grabbed = true

func onPushed(_dir : Vector2, _factor : float, _pusher : Pushable):
	grabbed = false
	color = Color.WHITE
	
	# Permite colisionar con el que lo agarró devuelta
	# IMPORTANTE: esto significa que los pushables no pueden tener excepciones
	# de colisión
	for e in get_collision_exceptions():
		remove_collision_exception_with(e)

## Devuelve si el grab fue exitoso o no
func startGrab(body : Pushable) -> bool:
	if not canGrab():
		return false
	if not body.canBeGrabbed(self):
		return false
	
	grabbing = true
	
	timer.start(maxGrabTime)
	
	grabBody = body
	body.onGrabbed()

	# En caso de que se escape
	body.connect("escaped", func ():
		onGrabbingEscaped(body)
		pushFactor = failedPushFactor
		push())

	return true

func onGrabbingEscaped(body : Pushable) -> void:
	pass

func push():
	if not grabbing:
		return
	
	grabbing = false
	timer.stop()
	
	if not is_instance_valid(grabBody):
		return
	
	grabBody.onPushed(grabDir, pushFactor, self)
	grabBody = null

func _physics_process(delta):
	if grabbed:
		return
	
	if affectedByGravity and !is_on_floor():
		velocity.y -= 20 * delta

func onGrabbing():
	if not is_instance_valid(grabBody):
		return
	
	# Determina la fuerza dependiendo del tiempo
	var t = (grabBody.maxGrabTime - timer.time_left) / grabBody.maxGrabTime # Para que vaya del 0 al 1
	pushFactor = (pow(t, 3) * 4/5 + .2) # t³ * 4/5 + .2
	grabBody.color = Color(1, 1-pushFactor, 1-pushFactor)
	
	# Prohibe al cuerpo colisionar con el que lo agarra
	grabBody.add_collision_exception_with(self)
	
	# Pone el cuerpo agarrado a grabDistance de distancia en la dirección de grabDir
	var dir3d := Vector3(grabDir.x, 0, grabDir.y)
	if dir3d == Vector3.ZERO:
		dir3d = Vector3.RIGHT
	var newPosition = position + dir3d.normalized() * grabBody.grabDistance
	grabBody.position = newPosition
