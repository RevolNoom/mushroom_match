extends Sprite2D

class_name Mushroom

@export var ID = 0

const SPORE_SCALE = Vector2(0.3, 0.3)
const GROWN_SCALE = Vector2(1, 1)


signal anim_finished(_this: Mushroom, anim_name: String)


func _ready():
	SwingLazily()


func SwingLazily():
	$AnimationPlayer.stop()
	aperiodically_swing()


func aperiodically_swing():
	$Timer.wait_time = 3+15*randf()
	$Timer.start()
	

func _on_timer_timeout():
	# Something else is playing.
	# Probably "grow" or "boing boing"
	# Wait until it's done
	if $AnimationPlayer.is_playing():
		aperiodically_swing()
	else:

		$AnimationPlayer.play("swing_lazily")
	
	
func _on_animation_player_animation_finished(anim_name):
	#if ["swing_lazily", "grow"].has(anim_name):
	if anim_name != "boing_boing":
		aperiodically_swing()
	emit_signal("anim_finished", self, anim_name)


func BoingBoingOnChosen():
	$AnimationPlayer.play("boing_boing")


func PlayAnim(anim_name: String):
	$AnimationPlayer.play(anim_name)






