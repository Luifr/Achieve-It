extends Control

var achievement: Achievement

const LOCKED_ACHIEVEMENT = preload("uid://b8be7fyqxs7ev")
const CHECK_MARK = preload("uid://cmh2sjfbnammm")

@export var icon: TextureRect
@export var achievement_title: Label

func _ready() -> void:
	if !achievement:
		printerr("Achievement container missing achievement reference")
		return

	achievement_title.text = achievement.title
	
	icon.texture = CHECK_MARK if achievement.unlocked else LOCKED_ACHIEVEMENT
