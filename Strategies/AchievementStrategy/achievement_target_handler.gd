class_name AchievementTargetHandler
extends AchievementHandler

func try_unlock_achievements(_context: Dictionary) -> void:
	var achievement_achievements_array := AchievementManager.achievement_achievements_array
	
	for achievement: Achievement in achievement_achievements_array.achievements:
		if achievement.unlocked:
			continue

		var can_unlock := check_can_unlock_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			AchievementManager.achievement_unlocked.emit(achievement)
	
func check_can_unlock_achievement(achievement: Achievement) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != Achievement.UnlockType.ACHIEVEMENT_TARGET:
		return false

	return AchievementManager.get_amount_of_unlocked_achievements() >= achievement.value_target

func get_progress_value(_achievement: Achievement) -> float:
	return AchievementManager.get_amount_of_unlocked_achievements()
