extends Block

var hover_active = false
const BLINKING_FREQUENCY = 0.2
var animation_clock = 0
var sprite:Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite

func _physics_process(delta):
	if not hover_active:
		if get_colliding_blocks():
			mode = 3
			hover_active = true
func _process(delta):
	if hover_active:
		animation_clock += delta
		if animation_clock >= BLINKING_FREQUENCY:
			animation_clock = 0
			sprite.frame = 1 if $Sprite.frame == 0 else 0 
		
