# Credts to: https://youtu.be/v4IEPi1c0eE?si=s-a95XTROJM22NDR 
extends CharacterBody3D

@export var float_force := 2.5
@export var water_drag := 0.15  # stops bouncing faster

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# movement settings
const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5

@onready var pivot := $Pivot
@onready var player_cameras = $Pivot.get_children()
var is_ship_cam_mode = false

var sensitivity = 0.01

# water settings
var water
var submerged := false


func _ready() -> void:
	Global.freelook_button_pressed.connect(freelook_btn_pressed)
	Global.shiplook_button_pressed.connect(shiplook_btn_pressed)
	water = get_tree().get_first_node_in_group("waters")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not Global.fire_mode:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * sensitivity)
			get_current_player_camera().rotate_x(-event.relative.y * sensitivity)
			get_current_player_camera().rotation.x = clamp(get_current_player_camera().rotation.x, deg_to_rad(-30), deg_to_rad(60))


func _process(delta: float) -> void:
	# handle ship mounting
	if Global.canMount == true and Global.isMounted == false and Global.canMountShipBody != null:
		var keybind_message = "Press E to enter"
		# show enter ship keybind
		$"../MainUI".show_keybind_label(keybind_message)
		
		# enter ship
		if Input.is_action_just_pressed("pressed_e"):
			var ships = get_tree().get_nodes_in_group("ships")
			for ship in ships:
				if ship == Global.canMountShipBody:
					Global.canMount = false
					Global.isMounted = true
					global_position = Global.canMountShipBody.get_node("Markers/quarterDeck").global_position
					$"../MainUI".hide_keybind_label(keybind_message)
					await get_tree().create_timer(0.5).timeout

	# handle ship exit
	if Global.canMount == false and Global.isMounted == true:
		var keybind_message = "Press E to exit"
		$"../MainUI".show_keybind_label(keybind_message)
		
		if Input.is_action_just_pressed("pressed_e"):
			var ships = get_tree().get_nodes_in_group("ships")
			for ship in ships:
				if ship == Global.canMountShipBody:
					global_position = Global.canMountShipBody.get_node("Markers").get_node("exitPoint").global_position
					Global.isMounted = false
	
	# handle camera change
	if Input.is_action_just_pressed("pressed_f5"):
		if not is_ship_cam_mode:
			var new_camera_index = (get_current_player_camera(true) + 1) % player_cameras.size()
			get_current_player_camera().current = false
			player_cameras[new_camera_index].current = true
		else:
			# change ship cameras
			pass


	# handle water staying with you
	water.global_position.x = lerp(water.global_position.x, global_position.x, 0.1)
	water.global_position.z = lerp(water.global_position.z, global_position.z, 0.1)


func _physics_process(delta: float) -> void:
	var current_speed = WALK_SPEED
	
	# handle staying in ship
	if Global.isMounted == true:
		$CollisionShape3D.disabled = true
		global_position = Global.canMountShipBody.get_node("Markers/quarterDeck").global_position
	else:
		$CollisionShape3D.disabled = false

	# handle bouyancy
	submerged = false
	var depth = water.get_height(global_position) - global_position.y
	if depth > 0:
		submerged = true
		velocity.y += float_force * gravity * depth * delta
		#velocity.y = min(velocity.y, WALK_SPEED)  # stops launches into air
		velocity.x *= (1.0 - water_drag)
		velocity.y *= (1.0 - water_drag)
		velocity.z *= (1.0 - water_drag)
	else:
		# Add the gravity.
		if not is_on_floor() and not Global.isMounted:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# handle sprint
	if Input.is_action_pressed("pressed_shift"):
		current_speed = SPRINT_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Global.isMounted == false:
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func get_current_player_camera(return_index=false):
	for i in range(len(player_cameras)):
		if player_cameras[i].current == true:
			if return_index:
				return i
			else:
				return player_cameras[i]


func freelook_btn_pressed():
	is_ship_cam_mode = false


func shiplook_btn_pressed():
	is_ship_cam_mode = true
