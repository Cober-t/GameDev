extends Camera2D

var actual_cam_pos: Vector2

@onready var player: CharacterBody2D = $".."
@export var shader: Shader

func _process(delta: float) -> void:
	actual_cam_pos = actual_cam_pos.lerp(player.global_position, delta * 3)
	
	# Distance between nearest pixel perfect position and the camera´s current position
	var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	get_parent().get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	
	global_position = actual_cam_pos.round()
	
