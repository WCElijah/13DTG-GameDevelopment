extends Node3D

const water_tile = preload("res://Trialing/water_plane.tscn")

func _ready() -> void:
	#generate_water()
	pass

func _physics_process(delta: float) -> void:
	pass


func generate_water():
	var length_count = 100
	var width_count = 100
	for x in range(length_count):
		for z in range(width_count):
			var new_water = water_tile.instantiate()
			$WaterTiles.add_child(new_water)
			new_water.position = Vector3(x, 0, z)
	
