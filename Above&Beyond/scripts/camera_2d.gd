extends Camera2D

var actual_cam_pos: Vector2
@export var position_smoothing: float = 5.0
@export var position_y_offset: float = 5.0
@onready var player: CharacterBody2D = %Player

#func _physics_process(delta: float) -> void:
func _process(delta: float) -> void:
	if not player or player is not CharacterBody2D:
		return

	actual_cam_pos = actual_cam_pos.lerp(player.global_position, delta * position_smoothing)
	# Distance between nearest pixel perfect position and the camera´s current position
	var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	global_position = actual_cam_pos.round()
