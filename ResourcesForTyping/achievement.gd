class_name Achievement
extends Resource

enum UnlockType {
	INVALID,
	STAT_TARGET,
	COLLECTABLE_TARGET,
	TRIGGERED
}

@export var title: String
@export var description: String
@export var unlock_type: UnlockType
@export var target_name: String
@export var value_target: float
# Not in the achievements.json, added at runtime
@export var unlocked: bool

func from_dictionary(data: Dictionary) -> Achievement:
	assert(is_valid_achievement_data(data), "Invalid data for achievement" + str(data))

	title = data.get("title")
	description = data.get("description")
	unlock_type = get_unlock_type_enum_from_string(data.get("unlock_type"))
	target_name = data.get("target_name")
	value_target = data.get("value_target")
	unlocked = data.get("unlocked", false)
	
	return self

static func is_valid_achievement_data(data: Dictionary) -> bool:
	if (
		!data.has("title") or
		!data.has("description") or
		!data.has("target_name") or
		!data.has("value_target") or
		!data.has("unlock_type") or
		get_unlock_type_enum_from_string(data.get("unlock_type")) == UnlockType.INVALID
	):
		return false
	
	return true

static func get_unlock_type_enum_from_string(unlock_type_string: String) -> UnlockType:
	match unlock_type_string:
		"value_target":
			return UnlockType.STAT_TARGET
		"collectable_target":
			return UnlockType.COLLECTABLE_TARGET
		"triggered":
			return UnlockType.TRIGGERED
		_:
			printerr("Invalid unlock type: ", unlock_type_string)
			return UnlockType.INVALID
