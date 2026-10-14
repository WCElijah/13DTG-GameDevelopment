extends CanvasLayer

var mouse_mode_before_pause = Input.MOUSE_MODE_VISIBLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			resume()
		else:
			pause()


func pause():
	mouse_mode_before_pause = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	get_tree().paused = true


func resume():
	Input.mouse_mode = mouse_mode_before_pause
	visible = false
	get_tree().paused = false


func _on_button_pressed() -> void:
	resume()
