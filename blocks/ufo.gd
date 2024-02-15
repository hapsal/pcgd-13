extends Block

var hover_active = false
const BLINKING_FPS = 2
var animation_clock = 0
var sprite:Sprite
var animation_clock_reset_time = (1.0 / 60.0) * BLINKING_FPS

# Called when the node enters the scene tree for the first time.
func _ready():
	print(animation_clock_reset_time)
	sprite = $Sprite

func _process(delta):
	if not hover_active:
		if get_colliding_blocks():
			mode = 3
			hover_active = true
	else:
		animation_clock += delta
		if animation_clock >= animation_clock_reset_time:
			animation_clock = 0
			sprite.frame = 1 if $Sprite.frame == 0 else 0 
