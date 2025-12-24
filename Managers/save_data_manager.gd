extends Node

var collectables: Dictionary

const SAVE_DATA_PATH = "user://save_data.json"

func save() -> void:
	var file := FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"collectables": collectables,
		"stats": StatsManager.stats
	}))

func load() -> void:
	if not FileAccess.file_exists(SAVE_DATA_PATH):
		print("No save file to load")
		return

	var file := FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
	var file_text := file.get_as_text()
	
	if (file_text.length() == 0):
		print("Save file contains empty string")
		return
	
	var data: Dictionary = JSON.parse_string(file_text)

	StatsManager.stats = data.get("stats", {})
	collectables = data.get("collectables", {})
	
	get_tree().reload_current_scene()
	
	AchievementManager.prepare_achievements()

func reset() -> void:
	if not FileAccess.file_exists(SAVE_DATA_PATH):
		return
	
	var file := FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
	file.store_string("")
