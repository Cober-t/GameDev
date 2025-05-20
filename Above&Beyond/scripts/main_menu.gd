extends CanvasLayer

@export var level: PackedScene
@onready var margin_container: MarginContainer = $Control/MarginContainer
@onready var main_buttons: VBoxContainer = $Control/MarginContainer/MainButtons
@onready var credits_menu: VBoxContainer = $Control/MarginContainer/CreditsMenu
@onready var music_tab_settings: Button = $Control/MarginContainer/SettingsMenu/Tabs/MUSIC
@onready var title: Label = $Control/MarginContainer/Title
@onready var menu_root: MarginContainer = $Control/MarginContainer
@onready var settings_menu: Control = $Control/MarginContainer/SettingsMenu

var default_button :Button
var back_button :Button

func _ready() -> void:
	focus_button()

func focus_button() -> void:
	if main_buttons:
		var button: Button = main_buttons.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(level)

func _on_settings_pressed() -> void:
	settings_menu.visible = true


func _on_credits_pressed() -> void:
	title.visible = false
	main_buttons.visible = false
	credits_menu.visible = true
	credits_menu.get_node("back").grab_focus()


func _on_back_pressed() -> void:
	main_buttons.visible  = true
	if settings_menu.visible:
		settings_menu.visible = false
		main_buttons.get_node("settings").grab_focus()
	if credits_menu.visible:
		credits_menu.visible  = false
		main_buttons.get_node("credits").grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	focus_button()
