extends Node

var sfx_dict: Dictionary = {
	"ui_click": "res://Assets/Audio/SFX/click.wav"
}

var music_dict: Dictionary = {
	"main_menu": "res://Assets/Audio/Music/main_theme.ogg"
}

var sfx_players: Array[AudioStreamPlayer] = []
var current_music_player: AudioStreamPlayer

func _ready() -> void:
	current_music_player = AudioStreamPlayer.new()
	current_music_player.bus = "Music"
	add_child(current_music_player)
	
	for i in range(8):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)

func play_sfx(sfx_name: String, pitch_variance: float = 0.0) -> void:
	if not sfx_dict.has(sfx_name) or sfx_dict[sfx_name] == null:
		push_warning("SFX not found: " + sfx_name)
		return
		
	var stream = sfx_dict[sfx_name]
	if typeof(stream) == TYPE_STRING:
		if ResourceLoader.exists(stream):
			stream = load(stream)
			sfx_dict[sfx_name] = stream # Cache it
		else:
			push_warning("SFX file not found: " + stream)
			return
			
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			if pitch_variance > 0.0:
				var rnd = RandomNumberGenerator.new()
				rnd.randomize()
				player.pitch_scale = 1.0 + rnd.randf_range(-pitch_variance, pitch_variance)
			else:
				player.pitch_scale = 1.0
			player.play()
			return
			
	# Fallback if all players are busy
	var temp_player = AudioStreamPlayer.new()
	temp_player.bus = "SFX"
	temp_player.stream = stream
	add_child(temp_player)
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)

func play_music(music_name: String) -> void:
	if not music_dict.has(music_name) or music_dict[music_name] == null:
		push_warning("Music not found: " + music_name)
		return
		
	var stream = music_dict[music_name]
	if typeof(stream) == TYPE_STRING:
		if ResourceLoader.exists(stream):
			stream = load(stream)
			music_dict[music_name] = stream # Cache it
		else:
			push_warning("Music file not found: " + stream)
			return
			
	if current_music_player.stream == stream and current_music_player.playing:
		return
		
	current_music_player.stream = stream
	current_music_player.play()

func stop_music() -> void:
	current_music_player.stop()
