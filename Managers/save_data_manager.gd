extends Node

const SAVES_DIR = "user://saves/"
const SAVE_DATA_PATH = SAVES_DIR + "save_data_{0}.json"

var loaded_data: SaveData = null

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVES_DIR):
		var error_code := DirAccess.make_dir_absolute(SAVES_DIR)
		if error_code != Error.OK:
			# TODO: handle error?
			printerr("Failed to create saves folder, error code: ", + error_code)

func reset_local_save_data() -> void:
	CollectablesManager.reset_data()
	AchievementManager.reset_data()
	StatsManager.stats = Stats.new()
	
func get_str_index_from_file_name(file_name: String) -> String:
	return file_name.split("_")[2].split(".")[0]

func create_new_save(profile_name: String) -> void:
	var new_save_index := 0

	var dir := DirAccess.open(SAVES_DIR)
	for file_name in dir.get_files():
		if file_name.ends_with(".json"):
			# get the index from the file name
			var index := int(get_str_index_from_file_name(file_name))
			if index > new_save_index:
				new_save_index = index

	var save_index_string: String = str(new_save_index + 1)

	var achievements := AchievementManager.load_achievements_from_json()
	var achievement_unlocked_dict: Dictionary = achievements.reduce(
		func(acc: Dictionary, achievement: Variant) -> Dictionary:
			acc[achievement.id] = false
			return acc,
		{} as Dictionary
	)

	reset_local_save_data()
	
	var file := FileAccess.open(SAVE_DATA_PATH.format([save_index_string]), FileAccess.WRITE)

	loaded_data = SaveData.new({
		"profile_name": profile_name,
		"achievements": achievement_unlocked_dict
	}, save_index_string)

	file.store_string(JSON.stringify(loaded_data.to_dictionary()))

func load_all_saves() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	var dir := DirAccess.open(SAVES_DIR)
	for file_name in dir.get_files():
		if file_name.ends_with(".json"):
			var save_data_path: String = SAVES_DIR + file_name
			var file := FileAccess.open(save_data_path, FileAccess.READ)
			var file_text := file.get_as_text()

			if file_text.length() == 0:
				printerr("Empty save file dected, probably corrupt or error during save creation at path %s" % save_data_path)
				file.close()
				var result := DirAccess.remove_absolute(save_data_path)
				if result != OK:
					printerr("Failed to remove save file at path %s" % save_data_path)
				continue
			
			var parsed_text: Variant = JSON.parse_string(file_text)
			# TODO: if file creation failed, we could have a corrupt file, handle it
			assert(parsed_text != null, "Save data with filename %s is invalid" % file_name)
			var data: Dictionary = parsed_text
			data.set("file_index", SaveDataManager.get_str_index_from_file_name(file_name))
			saves.append(data)
	return saves

func save_current_slot() -> void:
	if loaded_data == null:
		push_error("No data loaded, cannot save data")
		return

	save_data_at_index(loaded_data.file_index)

func save_data_at_index(index: String) -> void:
	var file := FileAccess.open(SAVE_DATA_PATH.format([index]), FileAccess.WRITE)
	
	var player := get_tree().get_first_node_in_group("player")

	if player:
		loaded_data.player_position = player.position

	var dict_to_save := loaded_data.to_dictionary()
	
	file.store_string(JSON.stringify(dict_to_save))

func load_current_slot(reload_current_scene := true) -> void:
	if loaded_data == null:
		push_error("No data loaded, cannot reload data")
		return

	load_data_at_index(loaded_data.file_index, reload_current_scene)

func load_data_at_index(index: String, reload_current_scene := true) -> void:
	var save_data_path: String = SAVE_DATA_PATH.format([index])
	if not FileAccess.file_exists(save_data_path):
		printerr("No save file to load")
		return

	var file := FileAccess.open(save_data_path, FileAccess.READ)
	var file_text := file.get_as_text()
	
	if (file_text.length() == 0):
		printerr("Save file contains empty string")
		return
	
	var data: Dictionary = JSON.parse_string(file_text)

	loaded_data = SaveData.new(data, index)

	CollectablesManager.reset_data()
	StatsManager.stats.load_from_dict(data.get("stats", {}))
	AchievementManager.prepare_achievements()
	
	if reload_current_scene:
		get_tree().reload_current_scene()

func remove_data_at_index(index: String) -> void:
	var save_data_path: String = SAVE_DATA_PATH.format([index])
	if not FileAccess.file_exists(save_data_path):
		return
	
	var response := DirAccess.remove_absolute(save_data_path)
	if response != Error.OK:
		printerr("Fail to remove file")
