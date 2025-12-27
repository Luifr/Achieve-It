class_name Collectable
extends Resource

@export var id: String
@export var is_collected: bool = false
@export var type: String

func _init(collectable_id: String, collectable_type: String, _is_collected: bool = false) -> void:
	self.id = collectable_id
	self.type = collectable_type
	self.is_collected = _is_collected

static func from_dictionary(data: Dictionary) -> Collectable:
	assert(is_valid_collectable_data(data), "Invalid data for collectable" + str(data))
	
	var collectable := Collectable.new(data.get("id"), data.get("type"), data.get("is_collected", false))
	
	return collectable

static func is_valid_collectable_data(data: Dictionary) -> bool:
	if !data.has("id") or !data.has("is_collected") or !data.has("type"):
		return false
	
	return true

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"is_collected": is_collected,
		"type": type
	}
