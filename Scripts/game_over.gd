extends CanvasLayer


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_game_over():
	$"../PauseMenu".process_mode = Node.PROCESS_MODE_DISABLED  # stop Esc from unpausing behind the game over screen
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # so Retry can be clicked
	visible = true
	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
