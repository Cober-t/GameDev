extends Control

@onready var settings_menu: Control = $SettingsMenu

func _ready() -> void:
	settings_menu.find_child("back").text = "QUIT"
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_select"):
		settings_menu.visible = !settings_menu.visible
		Engine.time_scale = int(!settings_menu.visible)

func _on_settings_menu_back_or_quit() -> void:
	get_tree().quit()
