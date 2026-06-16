extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = $"../Water"
@onready var probes = $ProbeContainer.get_children()
var submerged := false

@export var move_speed: float = 300
@export var acceleration: float = 50
@export var rotation_speed: float = 50

var input_dir = Vector3.ZERO

var cameras: Array
var current_camera_index = 0

func _ready() -> void:
	cameras = $Cameras.get_children()
	for i in cameras.size():
		cameras[i].current = (i == 0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		current_camera_index = (current_camera_index + 1) % cameras.size()
		for i in cameras.size():
			cameras[i].current  = (i == current_camera_index)


func _physics_process(delta: float) -> void:
	var input_x = Input.get_axis("left", "right")
	var input_z = Input.get_axis("forward", "back")
	input_dir = Vector3(input_x, 0, input_z).normalized()

	submerged = false
	for probe in probes:
		var depth = water.get_height(probe.global_position) - probe.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, probe.global_position - global_position)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
	
	var target_velocity = input_dir * move_speed
	target_velocity.y = state.linear_velocity.y
	
	var velocity_diff = target_velocity - state.linear_velocity
	var force_to_apply = velocity_diff * acceleration

	apply_force(force_to_apply)
	
	if input_dir.length_squared() > 0.001:
		# 1. Calculate the angle the character should face based on input_dir
		var target_angle = atan2(-input_dir.x, -input_dir.z)
		var target_rotation = Quaternion(Vector3.UP, target_angle)
		
		# 2. Smoothly interpolate (SLERP) from current rotation to target rotation
		var current_rotation = state.transform.basis.get_rotation_quaternion()
		var next_rotation = current_rotation.slerp(target_rotation, rotation_speed * state.step)
		
		# 3. Reconstruct the physics transform basis so it rotates safely
		var x_axis = next_rotation * Vector3.RIGHT
		var y_axis = next_rotation * Vector3.UP
		var z_axis = next_rotation * Vector3.BACK
		state.transform.basis = Basis(x_axis, y_axis, z_axis)
