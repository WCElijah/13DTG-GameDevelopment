extends Node3D

const CANON_BALL = preload("res://Scenes/canon_ball.tscn")
@onready var timer: Timer = $cooldownTimer

var canShoot = true

func _physics_process(delta: float) -> void:
	# handle cooldown
	
	if Input.is_action_just_pressed("left_click") and canShoot:
		timer.start()
		canShoot = false
		var attack = CANON_BALL.instantiate()
		add_child(attack)
		attack.global_transform = $SpawnPoint.global_transform


func _on_cooldown_timer_timeout() -> void:
	canShoot = true
