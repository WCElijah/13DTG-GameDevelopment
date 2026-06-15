extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = $"../Water"
@onready var probes = $ProbeContainer.get_children()
var submerged := false

@export var move_speed: float = 20.0
@export var max_velocity: float = 10.0


func _physics_process(delta: float) -> void:
	submerged = false
	for probe in probes:
		var depth = water.get_height(probe.global_position) - probe.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, probe.global_position - global_position)

	# We create a local variable to store the input direction.


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
	
	# 1. Get input direction from the keyboard/controller
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	# 2. Convert input to a 3D movement vector (X and Z axis)
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# 3. Calculate target force vector
	var target_force := direction * move_speed
	
	# 4. Apply the central force to move the body
	apply_central_force(target_force)
	
	# 5. Clamp velocity so the physics body doesn't accelerate infinitely
	limit_horizontal_velocity()
	
func limit_horizontal_velocity() -> void:
	var horizontal_vel := Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	if horizontal_vel.length() > max_velocity:
		horizontal_vel = horizontal_vel.normalized() * max_velocity
		# Reassign velocity while maintaining any falling/jumping Y velocity
		linear_velocity = Vector3(horizontal_vel.x, linear_velocity.y, horizontal_vel.z)
