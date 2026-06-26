extends Node3D

@export var water_tile : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_water() # Replace with function body.

func generate_water():
	var length = 10
	var width = 10
	# 1st quadrant
	for x in range(length):
		for z in range(width):
			var new_tile = water_tile.instantiate()
			add_child(new_tile)
			new_tile.position = Vector3(x,0,z)
			print(Vector3(x,0,z))
