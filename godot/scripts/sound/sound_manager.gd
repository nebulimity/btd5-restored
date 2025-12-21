extends Node

const CHANNELS: int = 32

const MUSIC = {
	"jazz": preload("res://assets/audio/music/jazz.ogg"),
	"main_theme": preload("res://assets/audio/music/main_theme.ogg"),
	"volcano": preload("res://assets/audio/music/volcano.ogg"),
	"dance": preload("res://assets/audio/music/dance.ogg"),
	"electron": preload("res://assets/audio/music/electron.ogg"),
	"rock": preload("res://assets/audio/music/rock.ogg"),
}

const SFX = {
	"select": preload("res://assets/audio/sfx/select.mp3"),
	"place": preload("res://assets/audio/sfx/place.mp3"),
	"pop_1": preload("res://assets/audio/sfx/pop_1.mp3"),
	"pop_2": preload("res://assets/audio/sfx/pop_2.mp3"),
	"pop_3": preload("res://assets/audio/sfx/pop_3.mp3"),
	"pop_4": preload("res://assets/audio/sfx/pop_4.mp3"),
	"metal_bloon_hit": preload("res://assets/audio/sfx/metal_bloon_hit.mp3"),
	"ceramic_bloon_hit": preload("res://assets/audio/sfx/ceramic_bloon_hit.mp3"),
	"frozen_bloon_hit": preload("res://assets/audio/sfx/frozen_bloon_hit.mp3"),
	"moab_damage_1": preload("res://assets/audio/sfx/moab_damage_1.mp3"),
	"moab_damage_2": preload("res://assets/audio/sfx/moab_damage_2.mp3"),
	"moab_damage_3": preload("res://assets/audio/sfx/moab_damage_3.mp3"),
	"moab_destroyed_short": preload("res://assets/audio/sfx/moab_destroyed_short.mp3"),
	"moab_destroyed_med": preload("res://assets/audio/sfx/moab_destroyed_med.mp3"),
	"moab_destroyed_big": preload("res://assets/audio/sfx/moab_destroyed_big.mp3"),
	"explosion_medium": preload("res://assets/audio/sfx/explosion_medium.mp3"),
}

var sfx_pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

var sfx_muted: bool = false
var music_muted: bool = false

func _ready() -> void:
	_init_music_player()
	_init_sfx_pool()

func _init_music_player() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

func _init_sfx_pool() -> void:
	for i in range(CHANNELS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_pool.append(player)

func play(sound_name: String, volume: float = 1.0) -> void:
	var stream = SFX[sound_name]
	var player = _get_available_player()
	
	if player:
		player.stream = stream
		player.volume_linear = volume
		player.play()

func play_music(music_name: String, volume: float = 1.0) -> void:
	music_player.volume_linear = volume
	if music_player.stream == MUSIC[music_name] and music_player.playing:
		return
		
	music_player.stream = MUSIC[music_name]
	music_player.play()

func mute_sfx(should_mute: bool) -> void:
	sfx_muted = should_mute
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus_index, should_mute)

func mute_music(should_mute: bool) -> void:
	music_muted = should_mute
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus_index, should_mute)

func _get_available_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	
	return null
