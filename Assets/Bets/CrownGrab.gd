extends Pushable
class_name CrownGrab

func _ready():
	connect("doubled", emit_signal.bind("escaped"))
