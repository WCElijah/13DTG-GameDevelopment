extends Node3D

var canon_ball = preload("res://Scenes/canon_ball.tscn")


func shoot():
	var new_canon_ball = canon_ball.instantiate()
	$CanonBalls.add_child(new_canon_ball)
	
