extends RigidBody3D

@export var speed: float = 35
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var vfx_explosion = preload("res://scenes/vfx_explosion.tscn")


func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ships"):
		var explosion = vfx_explosion.instantiate()
		add_child(explosion)
		explosion.global_position = global_position
		explosion.get_node("AnimationPlayer").play("Init")
		await explosion.get_node("AnimationPlayer").animation_finished
		queue_free()
