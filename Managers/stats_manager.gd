extends Node

var stats: Dictionary = {}

signal stat_changed(stat_name: String, new_value: Variant)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func increment_stat(stat_name: String) -> void:
	if !stats.has(stat_name):
		stats.set(stat_name, 0)

	stats[stat_name] = stats[stat_name] + 1
	stat_changed.emit(stat_name, stats[stat_name])
