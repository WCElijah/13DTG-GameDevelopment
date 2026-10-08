extends Node3D

@export var player_ship_speed = 6.0
@export var navy_ship_speed = 7.0  # a bit faster so they catch up

@onready var camera = $PlayerShip/Camera3D  # on the ship like the cameras in the aiming minigame

@onready var player_ship = $PlayerShip
@onready var cargos = $PlayerShip/Cargos
@onready var captain = $PlayerShip/Captain
@onready var lookout = $PlayerShip/Lookout
@onready var reinforcements = $Reinforcements

@onready var water = $WaterPlane
@onready var water_square_size = water.mesh.size.x / (water.mesh.subdivide_width + 1)  # cuz when they subdivide it they make an extra cut at the sides not accounted for

@onready var dialogue_label = $DialogueUI/DialogueLabel
@onready var fade = $DialogueUI/Fade

var floating_crates = []  # crates that have hit the water

var next_scene = 'res://scenes/main.tscn'  # change this to minigame 2 when its made


func _ready() -> void:
	# setup dialogue
	dialogue_label.visible = false
	fade.modulate.a = 0
	
	# hide ships at start and take the crates off them since theyre navy ships
	for ship in reinforcements.get_children():
		ship.visible = false
		ship.get_node('Cargos').visible = false
	reinforcements.get_child(0).visible = true  # the first ship is already chasing us
	
	play_cutscene()


func _process(delta: float) -> void:
	# keep ships moving forward (same as the aiming minigame)
	player_ship.position.z -= player_ship_speed * delta
	for ship in reinforcements.get_children():
		ship.position.z -= navy_ship_speed * delta

	# snapped makes it only moves to the position of the next relevant part based on the tile size
	water.global_position.x = snapped(player_ship.global_position.x, water_square_size)
	water.global_position.z = snapped(player_ship.global_position.z, water_square_size)

	# make the thrown crates float on the waves the same way the ship does in base_player_ship.gd
	for crate in floating_crates:
		var water_height = water.get_height(crate.global_position)
		crate.position.y = lerp(crate.position.y, water_height, 2.0 * delta)


func play_cutscene():
	# cam positions are nowrelativ etothe ship
	Global.move_camera(camera, Vector3(14, 6, -12), Vector3(0, 1.5, 10), 0)
	Global.move_camera(camera, Vector3(15, 4, 4), Vector3(0, 1, 4), 3.5)
	await get_tree().create_timer(1.5).timeout
	
	# crates falloff
	roll_ship(-14, 0.6)  # tip the right side down
	await get_tree().create_timer(0.4).timeout
	await crates_fall_off()
	roll_ship(0, 1.2)  # level out again
	
	# tracking the falling crates 
	Global.move_camera(camera, Vector3(12, 5, 2), Vector3(2, 0, 30), 3)
	await get_tree().create_timer(1.2).timeout
	player_ship.set_physics_process(true)
	await get_tree().create_timer(2).timeout

	# looking back atthe dropped crates
	Global.move_camera(camera, Vector3(2.2, 2.6, 2), Vector3(1, 0.5, 60), 0)
	Global.move_camera(camera, Vector3(2.1, 2.6, 2.4), Vector3(1, 0.5, 60), 4)
	Global.say(dialogue_label, 'Crewmate: "We lost half the cargo, Captain."')
	await get_tree().create_timer(4).timeout

	
	Global.move_camera(camera, Vector3(-2, 2, 3.9), Vector3(-1.2, 2.1, 6.8), 0)
	Global.move_camera(camera, Vector3(-1.8, 2.1, 4.5), Vector3(-1.2, 2.1, 6.8), 3.5)
	Global.say(dialogue_label, 'Captain: "Keep running."')
	await get_tree().create_timer(3.5).timeout

	# crewmate checks the canon and finds out they cant fire
	lookout.position = Vector3(1.3, 0.64, -1.33)  # stand behind ShipCanon3
	Global.move_camera(camera, Vector3(-0.5, 1.6, -3.8), Vector3(1.8, 1.0, -1.2), 0)
	Global.move_camera(camera, Vector3(-0.3, 1.6, -3.4), Vector3(1.8, 1.0, -1.2), 4.5)
	Global.say(dialogue_label, 'Crewmate: "The powder went over with the crates. We can\'t fire."')
	await get_tree().create_timer(4.5).timeout

	# more navy ships closing in from behind
	Global.hide_dialogue(dialogue_label)
	Global.move_camera(camera, Vector3(2, 5, 17), Vector3(5, 3, 120), 0)
	Global.move_camera(camera, Vector3(2, 5.5, 19), Vector3(5, 3, 120), 4)
	for ship in reinforcements.get_children():
		ship.visible = true
	await get_tree().create_timer(2.5).timeout

	# fade the screen away
	var tween = create_tween()
	tween.tween_property(fade, 'modulate:a', 1.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_file(next_scene)


func crates_fall_off():
	var falling_crates = [cargos.get_node('Crate4'), cargos.get_node('Crate5'), cargos.get_node('Crate6')]
	for crate in falling_crates:
		# slide across the tilted deck to the edge of the ship
		var slide_tween = create_tween()
		slide_tween.tween_property(crate, 'position:x', 2.8, 0.6)
		await slide_tween.finished

		# fall off the ship into the water
		crate.reparent(self)
		crate.position.x += 1.5
		floating_crates.append(crate)
		
	await get_tree().create_timer(1.0).timeout


func roll_ship(angle, duration):
	player_ship.set_physics_process(false)
	var tween = create_tween()
	tween.tween_property(player_ship, 'rotation:z', deg_to_rad(angle), duration)
