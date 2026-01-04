class_name SaveSlot
extends PanelContainer

@export var profile_name_label: Label
@export var achievement_stat_label: Label

var loaded_data: SaveData

const GAME = preload("uid://drlpxnsx3p7x0")

func _ready() -> void:
	profile_name_label.text = loaded_data.profile_name
	
	var unlocked_achievements := loaded_data.achievements.values().filter(func(is_unlocked: bool) -> bool: return is_unlocked).size()
	var total_achievements := loaded_data.achievements.size()
	
	if total_achievements > 0:
		achievement_stat_label.text = "%d/%d (%d%%) Achievements unlocked" % [
			unlocked_achievements,
			total_achievements,
			int(unlocked_achievements / float(total_achievements) * 100) 
		]

func _on_load_button_pressed() -> void:
	SaveDataManager.loaded_data = loaded_data
	SaveDataManager.load_current_slot(false)
	get_tree().change_scene_to_packed(GAME)

func _on_delete_button_pressed() -> void:
	SaveDataManager.remove_data_at_index(loaded_data.file_index)
	queue_free()
