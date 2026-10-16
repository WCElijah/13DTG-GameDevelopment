extends Node3D

@export var initial_rotating_speed = 8.0  # in deg per seconsd
@export var rotation_speed_inc = 2.0
@export var player_anti_rotating_speed = 15.0  # the speed we put against the rotating ship from capsisizing

@export var max_rotation_angle = 40.0 
@export var angle_where_water_comes_in = 20.0
@export var ship_dps = 15.0

@onready var player_ship = $PlayerShip
@onready var minigame_timer = $MinigameTimer
@onready var time_label = $MinigameUI/TimeLabel
@onready var ship_bar = $MinigameUI/HullBar

var next_scene = 'res://scenes/Story Scenes/ending_cutscene.tscn'

# internal variables
var current_ship_angle = 0.0  # how far the ship is rolled in degrees, positive is to the left
var current_rotating_direction = 1  # 1 is left and -1 is right
var current_rotating_speed = 0.0


func _ready() -> void:
	# stop the bouyancy so it doesnt fight the ship angle, same as roll_ship() in the supplies cutscene
	player_ship.set_physics_process(false)
	current_rotating_speed = initial_rotating_speed


func _process(delta: float) -> void:
	# handle the ship rolling by itself, it gets faster the longer it goes
	current_rotating_speed += rotation_speed_inc * delta
	current_ship_angle += current_rotating_direction * current_rotating_speed * delta

	# handle keeping lvl inputs
	if Input.is_action_pressed('left'):
		current_ship_angle += player_anti_rotating_speed * delta
	if Input.is_action_pressed('right'):
		current_ship_angle -= player_anti_rotating_speed * delta

	# limit how much it goesto theside
	current_ship_angle = clamp(current_ship_angle, -max_rotation_angle, max_rotation_angle)
	player_ship.rotation_degrees.z = current_ship_angle

	# handle taking damage
	if abs(current_ship_angle) > angle_where_water_comes_in:
		$SFXPlayer.stop()
		$SFXPlayer.play()
		ship_bar.value -= ship_dps * delta
		if ship_bar.value <= 0:
			$GameOver.show_game_over()

	# update time left
	time_label.text = 'Time Left: ' + str(round(minigame_timer.time_left))


func _on_roll_timer_timeout() -> void:
	current_rotating_direction = -current_rotating_direction


func _on_minigame_timer_timeout() -> void:
	get_tree().change_scene_to_file(next_scene)
