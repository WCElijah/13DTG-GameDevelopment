extends RigidBody3D

# water forces and boyounancy settings
@export var float_force_multiplier := 1.5
@export var water_drag := 2.0
@export var water_angular_drag := 0.1
var float_force: float
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water
@onready var probes = $Probes.get_children()
var submerged := false

# movement settings
@export var acceleration: float = 500
var input_dir = Vector3.ZERO

var special_cameras
var canons

func _ready() -> void:
	canons = self.get_node("Canons")
	water = get_tree().get_first_node_in_group("waters")
	# assign variables to cameras
	for child in get_children():
		if child.name == "PerspectiveCameras" and child is Node3D:
			perspective_cameras = child.get_children()
		if child.name == "SpecialCameras":
			special_cameras = child.get_children()
	
	# caluclate water physics
	var total_probes
	if probes.size() > 0:
		total_probes = probes.size()
	else:
		total_probes = 1
	
	float_force = (mass * float_force_multiplier) / total_probes
	
	# handle signals
	self.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# handle canon rotation
	if Global.fire_mode == true and self == Global.canMountShipBody:
		if Input.is_action_just_pressed("arrow_up"):
			for canon in canons.get_children():
				canon.rotate_vertical(1)
		elif Input.is_action_just_pressed("arrow_down"):
			for canon in canons.get_children():
				canon.rotate_vertical(-1)
		elif Input.is_action_just_pressed("arrow_left"):
			for canon in canons.get_children():
				canon.rotate_horizontal(1)
		elif Input.is_action_just_pressed("arrow_right"):
			for canon in canons.get_children():
				canon.rotate_horizontal(-1)

	# handle perspective camera changes
	if Global.isMounted == true and Global.canMountShipBody == self and Global.fire_mode == false:
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
		Global.fire_mode = !Global.fire_mode
		if Global.fire_mode:
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
		var turn_input = 0.0
		var speed = 1
		if Input.is_action_pressed("left"):
			turn_input += 1.0
			apply_torque(acceleration * mass * Vector3.UP * delta)
		elif Input.is_action_pressed("right"):
			turn_input -= 1.0
			apply_torque(acceleration * mass * Vector3.DOWN * delta)
		
		if turn_input != 0.0:
			angular_velocity.y = turn_input * speed
		else:
			angular_velocity.y = move_toward(angular_velocity.y, 0.0 , speed * 2 * delta)
		
		if Input.is_action_pressed("forward"):
			apply_force(acceleration * mass * -global_transform.basis.z * delta, $Markers/sailPoint.position)

	# boyouancy effect
	submerged = false
	for probe in probes:
		var depth = water.get_height(probe.global_position) - probe.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, probe.global_position - global_position)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - (water_drag * state.step)
		state.angular_velocity *= 1 - (water_angular_drag * state.step)


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


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("canon_balls"):
		body.queue_free()
