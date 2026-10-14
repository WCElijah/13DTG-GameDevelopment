extends Node3D

@export var player_ship_speed = 6.0
@export var navy_ship_speed = 6.0

@onready var camera = $PlayerShip/Camera3D

@onready var player_ship = $PlayerShip
@onready var cargos = $PlayerShip/Cargos
@onready var captain = $PlayerShip/Captain
@onready var crewmate = $PlayerShip/Crewmate
@onready var reinforcements = $Reinforcements

@onready var water = $WaterPlane
@onready var water_square_size = water.mesh.size.x / (water.mesh.subdivide_width + 1)  # same as the cargo cutscene

@onready var dialogue_label = $DialogueUI/DialogueLabel

var next_scene = 'res://scenes/Minigames/keep_level_minigame.tscn'


func _ready() -> void:
	# setup dialogue
	dialogue_label.visible = false

	# these crates fell off in the cargo cutscene so they shouldnt be here
	cargos.get_node('Crate4').visible = false
	cargos.get_node('Crate5').visible = false
	cargos.get_node('Crate6').visible = false

	# navy ships dont carry crates
	for ship in reinforcements.get_children():
		ship.get_node('Cargos').visible = false
		ship.get_node('SloopFlag').set_flag(Global.NAVY_FLAG)

	# crewmate stands next to the crates thats left
	crewmate.position = Vector3(-0.3, 0.66, 2.9)

	play_cutscene()


func _process(delta: float) -> void:
	# handle ships moving forward
	player_ship.position.z -= player_ship_speed * delta
	for ship in reinforcements.get_children():
		ship.position.z -= navy_ship_speed * delta

	# handle keeping water with us.
	water.global_position.x = snapped(player_ship.global_position.x, water_square_size)
	water.global_position.z = snapped(player_ship.global_position.z, water_square_size)


func play_cutscene():
	Global.move_camera(camera, Vector3(-16, 7, -12), Vector3(0, 1.5, 10), 0)
	Global.move_camera(camera, Vector3(-15, 5, 2), Vector3(0, 1, 6), 4)
	await get_tree().create_timer(4, false).timeout

	Global.move_camera(camera, Vector3(1, 2.6, 0.2), Vector3(-1.4, 1.2, 2.9), 0)
	Global.move_camera(camera, Vector3(0.8, 2.4, 0.8), Vector3(-1.4, 1.2, 2.9), 4.5)
	Global.say(dialogue_label, 'Crewmate: "This is all the food and water we have left."')
	await get_tree().create_timer(4.5, false).timeout

	Global.move_camera(camera, Vector3(-2, 2, 3.9), Vector3(-1.2, 2.1, 6.8), 0)
	Global.move_camera(camera, Vector3(-1.8, 2.1, 4.5), Vector3(-1.2, 2.1, 6.8), 3.5)
	Global.say(dialogue_label, 'Captain: "How long will it last?"')
	await get_tree().create_timer(3.5, false).timeout

	Global.move_camera(camera, Vector3(1.2, 2.2, 1.6), Vector3(-0.3, 1.6, 2.9), 0)
	Global.move_camera(camera, Vector3(1, 2.2, 2), Vector3(-0.3, 1.6, 2.9), 3.5)
	Global.say(dialogue_label, 'Crewmate: "Three days. Maybe four."')
	await get_tree().create_timer(3.5, false).timeout

	# make the ship sway form one side to the other
	Global.move_camera(camera, Vector3(-12, 2, 3), Vector3(0, 0.5, 3), 0)
	roll_ship(-10, 0.8)
	Global.say(dialogue_label, 'Crewmate: "And she\'s taking on water, Captain."')
	await get_tree().create_timer(2, false).timeout
	roll_ship(0, 1.5)  # level out again
	await get_tree().create_timer(1.5, false).timeout
	player_ship.set_physics_process(true)

	# navy still behind us
	Global.hide_dialogue(dialogue_label)
	Global.move_camera(camera, Vector3(2, 5, 17), Vector3(5, 3, 120), 0)
	Global.move_camera(camera, Vector3(2, 5.5, 19), Vector3(5, 3, 120), 4)
	await get_tree().create_timer(3.5, false).timeout

	get_tree().change_scene_to_file(next_scene)


func roll_ship(angle, duration):
	player_ship.set_physics_process(false)
	var tween = create_tween()
	tween.tween_property(player_ship, 'rotation:z', deg_to_rad(angle), duration)
