extends Control

@export var achievements_v_box: VBoxContainer

const ACHIEVEMENT_CONTAINER = preload("uid://cmcd1prtawpik")

@export var achievements_completed_info: Label
@export var current_profile_label: Label
@export var coins_collected_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_profile_label.text = SaveDataManager.loaded_data.profile_name

	add_achievements_to_list()

	CollectablesManager.collectables_set.connect(
		func() -> void:
			coins_collected_label.text = str(CollectablesManager.get_amount_of_collected_collectables_by_type("coin"))
	)

	update_achievements_stats()
	AchievementManager.filters_changed.connect(add_achievements_to_list)
	AchievementManager.achievement_unlocked.connect(update_achievements_stats.unbind(1))
	CollectablesManager.collectable_collected.connect(update_coins_collected)

func add_achievements_to_list() -> void:
	for child: Node in achievements_v_box.get_children():
		child.queue_free()
	
	# For each achievement instantiate a achievement container and add a child
	for achievement in AchievementManager.all_achievements:
		if !AchievementManager.unlock_type_filter[achievement.unlock_type]:
			continue

		if AchievementManager.is_unlocked_filter == AchievementManager.IS_UNLOCKED_FILTER.TRUE and !achievement.unlocked:
			continue
		if AchievementManager.is_unlocked_filter == AchievementManager.IS_UNLOCKED_FILTER.FALSE and achievement.unlocked:
			continue
		
		var achievement_container: AchievementContainer = ACHIEVEMENT_CONTAINER.instantiate()
		achievement_container.achievement = achievement
		achievements_v_box.add_child(achievement_container)

func update_coins_collected(_collectable_id: String, collectable_type: String) -> void:
	if collectable_type != "coin":
		return
	coins_collected_label.text = str(CollectablesManager.get_amount_of_collected_collectables_by_type("coin"))

func update_achievements_stats() -> void:
	var completed := AchievementManager.get_amount_of_unlocked_achievements()
	var total := AchievementManager.all_achievements.size()
	var percent := int(float(completed) / total * 100)
	achievements_completed_info.text = str(completed) + "/" + str(total) + "  " + str(percent) + "%"

func _on_save_pressed() -> void:
	SaveDataManager.save_current_slot()

func _on_load_pressed() -> void:
	SaveDataManager.load_current_slot()

func _on_back_pressed() -> void:
	var MAIN_MENU_SCENE := load("uid://co5e4q0jguxgk")
	get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

func _on_achievement_filter_button_pressed() -> void:
	AchievementManager.open_achievements_filter.emit()
