extends Node

var config_filepath = "user://player.cfg"
var configfile = ConfigFile.new()


func _enter_tree():
	if configfile.load(config_filepath) != OK:
		configfile.set_value("volume", "sfx", 0)
		configfile.set_value("volume", "sfx_enabled", true)
		configfile.set_value("volume", "music", 0)
		configfile.set_value("volume", "music_enabled", true)
		configfile.set_value("player", "highscore", 0)
		configfile.save(config_filepath)


func get_value(config_section: String, key_name: String) -> Variant:
	return configfile.get_value(config_section, key_name)
	
	
func set_value(config_section: String, key_name: String, value: Variant):
	#print("Setting " + config_section + " " + key_name + ": " + str(value))
	configfile.set_value(config_section, key_name, value)
	$ResaveTimer.start()


@export var sfx_enabled = true:
	set(enable):
		configfile.set_value("volume", "sfx_enabled", sfx_enabled)
		sfx_enabled = enable 


func SetSfxVolume(vol_db: float):
	configfile.set_value("volume", "sfx", vol_db)
	for sfx in $Sfx.get_children():
		sfx.volume_db = vol_db


func PlaySfx(sfx_name: String):
	if sfx_enabled:
		$Sfx.get_node(sfx_name).play()


func _on_resave_timer_timeout():
	configfile.save(config_filepath)
