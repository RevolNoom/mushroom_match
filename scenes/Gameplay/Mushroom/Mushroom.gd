extends Sprite2D

class_name Mushroom

@export var ID = 0
var _grown = true


func _ready():
	SwingLazily()


func SwingLazily():
	$AnimationPlayer.stop()
	aperiodically_swing()


func aperiodically_swing():
	$Timer.wait_time = 3+15*randf()
	$Timer.start()
	

func _on_timer_timeout():
	$AnimationPlayer.play("swing_lazily")
	
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "swing_lazily":
		aperiodically_swing()


func BoingBoingOnChosen():
	$AnimationPlayer.play("boing_boing")







