extends Node

var canMount = false
var isMounted = false
var canMountShipBody = null
var fire_mode = false

var range_modifier = 5  # meaning range is 5x that of its size

var is_ship_cam_mode = false


# signals
signal freelook_button_pressed
signal shiplook_button_pressed


func toggle_between_cameras(cameras: Array):
	# get current cam index
	var current_cam_index = null
	for i in range(len(cameras)):
		if cameras[i] == get_viewport().get_camera_3d():
			current_cam_index = i
	
	var new_camera_index = (current_cam_index + 1) % cameras.size()
	cameras[new_camera_index].current = true


func say(dialogue_label, line):
	dialogue_label.text = line
	dialogue_label.visible = true


func hide_dialogue(dialogue_label):
	dialogue_label.visible = false
