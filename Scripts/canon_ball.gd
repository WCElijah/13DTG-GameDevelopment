extends RayCast3D

@export var speed := 50.0


func _process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	var collider = get_collider()
	if is_colliding():
		cleanup()
	

func cleanup():
	queue_free()	
