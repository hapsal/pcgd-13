extends Sprite

var previous_position

func _process(_delta):
	offset.y += sin(Time.get_ticks_msec()*0.005)*0.1
	position.y = lerp(position.y, 0, 0.1)
