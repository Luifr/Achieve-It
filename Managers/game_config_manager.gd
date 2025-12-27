extends Node

const SAVE_CONFIG_PATH = "user://settings.cfg"

func _ready() -> void:
	load_config()

func set_default_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("Video", "resolution", Vector2i(1280, 720))
	config.set_value("Video", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)

	config.set_value("Audio", "volume", 0.5)

	config.save(SAVE_CONFIG_PATH)

func load_config() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_CONFIG_PATH)
	
	# No save config save, set default settings
	if err == ERR_FILE_NOT_FOUND:
		set_default_settings()

	elif err != OK:
		push_error("Problem when loading config file for saving, error code: %d" % err)
		return

	DisplayServer.window_set_size(config.get_value("Video", "resolution"))
	DisplayServer.window_set_mode(config.get_value("Video", "window_mode"))
	
	var volume: float = config.get_value("Audio", "volume")
	
	AudioServer.set_bus_volume_linear(0, volume)
	AudioServer.set_bus_mute(0, volume == 0)

func save_config(section: String, key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_CONFIG_PATH)
	
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_error("Problem when reading config file for saving, error code: %d" % err)
		return
	
	config.set_value(section, key, value)
	config.save(SAVE_CONFIG_PATH)
