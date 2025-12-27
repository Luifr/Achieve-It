class_name SaveData
extends Resource

@export var file_index: String
@export var profile_name: String
@export var player_position: Vector2

func _init(_file_index: String, _profile_name: String, _player_position: Vector2 = Vector2.INF) -> void:
	file_index = _file_index
	profile_name = _profile_name

	player_position = _player_position

func to_dictionary() -> Dictionary:

	var dict_to_save: Dictionary = {
		"profile_name": profile_name,
		"collectables": CollectablesManager.collectables_to_dictionary(),
		"stats": StatsManager.stats.to_dictionary()
	}

	if player_position != Vector2.INF:
		dict_to_save["player_position_x"] = player_position.x
		dict_to_save["player_position_y"] = player_position.y
	
	return dict_to_save
	
