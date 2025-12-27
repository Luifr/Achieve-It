extends Node

var all_achievements: Array[Achievement] = []

# TODO: create a Dictionary for triggered achievements
var stat_achievements_hash: Dictionary[String, AchievementsArray]
var collectable_achievements_hash: Dictionary[String, AchievementsArray]

const ACHIEVEMENTS_FILE_PATH = "res://Data/achievements.json"

signal achievement_unlocked(achievement: Achievement)

# Called when the node enters the scene tree for the first time.
func ready() -> void:
	if !StatsManager.stat_changed.is_connected(try_unlock_stat_target_achievements):
		StatsManager.stat_changed.connect(try_unlock_stat_target_achievements)

	if !CollectablesManager.collectable_collected.is_connected(try_unlock_collectable_target_achievements):
		CollectablesManager.collectable_collected.connect(try_unlock_collectable_target_achievements)

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
		if !(entry_variant is Dictionary) or !Achievement.is_valid_achievement_data(entry_variant):
			push_error("Invalid data at index " + str(index) + ", while parsing achievements JSON")
			continue

		var entry := Achievement.new().from_dictionary(entry_variant)

		all_achievements.append(entry)

		if entry.unlock_type == Achievement.UnlockType.STAT_TARGET:
			if check_stat_target_achievement(entry):
				entry.unlocked = true
			
			var target_name: String = entry.target_name
			if !stat_achievements_hash.has(target_name):
				stat_achievements_hash.set(target_name, AchievementsArray.new())
			stat_achievements_hash[target_name].achievements.append(entry)
		elif entry.unlock_type == Achievement.UnlockType.COLLECTABLE_TARGET:
			if check_collectable_target_achievement(entry):
				entry.unlocked = true

			var collectable_type: String = entry.target_name
			if !collectable_achievements_hash.has(collectable_type):
				collectable_achievements_hash.set(collectable_type, AchievementsArray.new())
			collectable_achievements_hash[collectable_type].achievements.append(entry)

	for key: String in stat_achievements_hash.keys():
		stat_achievements_hash[key].achievements.sort_custom(
			AchievementsArray.sort_target_ascending
		)

func is_achievement_unlocked(achievement: Achievement) -> bool:
	return achievement.unlocked

func check_stat_target_achievement(achievement: Achievement) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != Achievement.UnlockType.STAT_TARGET:
		return false
	
	return StatsManager.stats[achievement.target_name] >= achievement.value_target

func check_collectable_target_achievement(achievement: Achievement) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != Achievement.UnlockType.COLLECTABLE_TARGET:
		return false

	if !CollectablesManager.collectables_per_type.has(achievement.target_name):
		return false
	
	return CollectablesManager.collectables_per_type[achievement.target_name].collectables.filter(
		func(collectable: Collectable) -> bool: return collectable.is_collected
	).size() >= achievement.value_target

func try_unlock_stat_target_achievements(target_name: String, new_value: Variant) -> void:
	if !stat_achievements_hash.has(target_name):
		return
	
	for achievement: Achievement in stat_achievements_hash[target_name].achievements:
		if achievement.unlocked:
			continue
		
		var can_unlock := check_stat_target_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			achievement_unlocked.emit(achievement)
		elif achievement.value_target > new_value:
			return

func try_unlock_collectable_target_achievements(_collectable_id: String, collectable_type: String) -> void:
	if !collectable_achievements_hash.has(collectable_type):
		return
	
	for achievement: Achievement in collectable_achievements_hash[collectable_type].achievements:
		if achievement.unlocked:
			continue
		
		var can_unlock := check_collectable_target_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			achievement_unlocked.emit(achievement)
