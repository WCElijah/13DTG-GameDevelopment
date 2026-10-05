extends Node3D

# ship settings
@export var float_height := 0.3  # how high the ship sits above the water
@export var float_speed := 2.0  # lower is heavier and smoother

@export var health_ui_position = Vector3(0,0.4,0)

# node references
@export var probes_node: Node3D
@export var wheel_model_node: Node3D
@export var markers_node: Node3D
@export var canons_node: Node3D
@export var gun_deck_camera_node: Node3D

@export var ship_mesh: MeshInstance3D
@onready var health_ui_tscn = preload("res://scenes/health_ui.tscn")

# internal variables
var water_plane_node: MeshInstance3D
var probes: Array[Node]
var canons: Array[Node]
var ship_length: float
var ship_width: float

var health_ui: Sprite3D
var auto_move := false


func _ready() -> void:
	#generate_convex_collisions()  # not needed now the ship is a node3d with no physics
	#generate_health_bar()

	probes = probes_node.get_children()
	canons = canons_node.get_children()
	water_plane_node = get_tree().get_first_node_in_group("waters")
	
	# caluclate ship size from the probes for the tilting
	ship_length = probes_node.get_node('frontLeft').position.distance_to(probes_node.get_node('backLeft').position)
	ship_width = probes_node.get_node('frontLeft').position.distance_to(probes_node.get_node('frontRight').position)


func _process(_delta: float) -> void:
	# handle auto move toggle
	
	# handle canon rotation
	if Global.fire_mode == true and self == Global.canMountShipBody:
		if Input.is_action_just_pressed("arrow_up"):
			for canon in canons:
				canon.rotate_vertical(1)
		elif Input.is_action_just_pressed("arrow_down"):
			for canon in canons:
				canon.rotate_vertical(-1)
		elif Input.is_action_just_pressed("arrow_left"):
			for canon in canons:
				canon.rotate_horizontal(1)
		elif Input.is_action_just_pressed("arrow_right"):
			for canon in canons:
				canon.rotate_horizontal(-1)

	# handle gun fire mode
	if Input.is_action_just_pressed("pressed_f") and Global.isMounted == true and Global.canMountShipBody == self:
		Global.fire_mode = !Global.fire_mode
		if Global.fire_mode:
			get_viewport().get_camera_3d().current = false
			gun_deck_camera_node.current = true
		else:
			gun_deck_camera_node.current = false


func _physics_process(delta: float) -> void:
	# boyouancy effect
	# bouyancy now dosent depend on actual physics but just a effect
	var front_height = 0.0
	var back_height = 0.0
	var left_height = 0.0
	var right_height = 0.0
	for probe in probes:
		var water_height = water_plane_node.get_height(probe.global_position)
		if 'front' in probe.name:
			front_height += water_height / 2
		else:
			back_height += water_height / 2
		if 'Left' in probe.name:
			left_height += water_height / 2
		else:
			right_height += water_height / 2
	
	# height is the average and the tilt comes from the difference between each side
	var target_height = (front_height + back_height) / 2 + float_height
	var target_pitch = atan2(front_height - back_height, ship_length)
	var target_roll = atan2(right_height - left_height, ship_width)
	
	global_position.y = lerp(global_position.y, target_height, float_speed * delta)
	rotation.x = lerp_angle(rotation.x, target_pitch, float_speed * delta)
	rotation.z = lerp_angle(rotation.z, target_roll, float_speed * delta)


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


func sink_ship():
	queue_free()
	

func generate_health_bar():
	var new_health_ui = health_ui_tscn.instantiate()
	add_child(new_health_ui)
	new_health_ui.position = health_ui_position
	health_ui = new_health_ui
	health_ui.no_hp_left.connect(sink_ship)


func generate_convex_collisions():
	# uses a builint HAVCD but using code 
	ship_mesh.create_multiple_convex_collisions() # this generates a staticbody child to meshinstance
	call_deferred('reparent_generated_collisions')  # 'call_defered' runs the function on a safe frame for physics manioulaition like this


func reparent_generated_collisions():
	for child in ship_mesh.get_children():
		if child is StaticBody3D: # because createmultipleconvexcollisons() generates a staticbody
			for shape in child.get_children():
				if shape is CollisionShape3D:
					var saved_global_transform = shape.global_transform
					shape.get_parent().remove_child(shape)  # remove the shape from the tree or parent
					add_child(shape)  # reparent it to the current rigidbody3d
					shape.global_transform = saved_global_transform
					shape.owner = self
			child.queue_free()
	print('succesfully generated : '+ str(self.name))
