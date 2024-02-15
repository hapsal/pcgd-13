extends Control


func _on_Replay_pressed():
	emit_signal("replay_pressed")
	get_tree().reload_current_scene()	

func set_height(value):
	$Panel/HeightLabel.text = "Height: " + str(value)
	
func set_highest_height(value):
	$Panel/HighHeightLabel.text = "Hi-Height: " + str(value)
