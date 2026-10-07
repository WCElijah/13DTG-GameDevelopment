extends Node

var canMount = false
var isMounted = false
var canMountShipBody = null
var fire_mode = false

var range_modifier = 5  # meaning range is 5x that of its size

var is_ship_cam_mode = false

var camera_tween = null


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



func move_camera(camera, cam_position, position_to_look, duration):
	# camera tweening logic is based on here: https://youtu.be/GN_HMhvYnYA?si=TGG-kzqnN7e3aLZX
	
	if camera_tween: # making sure all camera tweens are inactive
		camera_tween.kill()

	var pretend_camera = Transform3D(Basis(), cam_position)  # make pretend camera with no rotation seen by the empty Basis() and at the position we want it to be 'cam_posiiton'
	pretend_camera = pretend_camera.looking_at(position_to_look)  # essentially the same as look_at() but it only returns the value not actually turn it
	# because pretend_camera isnt an actual node we dont have acces to .rotation so we use .basis
	# but I think that basis returns a quanteriorn thingy (hard asf math) so we get its euler equivalent
	var target_rotation = pretend_camera.basis.get_euler()  

	# manually change them all to degrees
	target_rotation.x = rad_to_deg(target_rotation.x)
	target_rotation.y = rad_to_deg(target_rotation.y)
	target_rotation.z = rad_to_deg(target_rotation.z)

	# stopping the camera spinning the long way round
	var turn = target_rotation - camera.rotation_degrees  # the difference in angles (amount we want to turn)

	# wrapf adds or takes away 360 until the turn is between -180 and 180 (the shorter way) https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-wrapf
	# good stuff https://www.reddit.com/r/godot/comments/108g2rt/quick_visualization_of_3_methods_to_wrap_numbers/ 
	turn.x = wrapf(turn.x, -180, 180)
	turn.y = wrapf(turn.y, -180, 180)
	turn.z = wrapf(turn.z, -180, 180)
	target_rotation = camera.rotation_degrees + turn

	# if duration is 0 then it moves instantly
	if duration == 0:
		camera.position = cam_position
		camera.rotation_degrees = target_rotation
		return
	else:
		# camera.create_tween() so the tween gets removed with the camera when stuff changes later https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-create-tween
		camera_tween = camera.create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
		camera_tween.tween_property(camera, 'position', cam_position, duration)
		camera_tween.tween_property(camera, 'rotation_degrees', target_rotation, duration)


func say(dialogue_label, line):
	dialogue_label.text = line
	dialogue_label.visible = true


func hide_dialogue(dialogue_label):
	dialogue_label.visible = false
