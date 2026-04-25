extends Node

# NOTE: This file was largely AI generated

const SAVE_PATH = "user://save_data.json"

# This is the data that will be loaded from the save file and modified throughout the game
var data: Dictionary = {}

# This is the data that will be used if the save file is corrupted or doesn't exist (e.g. first time playing)
var default_data: Dictionary = {}

func _ready() -> void:
	load_data()

func get_value(key: String, default: Variant = null) -> Variant:
	if data.has(key):
		return data[key]
	return default

func set_value(key: String, value: Variant, auto_save: bool = false) -> void:
	data[key] = value
	if auto_save:
		save_data()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Save file not found, creating default data.")
		data = default_data.duplicate(true)
		save_data()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			if typeof(json.data) == TYPE_DICTIONARY:
				data = json.data
				# Merge with default data to ensure all keys exist (in case of updates)
				_merge_with_defaults(data, default_data)
				print("Data loaded successfully.")
				save_data()
			else:
				print("Save data root is not a dictionary. Overwriting with defaults.")
				data = default_data.duplicate(true)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
			data = default_data.duplicate(true)
	else:
		print("Failed to open save file.")
		data = default_data.duplicate(true)

func save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Data saved successfully.")
	else:
		print("Failed to save data.")

# Recursively merge loaded data with defaults to handle missing keys from older saves
func _merge_with_defaults(target: Dictionary, source: Dictionary) -> void:
	for key in source:
		if not target.has(key):
			target[key] = source[key]
		elif typeof(source[key]) == TYPE_DICTIONARY and typeof(target[key]) == TYPE_DICTIONARY:
			_merge_with_defaults(target[key], source[key])
