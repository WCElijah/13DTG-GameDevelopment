extends Node3D

@export var player_ship_speed = 8.0
@export var hits_needed = 3  # how many sink must be sunk before we move on
@export var aim_time_limit = 5.0  # time limit 
@export var time_between_ship_spawn = 6.0

@onready var player_ship = $PlayerShip
@onready var water = $WaterPlane
@onready var sail_camera = $PlayerShip/SailCamera
@onready var aim_camera = $PlayerShip/AimCamera
@onready var enemies = $Enemies
@onready var canon = $PlayerShip/Canons/ShipCanon3  # same canon the cutscene fires

@onready var crosshair = $MinigameUI/Crosshair
@onready var info_label = $MinigameUI/InfoLabel
@onready var time_label = $MinigameUI/TimeLabel
@onready var score_label = $MinigameUI/ScoreLabel

@onready var sloop_tscn = preload("res://scenes/Ships/sloop.tscn")
@onready var vfx_explosion = preload("res://scenes/vfx_explosion.tscn")

var next_scene = 'res://scenes/main.tscn'

# internal variables
var time_until_next_ship = 0.0
var state = 'sailing'  # can be 'sailing', 'aiming', 'firing' or 'paused'
var time_left = 0.0  # used for the aim time and for how long the ball can fly
var ball = null  # the canon ball fired
var target_ship = null
var hits = 0


func _ready() -> void:
	time_until_next_ship = time_between_ship_spawn  # start at the beginning

	# setup ui
	crosshair.visible = false
	time_label.visible = false
	sail_camera.current = true
	update_score()


func _process(delta: float) -> void:
	# keep ship moving forward
	player_ship.position.z -= player_ship_speed * delta

	# water following logic applied to the player's ship like in player.gd
	water.global_position.x = player_ship.global_position.x
	water.global_position.z = player_ship.global_position.z
	# keep crosshair node alongside player mouse position (it is still invisble tho in most cases)
	crosshair.position = get_viewport().get_mouse_position()

	if state == 'sailing':
		# count down to the next ship
		time_until_next_ship -= delta
		info_label.text = 'Enemy ship in ' + str(int(time_until_next_ship)) + 's'
		if time_until_next_ship <= 0:
			start_aiming()

	elif state == 'aiming':
		time_left -= delta
		time_label.text = 'Time Left: ' + str(round(time_left))

		if Input.is_action_just_pressed("left_click"):
			fire()
		elif time_left <= 0:
			end_aiming('Too slow! They got away')

	elif state == 'firing':
		# wait for the ball to hit the ship, if it flies too long its a miss
		time_left -= delta
		if time_left <= 0:
			ball.queue_free()
			end_aiming('Missed!')


func start_aiming():
	state = 'aiming'
	time_left = aim_time_limit
	spawn_enemy()

	# swap to the side camera to aim
	aim_camera.current = true
	crosshair.visible = true
	time_label.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN  # hide the normal mouse so only the crosshair shows
	info_label.text = 'Aim at the ship and left click to fire!'


func spawn_enemy():
	# delete previously missed ships
	for ship in enemies.get_children():
		ship.queue_free()

	target_ship = sloop_tscn.instantiate()
	enemies.add_child(target_ship)
	target_ship.global_position = player_ship.global_position + Vector3(70, 0, -20)  # 70m to the right and 20m ahead
	target_ship.global_position.y = 0
	target_ship.rotation_degrees.y = 180  # face the other way of the player (positive z)
	make_hit_box(target_ship)


func make_hit_box(ship):
	# make area3d colllider box for canonball to detect
	var box = ship.ship_mesh.get_aabb()  # the box around the ship model https://docs.godotengine.org/en/stable/classes/class_aabb.html
	var hit_box = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = box.size
	
	hit_box.add_child(shape)
	ship.ship_mesh.add_child(hit_box)
	hit_box.position = box.get_center()

	hit_box.area_entered.connect(on_hit_box_area_entered)


func fire():
	state = 'firing'
	time_left = 3.0  # timeframe where we would check if the canonball actually landed
	crosshair.visible = false
	time_label.visible = false
	info_label.text = 'Fire!'

	canon.shoot_canon()
	ball = canon.get_child(canon.get_child_count() - 1)  # get the newest fired ball as the ball we want to check for a hit
	ball.gravity_scale = 0  # no gravity so the ball goes straight

	# point the ball at the crosshair
	# project_position() converts a 2d point to a 3d position 100m away from the aim camera
	# https://docs.godotengine.org/en/stable/classes/class_camera3d.html#class-camera3d-method-project-position
	ball.look_at(aim_camera.project_position(crosshair.position, 100))


func on_hit_box_area_entered(area):
	# check if it is ball
	if area.get_parent() == ball:
		ball.queue_free()
		hits += 1
		update_score()
		start_explosion_effect(target_ship)
		sink_ship(target_ship)
		end_aiming('Direct hit!')


func end_aiming(message):
	# hanlde ui changes
	target_ship = null
	crosshair.visible = false
	time_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	info_label.text = message

	state = 'paused'  # paused state is just to see the ship sink or go away
	await get_tree().create_timer(2).timeout

	# mvoe on to the next scene if finished
	if hits >= hits_needed:
		get_tree().change_scene_to_file(next_scene)
		return

	# if not finished swich to sailing state
	sail_camera.current = true
	time_until_next_ship = time_between_ship_spawn  # reset the countdown for the next ship
	state = 'sailing'


func start_explosion_effect(ship):  # same as the cutscene one
	var explosion = vfx_explosion.instantiate()
	add_child(explosion)
	explosion.global_position = ship.global_position + Vector3(0, 3, 0)
	explosion.scale = Vector3(3, 3, 3)
	explosion.get_node('AnimationPlayer').play('Init')


func sink_ship(ship):  # same tween idea as the trader ship in the cutscene
	ship.set_physics_process(false)  # stop the bouyancy so it can sink
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(ship, 'rotation:z', deg_to_rad(-80), 3)
	tween.tween_property(ship, 'position:y', -12.0, 3)


func update_score():
	score_label.text = 'Hits: ' + str(hits) + ' / ' + str(hits_needed)
