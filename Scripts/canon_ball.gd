extends RigidBody3D

@export var speed: float = 35
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta


func cleanup():
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ships"):
		cleanup()
