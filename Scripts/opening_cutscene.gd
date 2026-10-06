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


func say(line):
	dialogue_label.text = line
	dialogue_panel.visible = true


func hide_dialogue():
	dialogue_panel.visible = false
