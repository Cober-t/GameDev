extends Button
class_name RemapButton

@export var action: String

func _init() -> void:
	toggle_mode = true
	theme_type_variation = "RemapButton"

func _ready() -> void:
	set_process_unhandled_input(false)
	update_key_text()
	
func _toggled(_toggled_on: bool) -> void:
	set_process_unhandled_input(button_pressed)
	if button_pressed:
		text = "... Await Input ..."
		release_focus()
	else:
		update_key_text()
		grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button_pressed = false

func update_key_text():
	text = "%s" % InputMap.action_get_events(action)[0].as_text().split(" (")[0]
