extends Control

@onready var settings_menu: Control = $SettingsMenu

func _ready() -> void:
	get_child(0).find_child("back").text = "QUIT"
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("ui_select"):
		get_child(0).visible = !get_child(0).visible
		Engine.time_scale = 0.0
	if Input.is_action_just_pressed("ui_cancel"):
		settings_menu.hide()
		Engine.time_scale = 1.0

func _on_settings_menu_back_or_quit() -> void:
	get_tree().quit()
