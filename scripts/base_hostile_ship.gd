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
	# handle signals
	self.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
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


func _on_body_entered(body: Node) -> void:
	print('checking')
	if body.is_in_group("canon_balls"):
		print("culled")
		body.queue_free()


func create_range_area():
	var range_radius = sqrt(get_node("BoundingBoxArea").get_child(0).size.z) * Global.range_modifier
	var new_range_area = Area3D.new()
	new_range_area.name = "RangeArea"
	add_child(new_range_area)
	
	var new_collision_shape = CollisionShape3D.new()
	new_range_area.add_child(new_collision_shape)
	
	var new_cylinder_colider = CylinderShape3D.new()
	
