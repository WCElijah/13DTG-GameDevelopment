extends Node3D

var player : CharacterBody3D

func _ready() -> void:
	for child in get_children():
		if child is CharacterBody3D:
			player = child
