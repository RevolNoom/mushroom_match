extends Sprite2D

class_name Mushroom

@export var ID = 0


# Signals emitted after animation is complete

signal sprouted(_self: Mushroom)
signal unsprouted(_self: Mushroom)

signal grown(_self: Mushroom)
signal ungrown(_self: Mushroom)

signal popped(_self: Mushroom)
signal unpopped(_self: Mushroom)

const SPORE_SCALE = Vector2(0.3, 0.3)
const GROWN_SCALE = Vector2(1, 1)


func _ready():
	SwingLazily()


func IsSpore():
	return is_in_group("spore")
	

func SwingLazily():
	$AP.stop()
	aperiodically_swing()


func aperiodically_swing():
	$Timer.wait_time = 3+15*randf()
	$Timer.start()
	

func _on_timer_timeout():
	# Something else is playing.
	# Probably "grow" or "boing boing"
	# Wait until it's done
	if $AP.is_playing():
		aperiodically_swing()
	else:
		$AP.play("swing_lazily")
	
	
func _on_animation_player_animation_finished(_anim_name):
	aperiodically_swing()


func BoingBoing():
	$AP.play("boing_boing")


func GetCell():
	return get_parent()


func Sprout():
	$AP.play("sprout")
	await $AP.animation_finished
	add_to_group("spore")
	emit_signal("sprouted", self)


func Unsprout():
	$AP.play_backwards("sprout")
	await $AP.animation_finished
	add_to_group("spore")
	emit_signal("unsprout", self)


func Grow():
	$AP.play("grow")
	await $AP.animation_finished
	remove_from_group("spore")
	emit_signal("grown", self)


func Ungrow():
	$AP.play_backwards("grow")
	await $AP.animation_finished
	add_to_group("spore")
	emit_signal("ungrown", self)


func Pop():
	$AP.play("pop")
	await $AP.animation_finished
	emit_signal("popped", self)
	

func Unpop():
	$AP.play_backwards("pop")
	await $AP.animation_finished
	remove_from_group("spore")
	emit_signal("unpopped", self)
