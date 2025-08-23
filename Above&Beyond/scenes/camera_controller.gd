# In your Camera2D script
extends Camera2D

func _ready():
	# Enable pixel snapping
	# position_smoothing_enabled = true
	# position_smoothing_speed = 5.0  # Adjust as needed
	return

func _process(_delta):
	# Round the camera position to nearest pixel
	#global_position = Vector2( round(global_position.x), round(global_position.y) )
	return
