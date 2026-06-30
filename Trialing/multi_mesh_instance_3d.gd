extends MultiMeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var count = multimesh.instance_count
	
	for i in range(count):
		var transform = Transform3D()
		transform.origin = Vector3(i, 0, 0)
		multimesh.set_instance_transform(i, transform)
