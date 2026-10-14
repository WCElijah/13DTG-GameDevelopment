extends Node3D

# ship settings
@export var float_height := 0.3  # how high the ship sits above the water
@export var float_speed := 2.0  # lower is heavier and smoother

# node references
@export var ship_mesh: MeshInstance3D

# internal variables
var water_plane_node: MeshInstance3D
var probe_points: Dictionary
var ship_length: float
var ship_width: float


func _ready() -> void:
	water_plane_node = get_tree().get_first_node_in_group("waters")
	
	# get_aabb() gives the smallest box that fits around the whole model (AABB = axis aligned bounding box)
	# https://docs.godotengine.org/en/stable/classes/class_aabb.html
	var box = ship_mesh.transform * ship_mesh.get_aabb()
	ship_length = box.size.z
	ship_width = box.size.x
	
	probe_points = {
		'frontLeft': Vector3(box.position.x, 0, box.position.z),
		'frontRight': Vector3(box.end.x, 0, box.position.z),
		'backLeft': Vector3(box.position.x, 0, box.end.z),
		'backRight': Vector3(box.end.x, 0, box.end.z),
	}


func _physics_process(delta: float) -> void:
	# boyouancy effect
	# bouyancy now dosent depend on actual physics but just a effect
	var front_height = 0.0
	var back_height = 0.0
	var left_height = 0.0
	var right_height = 0.0
	for probe_name in probe_points:
		# to_global() changes a point from the ships space into the worlds space so it moves and turns with the ship
		# ref to https://docs.godotengine.org/en/stable/classes/class_node3d.html#class-node3d-method-to-global
		# each side has 2 probes so adding half of each one gives the average for that side
		var water_height = water_plane_node.get_height(to_global(probe_points[probe_name]))
		if 'front' in probe_name:
			front_height += water_height / 2
		else:
			back_height += water_height / 2
		if 'Left' in probe_name:
			left_height += water_height / 2
		else:
			right_height += water_height / 2
	
	var target_height = (front_height + back_height) / 2 + float_height
	
	# atan2 gives the angle of a slope that goes up by y over a distance of x
	# so if the front water is higher than the back the angle is positive and the front of the ship tilts up
	# its the same as trig inverse tan(angle): calc coming to haunt me bruh
	# for more info and ref here it is boomers: https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-atan2
	var target_pitch = atan2(front_height - back_height, ship_length)
	var target_roll = atan2(right_height - left_height, ship_width)

	global_position.y = lerp(global_position.y, target_height, float_speed * delta)
	rotation.x = lerp_angle(rotation.x, target_pitch, float_speed * delta)
	rotation.z = lerp_angle(rotation.z, target_roll, float_speed * delta)