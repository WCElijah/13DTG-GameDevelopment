extends Node3D


func _ready() -> void:
	for i in range(10):
		create_multimesh(10, i)


func create_multimesh(custom_count, z_index):
	var multimesh_instance = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	$MultiMeshes.add_child(multimesh_instance)
	multimesh_instance.multimesh = multimesh
	
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = preload("res://Trialing/water_plane_quad_mesh.tres")
	multimesh.instance_count = custom_count
	
	for i in range(custom_count):
		var transform = Transform3D()
		transform.origin = Vector3(i, 0, z_index)
		multimesh.set_instance_transform(i, transform)
