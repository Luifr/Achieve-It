class_name AchievementContainer
extends PanelContainer

var achievement: Achievement

const LOCKED_ACHIEVEMENT = preload("uid://b8be7fyqxs7ev")
const CHECK_MARK = preload("uid://cmh2sjfbnammm")

@onready var icon: TextureRect = $AchievementContainer/Icon
@onready var title: Label = $AchievementContainer/VBoxContainer/Title
@onready var description: Label = $AchievementContainer/VBoxContainer/Description
@onready var progress_bar: ProgressBar = $AchievementContainer/VBoxContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !achievement:
		printerr("Achievement container missing achievement reference")
		return

	StatsManager.stat_changed.connect(update_stat_target_progres)
	CollectablesManager.collectable_collected.connect(update_collectable_target_progres)
	
	title.text = achievement.title
	description.text = achievement.description
	
	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT

	if achievement.unlock_type == Achievement.UnlockType.STAT_TARGET:
		progress_bar.max_value = achievement.value_target
		progress_bar.value = StatsManager.stats[achievement.target_name]
	
	if achievement.unlock_type == Achievement.UnlockType.COLLECTABLE_TARGET:
		progress_bar.max_value = achievement.value_target
		if CollectablesManager.collectables_per_type.has(achievement.target_name):
			progress_bar.value = CollectablesManager.collectables_per_type[achievement.target_name].collectables.filter(
				func(collectable: Collectable) -> bool: return collectable.is_collected
			).size()
		else:
			progress_bar.value = 0

func update_stat_target_progres(target_name: String, new_value: Variant) -> void:
	if target_name != achievement.target_name:
		return
		
	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT
	
	if achievement.unlock_type == Achievement.UnlockType.STAT_TARGET:
		progress_bar.max_value = achievement.value_target
		progress_bar.value = new_value

func update_collectable_target_progres(_collectable_id: String, collectable_type: String) -> void:
	if collectable_type != achievement.target_name:
		return

	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT

	if achievement.unlock_type == Achievement.UnlockType.COLLECTABLE_TARGET:
		progress_bar.max_value = achievement.value_target
		progress_bar.value = CollectablesManager.collectables_per_type[achievement.target_name].collectables.filter(
			func(collectable: Collectable) -> bool: return collectable.is_collected
		).size()
	else:
		progress_bar.value = 0
