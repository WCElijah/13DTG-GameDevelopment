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
var current_steering_deg = 0.0
var target_steering_deg = 0.0

var canons
@onready var health_ui = preload("res://scenes/health_ui.tscn")

@export var ship_mesh: MeshInstance3D


func _ready() -> void:
	generate_convex_collisions()
	canons = self.get_node("Canons")
	water = get_tree().get_first_node_in_group("waters")
	
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

	# handle gun fire mode
	if Input.is_action_just_pressed("pressed_f") and Global.isMounted == true and Global.canMountShipBody == self:
		Global.fire_mode = !Global.fire_mode
		if Global.fire_mode:
			get_viewport().get_camera_3d().current = false
			get_node("SpecialCameras/GunDeck").current = true
		else:
			$SpecialCameras/GunDeck.current = false


func _physics_process(delta: float) -> void:
	# movement
	if Global.isMounted == true and Global.canMountShipBody == self and not Global.fire_mode:
		var steering_inc = deg_to_rad(15)

		if Input.is_action_pressed("left"):
			target_steering_deg = current_steering_deg + steering_inc
			#apply_torque(acceleration * mass * Vector3.UP * delta)
		elif Input.is_action_pressed("right"):
			target_steering_deg = current_steering_deg - steering_inc
		
		current_steering_deg = clamp(current_steering_deg, deg_to_rad(-45), deg_to_rad(45))
		current_steering_deg = lerp(current_steering_deg, target_steering_deg, delta)
		$WheelModel.rotation.z = current_steering_deg
		
		if abs(current_steering_deg) > 0.01: # error checking
			var turning_dir
			if current_steering_deg > 0:
				turning_dir = Vector3.UP
			else:
				turning_dir = Vector3.DOWN
			apply_torque(acceleration * mass * turning_dir * abs(current_steering_deg) * delta)

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
		

func sink_ship():
	queue_free()
	

func generate_health_bar():
	var new_health_ui = health_ui.instantiate()
	add_child(new_health_ui)
	new_health_ui.global_position = Vector3(0,0.4,0)
	get_node("HealthUI").no_hp_left.connect(sink_ship)


func generate_convex_collisions():
	# uses a builint HAVCD but using code 
	ship_mesh.create_multiple_convex_collisions() # this generates a staticbody child to meshinstance
	call_deferred('reparent_generated_collisions')  # 'call_defered' runs the function on a safe frame for physics manioulaition like this


func reparent_generated_collisions():
	for child in ship_mesh.get_children():
		if child is StaticBody3D: # because createmultipleconvexcollisons() generates a staticbody
			for shape in child.get_children():
				if shape is CollisionShape3D:
					var global_transform = shape.global_transform
					shape.get_parent().remove_child(shape)  # remove the shape from the tree or parent
					add_child(shape)  # reparent it to the current rigidbody3d
					shape.global_transform = global_transform
					shape.owner = self
			child.queue_free()
	print('succesfully generated : '+ str(self.name))
