# Credts to: https://youtu.be/v4IEPi1c0eE?si=s-a95XTROJM22NDR 
extends CharacterBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# movement settings
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera3D
var sensitivity = 0.01

# water settings
var water
var submerged := false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func _ready() -> void:
	water = get_tree().get_first_node_in_group("waters")


func _physics_process(delta: float) -> void:
	submerged = false
	var depth = water.get_height(self.global_position) - self.global_position.y
	if depth > 0:
		submerged = true
		velocity.y += gravity * depth 

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
