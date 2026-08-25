extends Node3D

const CANON_BALL = preload("res://Scenes/canon_ball.tscn")
@onready var timer: Timer = $cooldownTimer

var canShoot = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and canShoot and Global.fire_mode and Global.canMountShipBody == get_parent().get_parent():
		shoot_canon()


func rotate_vertical(vector):
	var rotational_inc := deg_to_rad(5.0)
	var max_rotation := deg_to_rad(30.0)
	
	var target_rotation = $Model/HorizontalPivot.rotation.z + (rotational_inc * vector)
	$Model/HorizontalPivot.rotation.z = clamp(target_rotation, -max_rotation, max_rotation)


func rotate_horizontal(vector):
	# rotating left is a positive vector and right is negative
	var rotational_inc := deg_to_rad(5.0)
	var target_rotation  = $Model.rotation.y + (rotational_inc * vector)
	$Model.rotation.y = clamp(target_rotation, deg_to_rad(60), deg_to_rad(120))


func _on_cooldown_timer_timeout() -> void:
	canShoot = true


func shoot_canon():
	if canShoot:
		timer.start()
		canShoot = false
			
		var attack = CANON_BALL.instantiate()
		add_child(attack)
		attack.global_transform = $Model/HorizontalPivot/SpawnPoint.global_transform
