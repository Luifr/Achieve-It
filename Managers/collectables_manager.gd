extends Node

var all_collectables: Array[Collectable] = [] 
var collectables: Dictionary[String, Collectable] = {}
var collectables_per_type: Dictionary[String, CollectablesArray]

signal collectable_collected(collectable_id: String, collectable_type: String)

func reset_data() -> void:
	all_collectables = []
	collectables = {}
	collectables_per_type = {}

func collect_collectable(collectable_id: String) -> void:
	collectables[collectable_id].is_collected = true
	collectable_collected.emit(collectable_id, collectables[collectable_id].type)

func add_collectable(collectable_id: String, collectable_type: String) -> void:
	if collectables.has(collectable_id):
		return

	var collectable := Collectable.new(collectable_id, collectable_type)
	collectables.set(collectable_id, collectable)
	all_collectables.append(collectable)
	(collectables_per_type.get_or_add(collectable.type, CollectablesArray.new()) as CollectablesArray).collectables.append(collectable)

func set_collectables_from_dictionary(data: Array) -> void:
	collectables = {}
	all_collectables = []
	collectables_per_type = {}
	
	for entry: Variant in data:
		assert(entry is Dictionary)
		var dictionary_entry: Dictionary = entry
		var collectable := Collectable.from_dictionary(dictionary_entry)
		printt(str(dictionary_entry))
		# TODO: id cant change, but what if type or something else changes? then data from disk has to be updated
		# event better, only save id and is_unlocked on disk, everything else should come from the game
		collectables.set(entry.get("id", ""), collectable)
		all_collectables.append(collectable)
		(collectables_per_type.get_or_add(collectable.type, CollectablesArray.new()) as CollectablesArray).collectables.append(collectable)

func collectables_to_dictionary() -> Array[Dictionary]:
	var dictionary_array: Array[Dictionary] = []
	
	for collectable: Collectable in collectables.values():
		dictionary_array.append(collectable.to_dictionary())
	
	return dictionary_array
