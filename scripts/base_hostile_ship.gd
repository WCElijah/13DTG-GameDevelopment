extends RigidBody3D

@export var float_force_multiplier := 1.5
@export var water_drag := 2.0
@export var water_angular_drag := 0.5
var float_force: float

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water
@onready var probes = $Probes.get_children()
var submerged := false

@export var acceleration: float = 250
@export var shooting_distance: float = 30.0

var in_range = false
var target = null
@onready var health_ui = preload("res://scenes/health_ui.tscn")


func _ready() -> void:
	# caluclate water physics
	var total_probes
	if probes.size() > 0:
		total_probes = probes.size()
	else:
		total_probes = 1
	
	float_force = (mass * float_force_multiplier) / total_probes
	water = get_tree().get_first_node_in_group("waters")
	
	generate_health_bar()
	create_range_area()


func _physics_process(delta: float) -> void:
	# boyouancy effect
	submerged = false
	for probe in probes:
		var depth = water.get_height(probe.global_position) - probe.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, probe.global_position - global_position)
	
	# handle target movement
	update_target()
	if target != null:
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target > shooting_distance:
			apply_force(acceleration * mass * -global_transform.basis.z * delta, $Markers/sailPoint.position)
		else:
			shoot_canons()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# handle water drag
	if submerged:
		state.linear_velocity *= 1 - (water_drag * state.step)
		state.angular_velocity *= 1 - (water_angular_drag * state.step)


	# handle rotational follow
	if target == null:
		return
	
	var target_direction = global_position.direction_to(target.global_position)
	var current_forward = -global_transform.basis.z
	var rot_axis = current_forward.cross(target_direction)
	if rot_axis.length_squared() > 0.001:
		rot_axis = rot_axis.normalized()
		var angle = current_forward.angle_to(target_direction)
		state.angular_velocity = rot_axis * angle


func create_range_area():
	var bounding_box_collider = get_node("BoundingBoxArea").get_child(0)
	var bounding_box_shape: BoxShape3D = bounding_box_collider.shape
	var bounding_box_shape_sizes = Vector3(
		bounding_box_shape.size.x * bounding_box_collider.scale.x,
		bounding_box_shape.size.y * bounding_box_collider.scale.y,
		bounding_box_shape.size.z * bounding_box_collider.scale.z)
		
	# generate area3d
	var new_range_area = Area3D.new()
	new_range_area.name = "RangeArea"
	new_range_area.monitoring = true
	new_range_area.monitorable = true
	add_child(new_range_area)
	
	# generate collisionshape
	var new_collision_shape = CollisionShape3D.new()
	new_range_area.add_child(new_collision_shape)
	
	# generate shape of collisionshape
	var new_cylinder_colider = CylinderShape3D.new()
	new_cylinder_colider.height = bounding_box_shape_sizes.y
	new_cylinder_colider.radius = max(bounding_box_shape_sizes.x, bounding_box_shape_sizes.z) / 2.0
	new_cylinder_colider.radius *= Global.range_modifier
	new_collision_shape.shape = new_cylinder_colider
	
	print("Cylinder height: ", new_cylinder_colider.height)
	print("Cylinder radius: ", new_cylinder_colider.radius)
	print("Assigned shape: ", new_collision_shape.shape)

func sink_ship():
	queue_free()


func shoot_canons():
	# get canons
	var canons = get_node("Canons").get_children()
	for canon in canons:
		canon.shoot_canon()


func generate_health_bar():
	var new_health_ui = health_ui.instantiate()
	add_child(new_health_ui)
	new_health_ui.position = Vector3(0,5.23,0)
	get_node("HealthUI").no_hp_left.connect(sink_ship)


func update_target():
	var bodies_in_range = $RangeArea.get_overlapping_bodies()

	in_range = false
	target = null

	for body in bodies_in_range:
		if body.is_in_group("ships") and body == Global.canMountShipBody and Global.isMounted:
			in_range = true
			target = body
			return
	
