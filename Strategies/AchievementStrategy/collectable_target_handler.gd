class_name CollectableTargetHandler
extends AchievementHandler

func try_unlock_achievements(context: Dictionary) -> void:
	assert(context.has("collectable_type"))
	
	var collectable_achievements_hash := AchievementManager.collectable_achievements_hash
	var collectable_type: String = context.get("collectable_type")

	if !collectable_achievements_hash.has(collectable_type):
		return
	
	for achievement: Achievement in collectable_achievements_hash[collectable_type].achievements:
		if achievement.unlocked:
			continue
		
		var can_unlock := check_can_unlock_achievement(achievement)
		if can_unlock:
			achievement.unlocked = true
			AchievementManager.achievement_unlocked.emit(achievement)
	
func check_can_unlock_achievement(achievement: Achievement) -> bool:
	if achievement.unlocked:
		return achievement.unlocked
	
	if achievement.unlock_type != Achievement.UnlockType.COLLECTABLE_TARGET:
		return false

	if !CollectablesManager.collectables_per_type.has(achievement.target_name):
		return false
	
	return CollectablesManager.get_amount_of_collected_collectables_by_type(achievement.target_name) >= achievement.value_target

func get_progress_value(achievement: Achievement) -> float:
	if !CollectablesManager.collectables_per_type.has(achievement.target_name):
		return 0.0
	return CollectablesManager.get_amount_of_collected_collectables_by_type(achievement.target_name)
