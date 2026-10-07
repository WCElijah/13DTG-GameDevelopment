extends Node3D

@onready var camera = $Camera3D

@onready var player_ship = $PlayerShip
@onready var trader_ship = $TraderShip
@onready var reinforcements = $Reinforcements

@onready var canon = $PlayerShip/Canons/ShipCanon3

@onready var dialogue_panel = $DialogueUI/Panel
@onready var dialogue_label = $DialogueUI/Panel/Label
@onready var fade = $DialogueUI/Fade

@onready var vfx_explosion = preload("res://scenes/vfx_explosion.tscn")

var camera_tween: Tween

var next_scene = "res://scenes/Minigames/aiming_minigame.tscn"  # remember t ochange ts LATER 



func _ready() -> void:
	# setup dialogue
	dialogue_panel.visible = false
	fade.modulate.a = 0
	
	# hide ships at start
	for ship in reinforcements.get_children():
		ship.visible = false
	
	play_cutscene()


func play_cutscene():
	# cinematic starting shot
	move_camera(Vector3(-45, 18, 40), Vector3(0, 2, 0), 0)
	move_camera(Vector3(-30, 10, 25), Vector3(0, 2, 0), 4)
	await get_tree().create_timer(4).timeout

	# shows a trading ship being spotted
	move_camera(Vector3(-3.2, 3.4, 9), trader_ship.position + Vector3(0, 3, 0), 0)
	move_camera(Vector3(-3, 3.3, 8.6), trader_ship.position + Vector3(0, 3, 0), 4)
	say('Lookout: "Sail ahead, Captain. It is just a trader."')
	await get_tree().create_timer(4).timeout

	# captain decides to shoot it
	move_camera(Vector3(-2, 2, 3.9), Vector3(-1.2, 2.1, 6.8), 0)
	move_camera(Vector3(-1.8, 2.1, 4.5), Vector3(-1.2, 2.1, 6.8), 3.5)
	say('Captain: "Then it won\'t shoot back."')
	await get_tree().create_timer(3.5).timeout

	# shows the firing of the canons to the trading ship
	hide_dialogue()
	move_camera(Vector3(9, 3.5, 6), Vector3(3, 2, -1.3), 0)
	await get_tree().create_timer(1).timeout
	canon.rotate_vertical(2)  # tilt it up a bit so the ball reaches the trader
	canon.shoot_canon()
	var ball = get_newest_ball()
	# moves the camera acrooss both of the ships
	move_camera(Vector3(20, 6, 10), Vector3(40, 2, -1.3), 1.5)

	# wait until the ball has flown as far as the trader then remove it
	var hit_distance = trader_ship.position.x - 4
	while is_instance_valid(ball) and ball.global_position.x < hit_distance:
		await get_tree().process_frame
	if is_instance_valid(ball):
		ball.queue_free()

	# ship starts sinking
	move_camera(Vector3(25, 8, 30), trader_ship.position + Vector3(0, 2, 0), 0)
	move_camera(Vector3(28, 9, 34), trader_ship.position + Vector3(0, 2, 0), 5.5)
	start_explosion_effect()
	await get_tree().create_timer(1.5).timeout
	sink_trader_ship()
	say('Lookout: "Captain... that was a navy supply ship."')
	await get_tree().create_timer(4).timeout

	# reinforcements show up shot
	hide_dialogue()
	move_camera(Vector3(2, 5, -17), Vector3(45, 3, -170), 0)
	move_camera(Vector3(2, 5.5, -19), Vector3(45, 3, -170), 4)
	for ship in reinforcements.get_children():
		ship.visible = true
	await get_tree().create_timer(1.5).timeout

	var tween = create_tween()
	tween.tween_property(fade, 'modulate:a', 1.0, 1.0)
	await tween.finished
	end_cutscene()


func move_camera(cam_position, position_to_look, duration):
	# making sure all camera tweens are inactive
	if camera_tween:
		camera_tween.kill()

	# if duration is 0 then it moves instantly
	if duration == 0:
		camera.position = cam_position
		camera.look_at(position_to_look)
		return

	# camera tweening logic is based on here: https://youtu.be/GN_HMhvYnYA?si=TGG-kzqnN7e3aLZX
	var target_basis = Transform3D(Basis(), cam_position).looking_at(position_to_look).basis
	camera_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	camera_tween.tween_property(camera, 'position', cam_position, duration)
	camera_tween.tween_property(camera, 'quaternion', target_basis.get_rotation_quaternion(), duration)


func say(line):
	dialogue_label.text = line
	dialogue_panel.visible = true


func hide_dialogue():
	dialogue_panel.visible = false


func get_newest_ball():
	# get the latest fired ball and not any possbile old ones
	var ball = null
	for child in canon.get_children():
		if child is RigidBody3D:
			ball = child
	return ball


func start_explosion_effect():  # we hve to do this since the original explosion only calls when physics collide
	var explosion = vfx_explosion.instantiate()
	add_child(explosion)
	explosion.position = trader_ship.position + Vector3(-3, 3, 0)  # make it spawn a little higher
	explosion.scale = Vector3(3, 3, 3) 
	explosion.get_node('AnimationPlayer').play('Init')


func sink_trader_ship():
	trader_ship.set_physics_process(false)  # turn off physics for better sinking and no interferance
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(trader_ship, 'rotation:z', deg_to_rad(-80), 6)
	tween.tween_property(trader_ship, 'position:y', -12.0, 6)


func end_cutscene():
	get_tree().change_scene_to_file(next_scene)
