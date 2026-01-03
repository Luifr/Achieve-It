extends Node

const ACHIEVEMENT_UNLOCKED_TOAST = preload("uid://c2letqrlfob0r")

@export var pause_menu: Control
@export var achievement_unlocked_v_box: VBoxContainer
@export var achievement_unlocked_audio_stream_player: AudioStreamPlayer

func _ready() -> void:
	pause_menu.hide()

	AchievementManager.achievement_unlocked.connect(handle_achievement_unlocked)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		pause_menu.show()

func handle_achievement_unlocked(achievement: Achievement) -> void:
	achievement_unlocked_audio_stream_player.play()
	create_achievement_unlocked_toast(achievement)

func create_achievement_unlocked_toast(achievement: Achievement) -> void:
	var toast := ACHIEVEMENT_UNLOCKED_TOAST.instantiate()
	toast.achievement = achievement
	achievement_unlocked_v_box.add_child(toast)
	await get_tree().create_timer(4).timeout
	toast.queue_free()
