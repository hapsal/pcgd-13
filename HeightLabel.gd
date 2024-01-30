extends Label

export(int, 0, 3) var significant_figures = 2
export(float) var height_scale = 0.01
export(String) var text_format = "Tower Height: %sm"

func update_height(var height:float) -> void:
	text = text_format % str(stepify(((height)*height_scale), pow(0.1, significant_figures)))

func _ready():
	pass
