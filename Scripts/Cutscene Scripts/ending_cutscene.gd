extends Node3D

@export var chasing_ships_speed = 3.0  # slow so they creep up on us for the whole scene

@onready var camera = $Camera3D  # not on the ship this time so it doesnt rock with the waves when it zooms far out

@onready var player_ship = $PlayerShip
@onready var cargos = $PlayerShip/Cargos
@onready var blocking_ships = $BlockingShips  # stopped side on in a line ahead of us so we cant get past
@onready var chasing_ships = $ChasingShips  # the ones that have been chasing us all game, they keep slowly closing in behind us

@onready var dialogue_label = $DialogueUI/DialogueLabel


func _ready() -> void:
	# setup dialogue
	dialogue_label.visible = false

	# same crates gone as the supplies cutscene
	cargos.get_node('Crate4').visible = false
	cargos.get_node('Crate5').visible = false
	cargos.get_node('Crate6').visible = false

	# navy ships dont carry crates
	for ship in blocking_ships.get_children():
		ship.get_node('Cargos').visible = false
		ship.get_node('SloopFlag').set_flag(Global.NAVY_FLAG)
	for ship in chasing_ships.get_children():
		ship.get_node('Cargos').visible = false
		ship.get_node('SloopFlag').set_flag(Global.NAVY_FLAG)

	# the ship is full of water after the keep level minigame so it sits lower
	player_ship.float_height = 0.0

	play_cutscene()


func _process(delta: float) -> void:
	# handle the chasing ships slowly closing in on us
	for ship in chasing_ships.get_children():
		ship.position.z -= chasing_ships_speed * delta


func play_cutscene():
	# from the side, the way ahead is blocked
	Global.move_camera(camera, Vector3(14, 4, 12), Vector3(0, 3, -70), 0)
	Global.move_camera(camera, Vector3(12, 4, 6), Vector3(0, 3, -70), 5)
	await get_tree().create_timer(5).timeout

	# close on the captain
	Global.move_camera(camera, Vector3(-2, 2, 3.9), Vector3(-1.2, 2.1, 6.8), 0)
	Global.move_camera(camera, Vector3(-1.8, 2.1, 4.5), Vector3(-1.2, 2.1, 6.8), 4)
	await get_tree().create_timer(4).timeout

	# looking back, the chasing ships are catching up (same shot as the end of the other cutscenes)
	Global.move_camera(camera, Vector3(2, 5, 17), Vector3(5, 3, 120), 0)
	Global.move_camera(camera, Vector3(2, 5.5, 19), Vector3(5, 3, 120), 4)
	await get_tree().create_timer(4).timeout

	# zoom out from above to show there is nowhere left to go
	Global.move_camera(camera, Vector3(0, 10, 35), Vector3(0, 0, 10), 0)
	Global.move_camera(camera, Vector3(0, 130, 100), Vector3(0, 0, 10), 12)
	await get_tree().create_timer(9).timeout

	Global.say(dialogue_label, 'Nobody remembers why it started.')
	await get_tree().create_timer(4).timeout

	# the game ends here so close it before the chasing ships reach us
	get_tree().quit()