class_name AchievementsArray
extends Resource

@export var achievements: Array[Achievement] = []

static func sort_target_ascending(achievementA: Achievement, achievementB: Achievement) -> bool:
	if achievementA.value_target < achievementB.value_target:
		return true
	return false
