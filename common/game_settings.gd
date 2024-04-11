extends Node


const FILE_PATH := "user://config.cfg"


var master_volume := 0.5 :
	set(value):
		master_volume = value
		_set_bus_volume(_audio_bus_master, master_volume)

var music_volume := 1.0 :
	set(value):
		music_volume = value
		_set_bus_volume(_audio_bus_music, music_volume)

var sfx_volume := 1.0 :
	set(value):
		sfx_volume = value
		_set_bus_volume(_audio_bus_sfx, sfx_volume)

var fullscreen := false :
	set(value):
		if fullscreen != value:
			fullscreen = value
			var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
			DisplayServer.window_set_mode(mode)


var _audio_bus_master := _get_audio_bus(&"Master")
var _audio_bus_music := _get_audio_bus(&"Music")
var _audio_bus_sfx := _get_audio_bus(&"SFX")


func _enter_tree() -> void:
	_read_from_disk()


func _exit_tree() -> void:
	_save_to_disk()


func _read_from_disk() -> void:
	var config := ConfigFile.new()
	config.load(FILE_PATH)

	master_volume = config.get_value("audio", "master_volume", master_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)

	fullscreen = config.get_value("video", "fullscreen", fullscreen)


func _save_to_disk() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.set_value("video", "fullscreen", fullscreen)

	config.save(FILE_PATH)


func _set_bus_volume(bus : int, volume : float) -> void:
	if bus >= 0:
		var clamped := clampf(volume, 0.0, 1.0)
		AudioServer.set_bus_volume_db(bus, linear_to_db(clamped))
		AudioServer.set_bus_mute(bus, is_zero_approx(clamped))


func _get_audio_bus(bus_name : StringName) -> int:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		push_error("Audio bus does not exist: %s" % bus_name)
	return index
