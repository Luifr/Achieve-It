extends Control

@export var quit_game_alert: Control
@export var settings: Control

# TODO: handle esc to close the topmost modal
func _ready() -> void:
	quit_game_alert.hide()
	settings.hide()

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_settings_button_pressed() -> void:
	settings.show()

func _on_quit_button_pressed() -> void:
	quit_game_alert.show()
