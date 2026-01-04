extends Control
# TODO: test, improve this script, filters are pretty shit right now
@onready var item_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/FiltersVBoxContainer/HBoxContainer/ItemList

var item_text_to_unlock_type: Dictionary[String, Achievement.UnlockType] = {
	"Stats": Achievement.UnlockType.STAT_TARGET,
	"Collectables": Achievement.UnlockType.COLLECTABLE_TARGET,
	"Achievement amount": Achievement.UnlockType.ACHIEVEMENT_TARGET
}

func _input(event: InputEvent) -> void:
	# Only handle escape action pressed
	if !event.is_action_pressed("escape"):
		return
	
	if !visible:
		return

	get_viewport().set_input_as_handled()
	hide()
	get_tree().paused = false

func _on_back_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_item_list_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	
	# If no items are selected, show all
	if item_list.get_selected_items().size() == 0:
		for key: Achievement.UnlockType in AchievementManager.unlock_type_filter.keys():
			AchievementManager.unlock_type_filter[key] = true
		AchievementManager.filters_changed.emit()
		return
	
	for index: int in range(item_list.item_count):
		var item_text := item_list.get_item_text(index)
		var unlock_type := item_text_to_unlock_type[item_text]
		var is_selected := item_list.is_selected(index)
		AchievementManager.unlock_type_filter[unlock_type] = is_selected

	AchievementManager.filters_changed.emit()

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			AchievementManager.is_unlocked_filter = AchievementManager.IS_UNLOCKED_FILTER.ALL
		1:
			AchievementManager.is_unlocked_filter = AchievementManager.IS_UNLOCKED_FILTER.TRUE
		2:
			AchievementManager.is_unlocked_filter = AchievementManager.IS_UNLOCKED_FILTER.FALSE

	AchievementManager.filters_changed.emit()
