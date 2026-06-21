extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water
@onready var probes = $Probes.get_children()
var submerged := false


func _ready() -> void:
	water = get_tree().get_first_node_in_group("waters")


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
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
