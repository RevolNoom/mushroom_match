extends Node


func _ready():
	#$Music.play()
	pass

var sfx_enabled = true
func EnableSfx(enable: bool):
	sfx_enabled = enable 


func SetSfxVolume(vol_db: float):
	for sfx in $Sfx.get_children():
		sfx.volume_db = vol_db


func PlaySfx(sfx_name: String):
	if sfx_enabled:
		$Sfx.get_node(sfx_name).play()
