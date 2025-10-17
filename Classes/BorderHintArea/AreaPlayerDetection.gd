extends Area3D

@export var meshes : Array[MeshInstance3D]
@export var pushable : Pushable

func _process(_delta: float) -> void:
	_setAllMeshesLayer(get_overlapping_bodies().any(func (b):
		if b is Monigote:
			return pushable.canBeGrabbed(b) and not b.isDead()
		return false))

func _setAllMeshesLayer(val : bool):
	for mesh : MeshInstance3D in meshes:
		mesh.set_layer_mask_value(3, val)
 
