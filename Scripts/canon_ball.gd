extends RigidBody3D

@export var explosion_strength := 5000.0
@export var speed := 10.0
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


#func _ready() -> void:
	#apply_impulse(global_basis * Vector3.FORWARD * explosion_strength)

#func _process(delta: float) -> void:
	#position += global_basis * Vector3.FORWARD * speed * delta


func cleanup():
	queue_free()
