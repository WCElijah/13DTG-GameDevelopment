extends Node3D

# pick whats inside the crate in the inspector
@export_enum("food", "water", "gunpowder", "cannonballs") var supply_type = "food"

const FOOD_ICON = preload("res://Assets/Textures/Crate Icons/food_icon.webp")
const WATER_ICON = preload("res://Assets/Textures/Crate Icons/water_icon.webp")
const GUNPOWDER_ICON = preload("res://Assets/Textures/Crate Icons/gunpowder_icon.webp")
const CANNONBALLS_ICON = preload("res://Assets/Textures/Crate Icons/cannonballs_icon.webp")

func _ready() -> void:
	# work out which icon goes with the supply
	var current_icon_texture = FOOD_ICON
	if supply_type == "water":
		current_icon_texture = WATER_ICON
	elif supply_type == "gunpowder":
		current_icon_texture = GUNPOWDER_ICON
	elif supply_type == "cannonballs":
		current_icon_texture = CANNONBALLS_ICON

	# put the icon on every side of the crate
	for icon in $Icons.get_children():
		icon.texture = current_icon_texture
