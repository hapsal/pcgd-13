extends Node2D

var tower
var height_level = 1
func _ready():
	tower = get_parent().get_node("Tower")
	
func _process(delta):
	if tower.height > 400 * height_level:
		height_level += 1
		update()
		print(height_level)
	
func draw_checkpoint_line(y: float) -> void:
	var line_width = 800
	var line_height = 2
	var line_position = Vector2(-400, -y)
	draw_rect(Rect2(line_position, Vector2(line_width, line_height)), Color.green)

# Override _draw method to handle drawing
func _draw() -> void:
	# Draw a line at the initial position
	draw_checkpoint_line(290*height_level)
	
