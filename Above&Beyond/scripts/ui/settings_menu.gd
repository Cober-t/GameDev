extends Control

@onready var graphics_settings :GridContainer = %GraphicsSettings
@onready var controller_settings: VBoxContainer = %ControllerSettings
@onready var inputs_container: GridContainer = %InputsContainer

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

@export var action_items: Array[String]

signal back_or_quit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_action_remap_items()

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
		change_action_remap_items()

func create_action_remap_items() -> void:
	var previous_item = controller_settings.get_child(0).get_child(-1)
	var inputs_count = Util.INPUT_SCHEME
	var start_range = (action_items.size() / Util.INPUT_SCHEMES.size()) * Util.INPUT_SCHEME
	var end_range = start_range + action_items.size() / Util.INPUT_SCHEMES.size()
	for index in range(start_range, end_range):
		var action = action_items[index]
		var label = Label.new()
		label.text = fix_action_text(action)
		inputs_container.add_child(label)
		
		var button = RemapButton.new()
		button.action = action
		button.focus_neighbor_top = previous_item.get_path()
		previous_item.focus_neighbor_bottom = button.get_path()
		#if index == action_items.size() - 1:
			#print(default_button)
			#default_button.focus_neighbor_top = button.get_path()
			#button.focus_neighbor_bottom = default_button.get_path()
		previous_item = button
		inputs_container.add_child(button)

func change_action_remap_items() -> void:
	var previous_item = controller_settings.get_child(0).get_child(-1)
	var inputs_count = Util.INPUT_SCHEME
	var index_action = (action_items.size() / Util.INPUT_SCHEMES.size()) * Util.INPUT_SCHEME
	
	var index = 2
	while index < controller_settings.get_child(0).get_children().size():
		var action = action_items[index_action]
		var action_text = fix_action_text(action)
		inputs_container.get_child(index).text = action_text
		index += 1
		inputs_container.get_child(index).action = action
		inputs_container.get_child(index).update_key_text()
		index += 1
		index_action += 1

func fix_action_text(action: String):
	return action.replace("_", " ").replace("joypad", "").replace("controller", "").replace("arrow", "").replace("keyboard","").capitalize()
