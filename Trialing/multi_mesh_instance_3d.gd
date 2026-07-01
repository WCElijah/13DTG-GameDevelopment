extends MultiMeshInstance3D

var count = multimesh.instance_count
var custom_width = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for mesh_index in range(count):
		var width_count = 0
		#if mesh_index <= custom_width:
			#var transform = Transform3D()
			#transform.origin = Vector3(width_count, 0, 0)
			#multimesh.set_instance_transform(mesh_index, transform)
		var transform = Transform3D()
		transform.origin = Vector3(mesh_index, 0, 0)
		multimesh.set_instance_transform(mesh_index, transform)


func reduce(value):
	var lock = true
	while not lock:
		if value > 10:
			pass
