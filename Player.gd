extends Area2D

export var speed = 400 # The players move speed
var screen_size 

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	var velocity = Vector2.ZERO # The players movement vector
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# With the code below we can check whether the player is moving or not
		#$AnimatedSprite2D.play()
	#else:
	#	$AnimatedSprite2D.stop()
	
	position += velocity * delta
