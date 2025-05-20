extends Control


@onready var settings_menu: Control = $SettingsMenu


func _on_show_settings() -> void:
	print("SHOW SETTINGS")
	settings_menu.visible = true
	
	
func _on_hide_settings() -> void:
	print("HIDE SETTINGS")
	settings_menu.visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_child(0).visible = !get_child(0).visible
		get_child(0).find_child("back").text = "QUIT"
		Engine.time_scale = 0.0 if get_child(0).visible else 1.0
		


func _on_settings_menu_back_or_quit() -> void:
	get_tree().quit()
