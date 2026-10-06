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


func _ready() -> void:
	# setup dialogue
	dialogue_panel.visible = false
	fade.modulate.a = 0
	
	# hide ships at start
	for ship in reinforcements.get_children():
		ship.visible = false
	
	play_cutscene()


func play_cutscene():
	say('text')


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
