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

var in_range = false
var target_position = null


func _ready() -> void:

	# caluclate water physics
	var total_probes
	if probes.size() > 0:
		total_probes = probes.size()
	else:
		total_probes = 1
	
	float_force = (mass * float_force_multiplier) / total_probes
	water = get_tree().get_first_node_in_group("waters")
	create_range_area()


func _physics_process(delta: float) -> void:
	# boyouancy effect
	submerged = false
	for probe in probes:
		var depth = water.get_height(probe.global_position) - probe.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, probe.global_position - global_position)
	
	# handle follow prechecks
	in_range = false
	var bodies_in_range = get_node("RangeArea").get_overlapping_bodies()
	for body in bodies_in_range:
		if body.is_in_group("ships") and Global.canMountShipBody == body:
			in_range = true
			target_position = body.global_position


	# follow
	if target_position != null:
		var distance_to_target = global_position.distance_to(target_position)
		if distance_to_target > 30:
			apply_force(acceleration * mass * -global_transform.basis.z * delta, $Markers/sailPoint.position)

	print(in_range)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - (water_drag * state.step)
		state.angular_velocity *= 1 - (water_angular_drag * state.step)


	# handle rotational follow
	if in_range:
		var target_dir = global_position.direction_to(target_position)
		var current_forward = -global_transform.basis.z
		var rot_axis = current_forward.cross(target_dir)
		if rot_axis.length_squared() > 0.001:
			rot_axis = rot_axis.normalized()
			var angle = current_forward.angle_to(target_dir)
			state.angular_velocity = rot_axis * angle
		else:
			state.angular_velocity = Vector3.ZERO


func create_range_area():
	var bounding_box_collider = get_node("BoundingBoxArea").get_child(0)
	var new_range_area = Area3D.new()
	new_range_area.name = "RangeArea"
	add_child(new_range_area)
	
	var new_collision_shape = CollisionShape3D.new()
	new_range_area.add_child(new_collision_shape)
	
	var new_cylinder_colider = CylinderShape3D.new()
	new_cylinder_colider.height = bounding_box_collider.shape.size.z
	new_cylinder_colider.radius = sqrt(bounding_box_collider.shape.size.y) * Global.range_modifier
	new_collision_shape.shape = new_cylinder_colider
	
