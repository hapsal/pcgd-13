extends Node2D

export var mainGameScene : PackedScene

func _on_PlayButton_pressed():
	$InteractSfx.play()

func _on_SettingsButton_pressed():
	$InteractSfx.play()

func _on_QuitButton_pressed():
	$InteractSfx.play()

func _on_PlayButton_button_up():
	get_tree().change_scene(mainGameScene.resource_path)

func _on_QuitButton_button_up():
	get_tree().quit()
