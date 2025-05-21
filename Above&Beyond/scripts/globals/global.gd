extends Node


func moving_direction() -> float:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.get_axis("move_arrow_left", "move_arrow_right")
	else:
		return Input.get_axis("move_joypad_left", "move_joypad_right")
		
func is_jumping() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_just_pressed("jump_keyboard")
	else:
		return Input.is_action_just_pressed("jump_controller")
		
func is_jumping_released() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_just_released("jump_keyboard")
	else:
		return Input.is_action_just_released("jump_controller")
		
func is_running() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_pressed("run_keyboard")
	else:
		return Input.is_action_pressed("run_controller")
		
func is_dashing() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_just_pressed("dash_keyboard")
	else:
		return Input.is_action_just_pressed("dash_controller")

func is_moving_left() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_pressed("move_arrow_left")
	else:
		return Input.is_action_pressed("move_joypad_left")
				
func is_moving_right() -> bool:
	if Util.INPUT_SCHEME == Util.INPUT_SCHEMES.KEYBOARD_AND_MOUSE:
		return Input.is_action_pressed("move_arrow_right")
	else:
		return Input.is_action_pressed("move_joypad_right")
