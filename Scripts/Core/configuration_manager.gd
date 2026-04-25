extends Node

# This is a Singleton (Autoload) script that handles saving and loading game settings.
# It uses Godot's ConfigFile class to read/write a .cfg file in the user data directory.

const CONFIG_PATH = "user://settings.cfg"

var config: ConfigFile

func _ready() -> void:
	config = ConfigFile.new()
	load_config()

func load_config() -> void:
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("No config file found or load failed. A new one will be created upon saving.")

func save_config() -> void:
	config.save(CONFIG_PATH)

func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	save_config()

func get_setting(section: String, key: String, default_val: Variant = null) -> Variant:
	return config.get_value(section, key, default_val)
