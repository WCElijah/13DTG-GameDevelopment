extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05
@export var buoyancy_damping := 8.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = self.get_parent().get_child(0)

@onready var probes = $ProbeContainer.get_children()

var submerged := false

func _physics_process(delta: float) -> void:
	submerged = false
	var buoyancy := 0.0
	var normal := Vector3.ZERO
	
	for probe in probes:
		var water_height = water.get_height(probe.global_position)
		var depth = water_height - probe.global_position.y

		if depth > 0.0:
			submerged = true

			# upward force
			buoyancy += depth * float_force

			# used for tilt approximation
			normal += Vector3.UP
			
	if submerged:
		velocity.y += (buoyancy - velocity.y * buoyancy_damping) * delta

		# drag in water
		velocity.x *= 1.0 - water_drag * delta
		velocity.z *= 1.0 - water_drag * delta

		# extra damping for smooth floating
		velocity.y *= 1.0 - water_drag * 0.5 * delta
	else:
		# gravity when NOT in water
		if not is_on_floor():
			velocity.y -= gravity * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if submerged:
		# slowly level the body when in water
		rotation.x = lerp_angle(rotation.x, 0.0, 2.0 * delta)
		rotation.z = lerp_angle(rotation.z, 0.0, 2.0 * delta)

	move_and_slide()
