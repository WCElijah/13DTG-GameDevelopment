extends Node3D

var player : CharacterBody3D

func _ready() -> void:
	for child in get_children():
		if child is CharacterBody3D:
			player = child


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Global.isMounted == false:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * sensitivity)
			cameras[get_current_camera_index()].rotate_x(-event.relative.y * sensitivity)
			cameras[get_current_camera_index()].rotation.x = clamp(cameras[get_current_camera_index()].rotation.x, deg_to_rad(-30), deg_to_rad(60))
