extends Path3D

@export var flipH : bool = false

@export_range(.01, .5, .01, "suffix:*length") var minSeparation : float = .01
@export_range(.01, .5, .01, "suffix:*length") var maxSeparation : float = .05

@export var audienceMemberScene : PackedScene

func _ready() -> void:
	var t := 0.0
	var length := curve.get_baked_length()
	while t < 1:
		var pos : Vector3 = curve.sample_baked(t * length)
		var member = audienceMemberScene.instantiate()
		member.position = pos
		member.flip_h = flipH
		member.position.x += randf_range(-.04,.04)
		add_child(member)
		t += randf_range(minSeparation, maxSeparation)
