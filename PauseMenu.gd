extends Control

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_Resume_pressed():
	$InteractSfx.play()

func _on_MainMenu_pressed():
	$InteractSfx.play()

func _on_QuitGame_pressed():
	$InteractSfx.play()

func _on_Resume_button_up():
	self.is_paused = false

func _on_MainMenu_button_up():
	self.is_paused = false
	get_tree().change_scene("res://Menu.tscn")

func _on_QuitGame_button_up():
	get_tree().quit()
