extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water
@onready var probes = $Probes.get_children()
#@onready var cameras = $Cameras.get_children()
var submerged := false


@export var acceleration: float = 150

var input_dir = Vector3.ZERO
var last_direction = Vector3.FORWARD

var current_camera_index = 0
var cameras_init = false
var perspective_cameras
var special_cameras

var fire_mode = false

func _ready() -> void:
	water = get_tree().get_first_node_in_group("waters")
	# assign variables to cameras
	for child in get_children():
		if child.name == "PerspectiveCameras" and child is Node3D:
			perspective_cameras = child.get_children()
		if child.name == "SpecialCameras":
			special_cameras = child.get_children()


func _process(delta: float) -> void:
	# handle perspective camera changes
	if Global.isMounted == true and Global.canMountShipBody == self and fire_mode == false:
		# make it uniqe and check for boat node
		if cameras_init == false:
			for i in range(len(perspective_cameras)):
				if i == current_camera_index:
					perspective_cameras[i].current = true
				else:
					perspective_cameras[i].current = false
	
		if Input.is_action_just_pressed("pressed_f5") and perspective_cameras != null:
			current_camera_index = (current_camera_index + 1) % len(perspective_cameras)
			for i in range(len(perspective_cameras)):
				perspective_cameras[i].current  = (i == current_camera_index)
	
	# handle gun fire mode
	if Input.is_action_just_pressed("pressed_f") and Global.isMounted == true and Global.canMountShipBody == self:
		fire_mode = !fire_mode
		if fire_mode:
			# disable all perspective cameras
			for camera in perspective_cameras:
				camera.current = false
			# switch
			for camera in special_cameras:
				if camera.name == "GunDeck":
					camera.current = true
		else:
			$SpecialCameras/GunDeck.current = false

func _physics_process(delta: float) -> void:
	# movement
	if Global.isMounted == true and Global.canMountShipBody == self:
		if Input.is_action_pressed("left"):
			apply_torque(acceleration * mass * Vector3.UP * delta)
		if Input.is_action_pressed("right"):
			apply_torque(acceleration * mass * Vector3.DOWN * delta)
			
		if Input.is_action_pressed("forward"):
			apply_force(acceleration * mass * -global_transform.basis.z * delta)
	
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
	if body.name == "Player" and Global.isMounted == false:
		Global.canMount = true
		Global.isMounted = false
		Global.canMountShipBody = self


func _on_bounding_box_area_body_exited(body: Node3D) -> void:
	if body.name == "Player" and Global.isMounted == false:
		Global.canMount = false
		Global.isMounted = false
		Global.canMountShipBody = null
