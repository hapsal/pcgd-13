extends Node2D
onready var menu = $Menu
onready var settings = $Settings
export var mainGameScene : PackedScene

func _on_PlayButton_pressed():
	$InteractSfx.play()

func _on_SettingsButton_pressed():
	$InteractSfx.play()

func _on_QuitButton_pressed():
	$InteractSfx.play()

func _on_ExitButton_pressed():
	$InteractSfx.play()

func _on_PlayButton_button_up():
	get_tree().change_scene(mainGameScene.resource_path)

func _on_SettingsButton_button_up():
	show_and_hide(settings, menu)

func _on_QuitButton_button_up():
	get_tree().quit()

func show_and_hide(first, second):
	first.show()
	second.hide()

func _on_ExitButton_button_up():
	show_and_hide(menu, settings)

func _on_Master_value_changed(value: float) -> void:
	volume(0, value)

func volume(bus_index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)
