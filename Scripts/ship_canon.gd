extends Node3D

const CANON_BALL = preload("res://Scenes/canon_ball.tscn")
@onready var timer: Timer = $cooldownTimer


func _physics_process(delta: float) -> void:
	if timer.is_stopped() and Input.is_action_pressed("left_click"):
		timer.start(0.1)
		var attack = CANON_BALL.instantiate()
		add_child(attack)
		attack.global_transform = $SpawnPoint.global_transform
