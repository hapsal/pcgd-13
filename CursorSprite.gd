extends Sprite

func _process(delta):
	transform.origin.y += sin(Time.get_ticks_msec()*0.005)*0.1
