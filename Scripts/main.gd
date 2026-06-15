extends Node3D

var cameras: Array

func _ready() -> void:
	cameras = get_tree().get_nodes_in_group("cameras")
	cameras[0].current = true
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print('pressed')
		print(cameras)
		for i in range(len(cameras)):
			if cameras[i].current == true:
				cameras[i].current == false
				if i  == len(cameras) - 1:
					cameras[-1].current == true
				else:
					cameras[i+1].current == true
