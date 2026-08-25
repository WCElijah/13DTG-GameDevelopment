extends Sprite3D

signal no_hp_left

@export var max_hp : int = 100
@export var viewport_size = Vector2(208, 48)


func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp

	#var mesh
	#for child in get_parent().get_children():
		#if child is MeshInstance3D:
			#mesh = child
			#
	#var ship_size = mesh.mesh.get_aabb().size # https://forum.godotengine.org/t/how-to-get-the-dimensions-of-a-meshinstance3d/63409
	#print(ship_size)
	$SubViewport.size = viewport_size


func take_damage(damage: float):
	$SubViewport/Panel/ProgressBar.value -= damage
	
	if $SubViewport/Panel/ProgressBar.value <= 0.1:
		no_hp_left.emit()
