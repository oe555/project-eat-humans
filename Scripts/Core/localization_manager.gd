extends Node

const LOCALIZATION_PATH = "res://Assets/Localization/localization.csv"

# Structure: { "locale_code": { "string_key": "translated_string" } }
var translations: Dictionary = {}
var current_locale: String = "en"

func _ready() -> void:
	load_translations()
	
	# Load the locale from the ConfigurationManager autoload
	var saved_locale = ConfigurationManager.get_setting("Settings", "Language", "en")
	# Check if the translation actually exists or default to English
	if translations.has(saved_locale):
		current_locale = saved_locale
		TranslationServer.set_locale(saved_locale)
	else:
		current_locale = "en"
		TranslationServer.set_locale("en")

func load_translations() -> void:
	if not FileAccess.file_exists(LOCALIZATION_PATH):
		push_warning("Localization CSV not found at: " + LOCALIZATION_PATH)
		return
		
	var file = FileAccess.open(LOCALIZATION_PATH, FileAccess.READ)
	if not file:
		return
		
	var headers = file.get_csv_line()
	var locales = []
	
	# Assuming format: key, en, es, fr...
	for i in range(1, headers.size()):
		var loc = headers[i].strip_edges()
		locales.append(loc)
		if not translations.has(loc):
			translations[loc] = {}
			
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 2 or line[0].is_empty():
			continue
			
		var key = line[0].strip_edges()
		for i in range(1, line.size()):
			if i - 1 < locales.size():
				var loc = locales[i - 1]
				translations[loc][key] = line[i].strip_edges()
				
	file.close()

func set_locale(locale: String) -> void:
	if translations.has(locale):
		current_locale = locale
		TranslationServer.set_locale(locale)
		
		# Save to configuration
		ConfigurationManager.set_setting("Settings", "Language", locale)
	else:
		push_warning("Locale not available: " + locale)

func get_text(key: String) -> String:
	if translations.has(current_locale) and translations[current_locale].has(key):
		return translations[current_locale][key]
	return key
