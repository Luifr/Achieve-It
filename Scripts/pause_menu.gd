extends Control

@export var quit_game_alert: Control
@export var settings: Control
@export var stats_panel: Control

func _ready() -> void:
	quit_game_alert.hide()
	settings.hide()
	stats_panel.hide()

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
	elif stats_panel.visible:
		stats_panel.hide()
		get_viewport().set_input_as_handled()
	elif visible:
		# Close pause menu itself if no modals are open
		hide()
		get_tree().paused = false
		get_viewport().set_input_as_handled()

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_settings_button_pressed() -> void:
	settings.show()

func _on_quit_button_pressed() -> void:
	quit_game_alert.show()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	var MAIN_MENU_SCENE := load("uid://co5e4q0jguxgk")
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

func _on_stats_button_pressed() -> void:
	stats_panel.update_stats_modal()
	stats_panel.show()
