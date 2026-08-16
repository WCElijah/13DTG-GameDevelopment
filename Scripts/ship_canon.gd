extends Node3D

const CANON_BALL = preload("res://Scenes/canon_ball.tscn")
@onready var timer: Timer = $cooldownTimer

var canShoot = true
var horizontal_pivot_rot = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and canShoot and Global.fire_mode and Global.canMountShipBody == get_parent().get_parent():
		timer.start()
		canShoot = false
		
		var attack = CANON_BALL.instantiate()
		add_child(attack)
		attack.global_transform = $Model/HorizontalPivot/SpawnPoint.global_transform
	printraw("Local: ")
	print($Model/HorizontalPivot.rotation)
	printraw("Global: ")
	print($Model/HorizontalPivot.global_rotation)
	$Model/HorizontalPivot.rotation = horizontal_pivot_rot


func rotate_vertical(vector):
	var max_positive_z_rotation = 30.0
	var max_negative_z_rotation = -30.0
	var current_rotation = $Model/HorizontalPivot.rotation.z
	print(current_rotation)
	if current_rotation == 0.0 and vector > 0:
		horizontal_pivot_rot.z = 15.0
	elif current_rotation == 15.0 and vector > 0:
		horizontal_pivot_rot.z = 30.0
	elif current_rotation > max_positive_z_rotation and vector > 0:
		return


func _on_cooldown_timer_timeout() -> void:
	canShoot = true
