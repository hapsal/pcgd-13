extends Label

var minutes
var seconds

func update_time(var timer_seconds) -> void:
	minutes = int(timer_seconds / 60)
	seconds = int(timer_seconds) % 60
	text = str(int(minutes)) + "." + str(seconds).pad_zeros(2)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

