extends Node3D

const CANON_BALL = preload("res://Scenes/canon_ball.tscn")
@onready var timer: Timer = $cooldownTimer

var canShoot = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and canShoot and Global.fire_mode and Global.canMountShipBody == get_parent().get_parent():
		timer.start()
		canShoot = false
		
		var attack = CANON_BALL.instantiate()
		add_child(attack)
		attack.global_transform = $SpawnPoint.global_transform


func rotate_vertical(direction):
	var rotational_inc = 5.0
	var max_positive_z_rotation := 20.0
	var max_negative_z_rotation := -20.0
	var current_rotation = $Model/HorizontalPivot.rotation.z
	if direction != 0 and current_rotation != max_positive_z_rotation and current_rotation != max_negative_z_rotation:
		$Model/HorizontalPivot.rotation.z += rotational_inc
		

func _on_cooldown_timer_timeout() -> void:
	canShoot = true
