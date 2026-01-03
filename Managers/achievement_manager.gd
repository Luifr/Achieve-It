extends Node

var all_achievements: Array[Achievement] = []

# TODO: create a Dictionary for triggered achievements
var stat_achievements_hash: Dictionary[String, AchievementsArray]
var collectable_achievements_hash: Dictionary[String, AchievementsArray]
var achievement_achievements_array: AchievementsArray

const ACHIEVEMENTS_FILE_PATH = "res://Data/achievements.json"

var achievement_handlers: Dictionary[Achievement.UnlockType, AchievementHandler] = {
	Achievement.UnlockType.STAT_TARGET: StatTargetHandler.new(),
	Achievement.UnlockType.COLLECTABLE_TARGET: CollectableTargetHandler.new(),
	Achievement.UnlockType.ACHIEVEMENT_TARGET: AchievementTargetHandler.new()
} 

signal achievement_unlocked(achievement: Achievement)

func _ready() -> void:
	StatsManager.stat_changed.connect(func(target_name: String, new_value: Variant) -> void:
		achievement_handlers[Achievement.UnlockType.STAT_TARGET].try_unlock_achievements({
			"target_name": target_name,
			"new_value": new_value
		})
	)

	CollectablesManager.collectable_collected.connect(func(_collectable_id: String, collectable_type: String) -> void:
		achievement_handlers[Achievement.UnlockType.COLLECTABLE_TARGET].try_unlock_achievements({
			"collectable_type": collectable_type
		})
	)

	achievement_unlocked.connect(func(_achievement: Achievement) -> void:
		achievement_handlers[Achievement.UnlockType.ACHIEVEMENT_TARGET].try_unlock_achievements({})
	)

func reset_data() -> void:
	for achievement in all_achievements:
		achievement.unlocked = false

func prepare_achievements() -> void:
	all_achievements = []
	stat_achievements_hash = {}
	achievement_achievements_array = AchievementsArray.new()

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
		if !(entry_variant is Dictionary) or !Achievement.is_valid_achievement_data(entry_variant):
			push_error("Invalid data at index " + str(index) + ", while parsing achievements JSON")
			continue

		if entry_variant.has("disabled") and entry_variant.get("disabled") == true:
			continue

		var entry := Achievement.new().from_dictionary(entry_variant)

		all_achievements.append(entry)

		if SaveDataManager.loaded_data.achievements.get(entry.id, false):
			entry.unlocked = true

		if entry.unlock_type == Achievement.UnlockType.STAT_TARGET:
			
			var target_name: String = entry.target_name
			if !stat_achievements_hash.has(target_name):
				stat_achievements_hash.set(target_name, AchievementsArray.new())
			stat_achievements_hash[target_name].achievements.append(entry)
		elif entry.unlock_type == Achievement.UnlockType.COLLECTABLE_TARGET:
			var collectable_type: String = entry.target_name
			if !collectable_achievements_hash.has(collectable_type):
				collectable_achievements_hash.set(collectable_type, AchievementsArray.new())
			collectable_achievements_hash[collectable_type].achievements.append(entry)
		elif entry.unlock_type == Achievement.UnlockType.ACHIEVEMENT_TARGET:
			achievement_achievements_array.achievements.append(entry)

	for key: String in stat_achievements_hash.keys():
		stat_achievements_hash[key].achievements.sort_custom(
			AchievementsArray.sort_target_ascending
		)
	
	achievement_achievements_array.achievements.sort_custom(
		AchievementsArray.sort_target_ascending
	)

func is_achievement_unlocked(achievement: Achievement) -> bool:
	return achievement.unlocked

func get_amount_of_unlocked_achievements() -> int:
	return all_achievements.filter(is_achievement_unlocked).size()

func to_saved_achievements() -> Dictionary[String, bool]:
	return all_achievements.reduce(
		func(acc: Dictionary[String, bool], achievement: Achievement) -> Dictionary[String, bool]:
			acc[achievement.id] = achievement.unlocked
			return acc,
		{} as Dictionary[String, bool]
	)
