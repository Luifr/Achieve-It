extends Control

const SPACED_DESCIPTION_TEXT = preload("uid://b1u07g6bp38eb")

@export var stats_v_box_container: VBoxContainer
@export var back_button: Button

func update_stats_modal() -> void:
	remove_all_stats_v_box_children()
	var stats_dictionary := StatsManager.stats.to_dictionary()

	for key: String in stats_dictionary.keys():
		var value: Variant = stats_dictionary[key]

		var stat_text := SPACED_DESCIPTION_TEXT.instantiate() as SpacedDescriptionText
		stat_text.init(key + ':', str(snapped(value, 0.01) if value is float else value))

		stats_v_box_container.add_child(stat_text)

func remove_all_stats_v_box_children() -> void:
	var children := stats_v_box_container.get_children()

	for child: Node in children:
		child.free()

func _on_back_button_pressed() -> void:
	hide()
