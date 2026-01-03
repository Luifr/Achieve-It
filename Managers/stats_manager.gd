extends Node

var stats: Stats = Stats.new()

signal stat_changed(target_name: String, new_value: Variant)

func increment_stat(stat_type: Stats.StatType) -> void:
	var target_name: String = Stats.get_stat_string_from_enum(stat_type)
	stats[target_name] += 1
	stat_changed.emit(target_name, stats[target_name])

func increment_stat_by(stat_type: Stats.StatType, amount: float) -> void:
	var target_name: String = Stats.get_stat_string_from_enum(stat_type)
	stats[target_name] += amount
	stat_changed.emit(target_name, stats[target_name])
