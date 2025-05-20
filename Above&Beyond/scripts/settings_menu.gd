extends Control

@onready var graphics_settings :GridContainer = %GraphicsSettings
@onready var controller_settings: VBoxContainer = %ControllerSettings
@onready var volume_settings: GridContainer = %VolumeSettings
@onready var fullscreen: CheckBox = %GraphicsSettings/fullscreen
@onready var settings_menu: Control = $Control/MarginContainer/SettingsMenu
@onready var music_tab: Button = $MarginContainer/SettingsMenu/Tabs/MUSIC

@onready var main_vol_slider: HSlider = %VolumeSettings/MainVolSlider
@onready var sfx_vol_slider: HSlider = %VolumeSettings/SFXVolSlider
@onready var music_vol_slider: HSlider = %VolumeSettings/MusicVolSlider

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

@onready var default_button: Button = $CommonOptions/default
@onready var back_button: Button = $CommonOptions/back

signal back_or_quit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		fullscreen.button_pressed = true
	else:
		fullscreen.button_pressed = false
	main_vol_slider.value  = db_to_linear(AudioServer.get_bus_volume_db(MASTER_BUS_ID))
	main_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(MUSIC_BUS_ID))
	sfx_vol_slider.value   = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))
	music_tab.grab_focus()

func _on_music_settings_pressed() -> void:
	volume_settings.visible     = true
	controller_settings.visible = false
	graphics_settings.visible   = false


func _on_controlls_settings_pressed() -> void:
	volume_settings.visible     = false
	controller_settings.visible = true
	graphics_settings.visible   = false
	print(graphics_settings.visible)


func _on_graphics_settings_pressed() -> void:
	volume_settings.visible     = false
	controller_settings.visible = false
	graphics_settings.visible   = true


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_vsync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_back_pressed() -> void:
	volume_settings.visible     = true
	controller_settings.visible = false
	graphics_settings.visible   = false
	hide()
	back_or_quit.emit()

func _on_default_pressed() -> void:
	pass # Replace with function body.
	
	
func _on_sfx_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)

func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)

func _on_main_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_visibility_changed() -> void:
	if music_tab and visible:
		music_tab.grab_focus()


func _on_input_type_button_item_selected(index: int) -> void:
	if index != -1:
		Util.INPUT_SCHEME = index
