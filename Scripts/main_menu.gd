extends Control

@export var choose_your_save: Panel
@export var quit_game_alert: Control
@export var settings: Control
@export var credits: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(RenderingServer.get_default_clear_color())
	SaveDataManager.loaded_data = null
	choose_your_save.hide()
	quit_game_alert.hide()
	credits.hide()

func _input(event: InputEvent) -> void:
	if !event.is_action_pressed("escape"):
		return

	# Close topmost modal by checking visibility
	if settings.visible:
		settings.hide()
		get_viewport().set_input_as_handled()
	elif quit_game_alert.visible:
		quit_game_alert.hide()
		get_viewport().set_input_as_handled()
	elif choose_your_save.visible:
		choose_your_save.hide()
		get_viewport().set_input_as_handled()
	elif credits.visible:
		credits.hide()
		get_viewport().set_input_as_handled()

func _on_play_button_pressed() -> void:
	choose_your_save.show()

func _on_settings_button_pressed() -> void:
	settings.show()

func _on_quit_button_pressed() -> void:
	quit_game_alert.show()

func _on_credits_button_pressed() -> void:
	credits.show()
