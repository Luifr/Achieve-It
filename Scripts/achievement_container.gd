extends PanelContainer

var achievement: Dictionary

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

	StatsManager.stat_changed.connect(update_progress)
	
	title.text = achievement.title
	description.text = achievement.description
	
	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT

	if achievement.unlock_type == "stat_target":
		progress_bar.max_value = achievement.stat_target
		progress_bar.value = StatsManager.stats.get(achievement.stat_name, 0)

func update_progress(stat_name: String, new_value: Variant) -> void:
	if stat_name != achievement.stat_name:
		return
		
	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT
	
	if achievement.unlock_type == "stat_target":
		progress_bar.max_value = achievement.stat_target
		progress_bar.value = new_value
