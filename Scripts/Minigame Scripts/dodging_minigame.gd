extends Node3D

@export var ship_speed = 10.0
@export var turn_speed = 60.0
@export var max_rotation = 80.0  # the ship can't turn further than this to either side, so it never sails backwards
@export var volley_distance = 45.0  # how far ahead of the ship each row of circles appears
@export var circles_per_volley = 9
@export var circle_spacing = 12.0  # metres between the middle of each circle
@export var canon_shot_indicator_scene: PackedScene

@onready var player_ship = $PlayerShip
@onready var water = $WaterPlane
@onready var water_square_size = water.mesh.size.x / (water.mesh.subdivide_width + 1)  # same as the aiming minigame
@onready var top_camera = $TopCamera  # looks straight down at the ship
@onready var minigame_timer = $MinigameTimer

@onready var time_label = $MinigameUI/TimeLabel

var next_scene = 'res://scenes/main.tscn'


func _ready() -> void:
	# setup ui
	top_camera.current = true


func _process(delta: float) -> void:
	# handle movement and turning
	if Input.is_action_pressed('left'):
		player_ship.rotation_degrees.y += turn_speed * delta
	if Input.is_action_pressed('right'):
		player_ship.rotation_degrees.y -= turn_speed * delta

	# limit how much the shpi can turn to either sides
	player_ship.rotation_degrees.y = clamp(player_ship.rotation_degrees.y, -max_rotation, max_rotation)

	# handle movement forward, in the direction the ship is facing
	player_ship.position += -player_ship.transform.basis.z * ship_speed * delta

	# camera stays above the ship, its height is set in the scene
	top_camera.global_position.x = player_ship.global_position.x
	top_camera.global_position.z = player_ship.global_position.z - 12  # a bit ahead so you can see the shots coming

	# handle water stayinh with player
	water.global_position.x = snapped(player_ship.global_position.x, water_square_size)
	water.global_position.z = snapped(player_ship.global_position.z, water_square_size)

	# update time left
	time_label.text = 'Time Left: ' + str(round(minigame_timer.time_left))


func _on_volley_timer_timeout() -> void:
	var volley_z_pos = player_ship.global_position.z - volley_distance
	var empty_gap_slot_no = randi_range(2, circles_per_volley - 3)

	# get the pos of where the volley should start relative to the player's position
	var no_of_spaces_between_circles = circles_per_volley - 1
	var volley_width = no_of_spaces_between_circles * circle_spacing
	var half_volley_width = volley_width / 2
	var first_circle_x_pos = player_ship.global_position.x - half_volley_width

	for circle_index in range(circles_per_volley):
		if circle_index != empty_gap_slot_no:
			var marker = canon_shot_indicator_scene.instantiate()
			add_child(marker)
			marker.global_position = Vector3(first_circle_x_pos + circle_index * circle_spacing, 0, volley_z_pos)
			marker.global_position.y = water.get_height(marker.global_position)


func _on_hit_box_area_entered(area: Area3D) -> void:
	area.queue_free()  # remove the circle so it can't hit the ship again


func _on_minigame_timer_timeout() -> void:
	get_tree().change_scene_to_file(next_scene)
