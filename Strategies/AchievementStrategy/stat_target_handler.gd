class_name StatTargetHandler
extends AchievementHandler

func try_unlock_achievements(context: Dictionary) -> void:
	assert(context.has("target_name"))
	assert(context.has("new_value"))
	
	var stat_achievements_hash := AchievementManager.stat_achievements_hash
	var target_name: String = context.get("target_name")
	var new_value: Variant = context.get("new_value")

	if !stat_achievements_hash.has(target_name):
		return
	
	for achievement: Achievement in stat_achievements_hash[target_name].achievements:
		if achievement.unlocked:
			continue
		
		var can_unlock := check_can_unlock_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			AchievementManager.achievement_unlocked.emit(achievement)
		elif achievement.value_target > new_value:
			return
	
func check_can_unlock_achievement(achievement: Achievement) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != Achievement.UnlockType.STAT_TARGET:
		return false
	
	return StatsManager.stats[achievement.target_name] >= achievement.value_target

func get_progress_value(achievement: Achievement) -> float:
	return StatsManager.stats[achievement.target_name]
