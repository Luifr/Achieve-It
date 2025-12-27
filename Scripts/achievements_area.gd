extends Control

@export var achievements_v_box: VBoxContainer

const ACHIEVEMENT_CONTAINER = preload("uid://cmcd1prtawpik")

@export var achievements_completed_info: Label
@export var current_profile_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_profile_label.text = SaveDataManager.loaded_data.profile_name
	
	# For each achievement instantiate a achievement container and add a child
	for achievement in AchievementManager.all_achievements:
		var achievement_container: AchievementContainer = ACHIEVEMENT_CONTAINER.instantiate()
		achievement_container.achievement = achievement
		achievements_v_box.add_child(achievement_container)

	update_achievements_stats()
	AchievementManager.achievement_unlocked.connect(update_achievements_stats.unbind(1))

func update_achievements_stats() -> void:
	var completed := AchievementManager.all_achievements.filter(AchievementManager.is_achievement_unlocked).size()
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
