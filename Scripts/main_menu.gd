extends Control

@export var choose_your_save: Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveDataManager.loaded_data = null
	choose_your_save.hide()

func _on_play_button_pressed() -> void:
	choose_your_save.show()

func _on_settings_button_pressed() -> void:
	var SETTINGS := load("uid://8l31r3a0bup0")
	get_tree().change_scene_to_packed(SETTINGS)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
