extends Node3D


@export var flag_texture: Texture2D
@export var sail_logos: Node3D  


func _ready() -> void:
	if flag_texture:
		set_flag(flag_texture)


func set_flag(texture: Texture2D):
	# we need to override the material cuz otherwise it would share its textures across mltiple ships
	var material = $Flag.get_active_material(0).duplicate()
	material.set_shader_parameter("flag_texture", texture)
	$Flag.material_override = material

	if sail_logos:
		for logo in sail_logos.get_children():
			logo.texture = texture
