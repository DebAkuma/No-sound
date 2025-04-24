# SettingConfig.gd

extends Node

# Define a singleton dictionary to hold the game data settings
var game_data = {
	"display_mode": "windowed",
	"vsync_mode": "adaptive",
	"show_fps": true,
	"resolution": "1920x1080",
	"max_fps": 60,
	"bloom_on": false,
	"brightness": 1.0,
	"SDFGI": false,
	"ReflectionLight": true,
	"master_vol": 0,
	"music_vol": 0,
	"speech_vol": 0,
	"sfx_vol": 0,
	"mouse_sens": 1.0
}

# Keybinding data structure
var keybindings = {}

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	load_data()
	apply_settings()
	load_keybinding()

# Load settings from file if it exists, or apply defaults
func load_data():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		for key in game_data.keys():
			game_data[key] = config.get_value("Settings", key, game_data[key])
		keybindings = config.get_value("Keybindings", "actions", keybindings)
	else:
		print("Settings file not found; using default values.")
	return err == OK

# Save current settings to file
func save_data():
	var config = ConfigFile.new()
	for key in game_data.keys():
		config.set_value("Settings", key, game_data[key])
	config.set_value("Keybindings", "actions", keybindings)
	config.save(SETTINGS_PATH)

# Load keybindings from saved data or default if not available
func load_keybinding() -> Dictionary:
	load_data()  # Ensures the latest settings are loaded
	return keybindings

# Save a specific keybinding
func save_keybinding(action: String, event: InputEvent) -> void:
	keybindings[action] = event
	save_data()

func apply_settings():
	
	# DISPLAY APPLY
	match game_data.display_mode:
		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		"minimized":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED)
		"maximized":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
		
	var w = game_data.resolution.split("x")[0]
	var h = game_data.resolution.split("x")[1]
	DisplayServer.window_set_size(Vector2(float(w), float(h)))
	
	match game_data.vsync_mode:
		"disabled":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
		"adaptive":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ADAPTIVE)
		"enabled":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED)
	
	# GRAPHICS APPLY
	GlobalWorldEnvironment.environment.set_glow_enabled(game_data.bloom_on)
	GlobalWorldEnvironment.environment.adjustment_brightness = game_data.brightness
	GlobalWorldEnvironment.environment.set_sdfgi_enabled(game_data.SDFGI)
	if game_data.ReflectionLight:
		GlobalWorldEnvironment.environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	elif !game_data.ReflectionLight:
		GlobalWorldEnvironment.environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
			

	# SOUND APPLY
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),game_data.master_vol)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Speech"),game_data.speech_vol)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),game_data.music_vol)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),game_data.sfx_vol)

# Define default settings for reset purposes
var default_game_data = {
	"display_mode": "windowed",
	"vsync_mode": "adaptive",
	"show_fps": true,
	"resolution": "1920x1080",
	"max_fps": 60,
	"bloom_on": false,
	"brightness": 1.0,
	"SDFGI": false,
	"ReflectionLight": true,
	"master_vol": 0,
	"music_vol": 0,
	"speech_vol": 0,
	"sfx_vol": 0,
	"mouse_sens": 0.2
}

var default_keybindings = {
	"sprint": create_key_event(KEY_SHIFT),
	"interaction": create_key_event(KEY_F),
	"jump": create_key_event(KEY_SPACE),
	"crouch": create_key_event(KEY_CTRL)
}

# Helper function to create an InputEventKey with a specific keycode
func create_key_event(physical_keycode: int) -> InputEventKey:
	var event = InputEventKey.new()
	event.physical_keycode = physical_keycode
	return event

# Reset to default settings and save
func reset():
	game_data = default_game_data.duplicate()
	keybindings = default_keybindings.duplicate()
	save_data()
