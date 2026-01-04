class_name SpacedDescriptionText
extends Control

@export var left_label: Label
@export var right_label: Label

func init(left_text: String, right_text: String) -> void:
	left_label.text = left_text
	right_label.text = right_text
