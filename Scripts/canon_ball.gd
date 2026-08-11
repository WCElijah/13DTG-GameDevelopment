extends RigidBody3D

@export var explosion_strength := 50.0
@export var speed := 25.0
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
