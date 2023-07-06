extends Sprite2D

class_name Mushroom


# Signals emitted after animation is complete

signal state_changed(_mushroom: Mushroom, is_spore: bool)

const SPORE_SCALE = Vector2(0.3, 0.3)
const GROWN_SCALE = Vector2(1, 1)

@export var ID = 0
var _is_spore := true:
	set(value): 
		_is_spore = value
		emit_signal("state_changed", self, value)


func _ready():
	SwingLazily()


func IsSpore():
	return _is_spore
	

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


func GetCell() -> Cell:
	return get_parent().get_parent().get_parent()


func Sprout():
	_is_spore = true
	scale = Vector2()
	$AP.play("sprout")


func Unsprout():
	$AP.play_backwards("sprout")
	_is_spore = true
	await $AP.animation_finished
	get_parent().remove_child(self)
	queue_free()


func Grow():
	_is_spore = false
	$AP.play("grow")
	

func Ungrow():
	_is_spore = true
	$AP.play_backwards("grow")


func Pop():
	$AP.play("pop")
	await $AP.animation_finished
	get_parent().remove_child(self)
	queue_free()


func Unpop():
	_is_spore = false
	$AP.play_backwards("pop")
