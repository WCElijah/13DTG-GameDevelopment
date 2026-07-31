extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water
@onready var probes = $Probes.get_children()
#@onready var cameras = $Cameras.get_children()
var submerged := false


@export var acceleration: float = 100

var input_dir = Vector3.ZERO
var last_direction = Vector3.FORWARD

var current_camera_index = 0


func _ready() -> void:
	water = get_tree().get_first_node_in_group("waters")
	#if not cameras:
		#for i in cameras.size():
			#cameras[i].current = (i == 0)


func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#current_camera_index = (current_camera_index + 1) % cameras.size()
		#for i in cameras.size():
			#cameras[i].current  = (i == current_camera_index)
	
	pass


func _physics_process(delta: float) -> void:
	## movement
	#if Input.is_action_pressed("left"):
		#apply_torque(acceleration * mass * Vector3.UP)
	#if Input.is_action_pressed("right"):
		#apply_torque(acceleration * mass * Vector3.DOWN)
		#
	#if Input.is_action_pressed("forward"):
		#apply_force(acceleration * mass * -global_transform.basis.z)
	
	# boyouancy effect
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


func _on_bounding_box_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Global.canMount = true


func _on_bounding_box_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		Global.canMount = false
		Global.canMountShipBodyName = body.name
