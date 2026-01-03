class_name SaveData
extends Resource

@export var file_index: String
@export var profile_name: String
@export var player_position: Vector2 = Vector2.INF

@export var achievements: Dictionary[String, bool]
@export var collectables: Dictionary[String, bool]
@export var stats: Stats

func _init(save_dict: Dictionary, _file_index: String) -> void:
	file_index = _file_index
	profile_name = save_dict.get("profile_name")

	achievements = {}
	if save_dict.has("achievements"):
		achievements.assign(save_dict.get("achievements"))

	collectables = {}
	if save_dict.has("collectables"):
		collectables.assign(save_dict.get("collectables"))

	stats = Stats.new()
	if save_dict.has("stats"):
		stats.load_from_dict(save_dict.get("stats"))


	if save_dict.has("player_position_x") and save_dict.has("player_position_y"):
		player_position.x = save_dict.get("player_position_x")
		player_position.y = save_dict.get("player_position_y")

func to_dictionary() -> Dictionary:

	var dict_to_save: Dictionary = {
		"profile_name": profile_name,
		"achievements": AchievementManager.to_saved_achievements(),
		"collectables": CollectablesManager.to_saved_collectables(),
		"stats": StatsManager.stats.to_dictionary()
	}

	if player_position != Vector2.INF:
		dict_to_save["player_position_x"] = player_position.x
		dict_to_save["player_position_y"] = player_position.y
	
	return dict_to_save
	
