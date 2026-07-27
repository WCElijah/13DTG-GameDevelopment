extends Node3D

# multimesh
var multimesh_instance: MultiMeshInstance3D
var multimesh: MultiMesh
var grid_width = 50
var grid_length = 50

# wave settings
var water_quad_mesh = "res://Trialing/water_plane_quad_mesh.tres"

@export var material: ShaderMaterial
var noise: Image
var noise_scale: float
var time_scale: float
var height_scale: float

var time: float

func _ready() -> void:
	create_multimesh()

	#noise = material.get_shader_parameter("wave").noise.get_seamless_image(512,512)
	#noise_scale = material.get_shader_parameter("noise_scale")
	#height_scale = material.get_shader_parameter("height_scale")
	#time_scale = material.get_shader_parameter("time_scale")

func _process(delta: float) -> void:
	time += delta
	#material.set_shader_parameter("wave_time", time)
	
	
func create_multimesh():
	multimesh_instance = MultiMeshInstance3D.new()
	multimesh = MultiMesh.new()
	$MultiMeshes.add_child(multimesh_instance)
	multimesh_instance.multimesh = multimesh
	
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = load(water_quad_mesh)
	multimesh.instance_count = grid_length * grid_width
	
	var half_width = (grid_width / 2.0)
	var half_length = (grid_length / 2.0)
	
	var index = 0
	for x in range(grid_width):
		for z in range(grid_length):
			var x_pos = x - half_width
			var z_pos = z - half_length
			var transform = Transform3D()
			transform.origin = Vector3(x_pos, 0, z_pos)
			multimesh.set_instance_transform(index, transform)
			index += 1


func get_instance_water_height(mesh_instance_index):
	var multimesh 
