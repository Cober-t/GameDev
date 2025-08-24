extends Camera2D

var actual_cam_pos : Vector2
func _physics_process(delta: float) -> void:
	#actual_cam_pos = actual_cam_pos.lerp(%Player.global_position, delta * 5.0)
	#var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	#
	#if Refs.sub_viewport_container:
		#Refs.sub_viewport_container.material.set_shader_parameter("cam_offset", cam_subpixel_offset)
		#global_position = actual_cam_pos.round()
	return
	
