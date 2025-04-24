extends Control

# Display Setting
@onready var display_mode_option = %DisplayModeOption
@onready var vsync_option = %VsyncOption
@onready var show_fps_toggle = %ShowFpsOption
@onready var resolution_option = %ResolutionOption
@onready var max_fps_slider = %MaxFps
@onready var max_fps_label = %Max

# Graphics Setting
@onready var bloom_toggle = %BloomOption
@onready var brightness_slider = %Brightness
@onready var brightness_label = %Brightness_Label
@onready var sdfgi_option: CheckButton = %SDFGIOption
@onready var reflection_option: CheckButton = %ReflectionOption

# Sound Setting
@onready var sound_high: Button = %High
@onready var sound_mid: Button = %Mid
@onready var sound_low: Button = %Low
@onready var mute: Button = %Mute
@onready var master_v: HSlider = %MasterV
@onready var master_v_label: Label = %MasterV_Label
@onready var music_v: HSlider = %MusicV
@onready var music_v_label: Label = %MusicV_Label
@onready var speech_v: HSlider = %SpeechV
@onready var speech_v_label: Label = %SpeechV_Label
@onready var sfx: HSlider = %SFX
@onready var sfx_label: Label = %SFX_Label

# Control Setting
@onready var sensy_text = %seny
@onready var mouse_sensy_slider = %Mouse_Sensy
@onready var input_button_scene = preload("res://Scene/input_button.tscn")
@onready var actionlist = %ActionList

# Control data
var is_remapping_button = false
var action_to_remap = null
var remapping_button = null
var input_actions = {
	"sprint" : "SPRINT",
	"interaction" : "INTERACTION",
	"jump" : "JUMP",
	"crouch" : "CROUCH"
}

func _ready():
	update_ui()
	load_keybinding()
	create_action_list()

# Updates UI elements to match current settings
func update_ui() -> void:
	update_display_settings_ui()
	update_graphics_settings_ui()
	update_sound_settings_ui()
	update_control_settings_ui()

# Updates display settings UI elements
func update_display_settings_ui() -> void:
	update_option(SettingConfig.game_data.display_mode, display_mode_option)
	update_option(SettingConfig.game_data.vsync_mode, vsync_option)
	show_fps_toggle.button_pressed = SettingConfig.game_data.show_fps
	update_option(SettingConfig.game_data.resolution, resolution_option)
	max_fps_label.text = str(SettingConfig.game_data.max_fps)
	max_fps_slider.value = SettingConfig.game_data.max_fps

# Updates graphics settings UI elements
func update_graphics_settings_ui() -> void:
	bloom_toggle.button_pressed = SettingConfig.game_data.bloom_on
	brightness_slider.value = SettingConfig.game_data.brightness
	brightness_label.text = str(int(SettingConfig.game_data.brightness * 50)) + "%"
	sdfgi_option.button_pressed = SettingConfig.game_data.SDFGI
	reflection_option.button_pressed = SettingConfig.game_data.ReflectionLight

# Updates sound settings UI elements
func update_sound_settings_ui() -> void:
	master_v.value = SettingConfig.game_data.master_vol
	music_v.value = SettingConfig.game_data.music_vol
	speech_v.value = SettingConfig.game_data.speech_vol
	sfx.value = SettingConfig.game_data.sfx_vol

# Updates control settings UI elements
func update_control_settings_ui() -> void:
	mouse_sensy_slider.value = SettingConfig.game_data.mouse_sens
	sensy_text.text = str(SettingConfig.game_data.mouse_sens)

# Selects the appropriate item in an OptionButton based on a value
func update_option(value: String, control: OptionButton) -> void:
	for i in range(control.item_count):
		if value == control.get_item_text(i).to_lower():
			control.select(i)
			break

# Display Setting
func _on_display_mode_option_item_selected(index):
	SettingConfig.game_data.display_mode = display_mode_option.get_item_text(index).to_lower()
	var itemModes = [
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
		DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED,
		DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
	]
	DisplayServer.window_set_mode(itemModes[index])
	SettingConfig.save_data()

	

func _on_vsync_option_item_selected(index):
	SettingConfig.game_data.vsync_mode = vsync_option.get_item_text(index).to_lower()
	var itemModes = [
		DisplayServer.VSyncMode.VSYNC_DISABLED,
		DisplayServer.VSyncMode.VSYNC_ADAPTIVE,
		DisplayServer.VSyncMode.VSYNC_ENABLED
	]
	DisplayServer.window_set_vsync_mode(itemModes[index])
	SettingConfig.save_data()

func _on_resolution_option_item_selected(index):
	var w = resolution_option.get_item_text(index).split("x")[0]
	var h = resolution_option.get_item_text(index).split("x")[1]
	DisplayServer.window_set_size(Vector2(float(w), float(h)))
	
	SettingConfig.game_data.resolution = resolution_option.get_item_text(index).to_lower()
	SettingConfig.save_data()

func _on_max_fps_value_changed(value):
	if value==500:
		Engine.max_fps = 0
	else:
		Engine.max_fps = value
	update_fps_text()
	SettingConfig.game_data.max_fps = value
	SettingConfig.save_data()
	
func update_fps_text():
	if Engine.max_fps == 0:
		max_fps_label.text = "MAX"
	else:
		max_fps_label.text = str(Engine.max_fps)

func _on_show_fps_option_toggled(toggled_on):
	SettingConfig.game_data.show_fps = toggled_on
	SettingConfig.save_data()


# Grapchis Setting

func _on_bloom_option_toggled(toggled_on):
	GlobalWorldEnvironment.environment.set_glow_enabled(toggled_on)
	SettingConfig.game_data.bloom_on = toggled_on
	# Implement bloom enable/disable logic here
	SettingConfig.save_data()

func _on_brightness_value_changed(value):
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	update_brightness_text()
	SettingConfig.game_data.brightness = value
	SettingConfig.save_data()

func update_brightness_text():
	brightness_label.text = str(int(SettingConfig.game_data.brightness * 50)) + "%"
	
	
# Adjusts UI and settings for various GPU performance modes
func set_gpu_settings(sdfgi: bool, bloom: bool, reflection: bool) -> void:
	sdfgi_option.button_pressed = sdfgi
	bloom_toggle.button_pressed = bloom
	reflection_option.button_pressed = reflection

func _on_gpu_high_pressed() -> void:
	set_gpu_settings(true, true, true)

func _on_gpu_mid_pressed() -> void:
	set_gpu_settings(false, true, true)

func _on_gpu_low_pressed() -> void:
	set_gpu_settings(false, false, false)

func _on_sdfgi_option_toggled(toggled_on: bool) -> void:
	GlobalWorldEnvironment.environment.set_sdfgi_enabled(toggled_on)
	SettingConfig.game_data.SDFGI = toggled_on
	SettingConfig.save_data()

func _on_reflection_option_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GlobalWorldEnvironment.environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	elif !toggled_on:
		GlobalWorldEnvironment.environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	SettingConfig.game_data.ReflectionLight = toggled_on
	SettingConfig.save_data()


# Audio Setting

func _on_high_pressed() -> void:
	var value = 6
	master_v.value = value
	music_v.value = value
	speech_v.value = value
	sfx.value = value

func _on_mid_pressed() -> void:
	var value = -24.5
	master_v.value = value
	music_v.value = value
	speech_v.value = value
	sfx.value = value

func _on_low_pressed() -> void:
	var value = -42.8
	master_v.value = value
	music_v.value = value
	speech_v.value = value
	sfx.value = value

func _on_mute_pressed() -> void:
	var value = -55
	master_v.value = value
	music_v.value = value
	speech_v.value = value
	sfx.value = value
	
func _on_master_v_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
	update_master_v_text(value)
	SettingConfig.game_data.master_vol = value
	SettingConfig.save_data()

func update_master_v_text(value):
	master_v_label.text = str(int(((value+55)/ 61) * 100)) + "%"

func _on_music_v_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),value)
	SettingConfig.game_data.music_vol = value
	SettingConfig.save_data()
	update_music_v_text(value)
	
func update_music_v_text(value):
	music_v_label.text = str(int(((value+55)/ 61) * 100)) + "%"

func _on_speech_v_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Speech"),value)
	SettingConfig.game_data.speech_vol = value
	SettingConfig.save_data()
	update_speech_v_text(value)

func update_speech_v_text(value):
	speech_v_label.text = str(int(((value+55)/ 61) * 100)) + "%"
	
func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)
	SettingConfig.game_data.sfx_vol = value
	SettingConfig.save_data()
	update_Sfx_v_text(value)

func update_Sfx_v_text(value):
	sfx_label.text = str(int(((value+55)/ 61) * 100)) + "%"


# Creates list of action buttons for key remapping
func create_action_list() -> void:
	for item in actionlist.get_children():
		item.queue_free()

	for action in input_actions:
		var button = input_button_scene.instantiate()
		button.find_child("LabelAction").text = input_actions[action]
		var events = InputMap.action_get_events(action)
		button.find_child("LabelInput").text = events[0].as_text().trim_suffix(" (Physical)") if events.size() > 0 else ""
		actionlist.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

# Remaps a key binding for a given action
func _on_input_button_pressed(button, action: String) -> void:
	if !is_remapping_button:
		is_remapping_button = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press Key..."

func _input(event: InputEvent) -> void:
	if is_remapping_button and event is InputEventKey:
		InputMap.action_erase_events(action_to_remap)
		InputMap.action_add_event(action_to_remap, event)
		SettingConfig.save_keybinding(action_to_remap, event)
		update_action_list(remapping_button, event)
		is_remapping_button = false
		accept_event()

func update_action_list(button, event: InputEvent) -> void:
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

# Loads saved key bindings from SettingConfig
func load_keybinding() -> void:
	var keybindings = SettingConfig.load_keybinding()
	for action in keybindings:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])


func _on_reset_button_pressed() -> void:
	SettingConfig.reset()
	update_ui()  # Refresh UI elements to display default values
	load_keybinding()  # Reload keybindings


func _on_mouse_sensy_value_changed(value: float) -> void:
	update_sensy_text()
	SettingConfig.game_data.mouse_sens = value
	SettingConfig.save_data()

func update_sensy_text():
	sensy_text.text = str(SettingConfig.game_data.mouse_sens)
