class_name SaveSlot
extends PanelContainer

@export var profile_name_label: Label

var loaded_data: SaveData

const GAME = preload("uid://drlpxnsx3p7x0")

func _ready() -> void:
	profile_name_label.text = loaded_data.profile_name

func _on_load_button_pressed() -> void:
	SaveDataManager.loaded_data = loaded_data
	SaveDataManager.load_current_slot(false)
	get_tree().change_scene_to_packed(GAME)

func _on_delete_button_pressed() -> void:
	SaveDataManager.remove_data_at_index(loaded_data.file_index)
	queue_free()
