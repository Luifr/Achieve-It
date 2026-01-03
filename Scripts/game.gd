extends Node

const ACHIEVEMENT_UNLOCKED_TOAST = preload("uid://c2letqrlfob0r")

@export var pause_menu: Control
@export var achievement_unlocked_v_box: VBoxContainer

func _ready() -> void:
	pause_menu.hide()
	
	AchievementManager.achievement_unlocked.connect(create_achievement_unlocked_toast)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		pause_menu.show()

func create_achievement_unlocked_toast(achievement: Achievement) -> void:
	var toast := ACHIEVEMENT_UNLOCKED_TOAST.instantiate()
	toast.achievement = achievement
	achievement_unlocked_v_box.add_child(toast)
	await get_tree().create_timer(4).timeout
	toast.queue_free()
