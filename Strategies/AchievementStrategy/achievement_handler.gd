class_name AchievementHandler
extends Resource

func try_unlock_achievements(_context: Dictionary) -> void:
	pass
	
func check_can_unlock_achievement(_achievement: Achievement) -> bool:
	return false

func get_progress_value(_achievement: Achievement) -> float:
	return 0.0
