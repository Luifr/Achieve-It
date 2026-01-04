class_name Stats
extends Resource

enum StatType {
	DEATH,
	JUMP,
	DOUBLE_JUMP,
	DISTANCE_WALKED
}

@export var death: int = 0
@export var jump: int = 0
@export var distance_walked: float = 0
@export var double_jump: int = 0

func to_dictionary() -> Dictionary:
	return {
		"death": death,
		"jump": jump,
		"distance_walked": distance_walked,
		"double_jump": double_jump
	}

func load_from_dict(data: Dictionary) -> void:
	death = data.get("death", 0)
	jump = data.get("jump", 0)
	distance_walked = data.get("distance_walked", 0.0)
	double_jump = data.get("jump", 0)

static func get_stat_string_from_enum(enum_type: StatType) -> String:
	var stat_string: String = ""

	if enum_type == StatType.DEATH:
		stat_string = "death"
	elif enum_type == StatType.JUMP:
		stat_string = "jump"
	elif enum_type == StatType.DISTANCE_WALKED:
		stat_string = "distance_walked"
	elif enum_type == StatType.DOUBLE_JUMP:
		stat_string = "double_jump"

	assert(stat_string.length() > 0, "Invalid StatType: %s" % enum_type)

	return stat_string
