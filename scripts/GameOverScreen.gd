extends Control


func _on_Replay_button_up():
	emit_signal("replay_pressed")
	get_tree().reload_current_scene()

func _on_Quit_button_up():
	get_tree().quit()

func _on_Main_Menu_button_up():
	get_tree().paused = false
	get_tree().change_scene("res://Menu.tscn")

func set_height(value):
	$Panel/HeightLabel.text = "Height: " + str(value)
	
func set_highest_height(value):
	$Panel/HighHeightLabel.text = "Hi-Height: " + str(value)

func _on_Main_Menu_pressed():
	get_tree().paused = false
	$InteractSfx.play()

func _on_Quit_pressed():
	$InteractSfx.play()

func _on_Replay_pressed():
	get_tree().paused = false
	$InteractSfx.play()
