extends VBoxContainer


var clock_start


# Called when the node enters the scene tree for the first time.
func _ready():
	clock_start = Time.get_ticks_msec()


func _process(_delta):
	$Value.text = FormatTime(Time.get_ticks_msec()-clock_start)
	#print("Format time: " + FormatTime(Time.get_ticks_msec()-clock_start))


func FormatTime(time_msec) -> String:
	var values = [	time_msec/1000/60/60/24 / 7,# Week
					time_msec/1000/60/60/24 % 7,# Day
					time_msec/1000/60/60 % 24,# Hour
					time_msec/1000/60 % 60, # Minute
					time_msec/1000 % 60]	#Second
					
	return 	("" if values[0] == 0 else (str(values[0]) + "w ")) +\
			("" if values[1] == 0 else (str(values[1]) + "d ")) +\
			("0" if values[2] < 10 else "") + str(values[2]) + ":" +\
			("0" if values[3] < 10 else "") + str(values[3]) + ":" +\
			("0" if values[4] < 10 else "") + str(values[4])
			
