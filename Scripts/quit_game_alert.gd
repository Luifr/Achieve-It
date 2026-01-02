extends Control
func _ready() -> void:
	hide()

func _on_confirm_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_cancel_button_pressed() -> void:
	hide()
