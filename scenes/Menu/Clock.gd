extends VBoxContainer


var time_elapsed: float


# Called when the node enters the scene tree for the first time.
func _ready():
	Reset()


func _process(delta):
	time_elapsed += delta
	$Value.text = FormatTime(floori(time_elapsed))


func Pause():
	set_process(false)


func Resume():
	set_process(true)


func Reset():
	time_elapsed = 0
	

func FormatTime(time_sec) -> String:
	var values = [	time_sec/60/60/24 / 7,# Week
					time_sec/60/60/24 % 7,# Day
					time_sec/60/60 % 24,# Hour
					time_sec/60 % 60, # Minute
					time_sec % 60]	#Second
					
	return 	("" if values[0] == 0 else (str(values[0]) + "w ")) +\
			("" if values[1] == 0 else (str(values[1]) + "d ")) +\
			("0" if values[2] < 10 else "") + str(values[2]) + ":" +\
			("0" if values[3] < 10 else "") + str(values[3]) + ":" +\
			("0" if values[4] < 10 else "") + str(values[4])


# Return "?w ?d hh:mm:ss" into a float, representing number of seconds
func ConvertFromString(time_string) -> float:
	var regex = RegEx.new()
	regex.compile("(\\d+w )?(\\d+d )?(\\d+):(\\d+):(\\d+)")
	var r = regex.search(time_string).strings
	return (int(r[1])*604800 if r[1] != "" else 0) +\
			(int(r[2])*86400 if r[2] != "" else 0) +\
			int(r[3])*3600 + int(r[4])*60 + int(r[5])
			
			
