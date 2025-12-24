extends Node

var all_achievements: Array[Dictionary] = []

# TODO: create a Dicitonary for triggered achievements
# TODO: move completed achievements to another Dictionary as they dont have to be checked
# Dictionary[String, Array[Achievement]
var stat_achievements_hash: Dictionary[String, Array]

const ACHIEVEMENTS_FILE_PATH = "res://data/achievements.json"

signal achievement_unlocked(achievement: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StatsManager.stat_changed.connect(try_unlock_stat_target_achievements)
	prepare_achievements()

func prepare_achievements() -> void:
	all_achievements = []
	stat_achievements_hash = {}

	var json_data := load_achievements_from_json()
	process_achievements_json(json_data)

func load_achievements_from_json() -> Array:
	var json_as_text := FileAccess.get_file_as_string(ACHIEVEMENTS_FILE_PATH)
	var json_data: Variant = JSON.parse_string(json_as_text)

	if json_data:
		if json_data is Array:
			return json_data
		else:
			printerr("Achievements JSON file is malformed, top level is not array.")
	else:
		printerr("Failed to load or parse Achievements JSON file.")

	# Fallback
	return []

func process_achievements_json(json_data: Array) -> void:
	for index in range(json_data.size()):
		var entry_variant: Variant = json_data[index]
		if !entry_variant is Dictionary or !entry_variant.has("unlock_type"):
			print("Invalid data at index " + str(index) + ", while parsing achievements JSON")
			continue

		var entry: Dictionary = entry_variant
		
		var can_unlock := check_stat_target_achievement(entry)
		print(can_unlock)
		if can_unlock:
			entry.unlocked = true
		
		all_achievements.append(entry)
		
		if entry.unlock_type == "stat_target":
			
			var stat_name: String = entry["stat_name"]
			if !stat_achievements_hash.has(stat_name):
				stat_achievements_hash.set(stat_name, [])
			stat_achievements_hash[stat_name].append(entry)
	
	for key: String in stat_achievements_hash.keys():
		stat_achievements_hash[key].sort_custom(sort_target_ascending)

func sort_target_ascending(dictionaryA: Dictionary, dictionaryB: Dictionary) -> bool:
	if dictionaryA["stat_target"] < dictionaryB["stat_target"]:
		return true
	return false

func is_achievement_unlocked(achievement: Dictionary) -> bool:
	return achievement.unlocked

func check_stat_target_achievement(achievement: Dictionary) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != "stat_target":
		return false
	
	return StatsManager.stats.get(achievement.stat_name, 0) >= achievement.stat_target

func try_unlock_stat_target_achievements(stat_name: String, new_value: Variant) -> void:
	if !stat_achievements_hash.has(stat_name):
		return
	
	for achievement: Dictionary in stat_achievements_hash[stat_name]:
		if achievement.unlocked:
			continue
		
		var can_unlock := check_stat_target_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			achievement_unlocked.emit(achievement)
		elif achievement.stat_target > new_value:
			return
