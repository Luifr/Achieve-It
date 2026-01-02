extends Control

@export var choose_your_save: Panel
@export var quit_game_alert: Control
@export var settings: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(RenderingServer.get_default_clear_color())
	SaveDataManager.loaded_data = null
	choose_your_save.hide()
	quit_game_alert.hide()

func _on_play_button_pressed() -> void:
	choose_your_save.show()

func _on_settings_button_pressed() -> void:
	settings.show()

func _on_quit_button_pressed() -> void:
	quit_game_alert.show()
