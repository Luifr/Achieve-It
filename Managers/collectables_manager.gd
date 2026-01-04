extends Node

var all_collectables: Array[Collectable] = [] 
var collectables: Dictionary[String, Collectable] = {}
var collectables_per_type: Dictionary[String, CollectablesArray]

signal collectables_set
signal collectable_collected(collectable_id: String, collectable_type: String)

func reset_data() -> void:
	all_collectables = []
	collectables = {}
	collectables_per_type = {}

func collect_collectable(collectable_id: String) -> void:
	collectables[collectable_id].is_collected = true
	collectable_collected.emit(collectable_id, collectables[collectable_id].type)

func init_collectables() -> void:
	reset_data()

	var collectable_nodes := get_tree().get_nodes_in_group("collectable")
	
	for collectable_node: Node in collectable_nodes:
		if !collectable_node.get("collectable_id") or !collectable_node.get("collectable_type"):
			push_error("Collectable node missing id or type ", str(collectable_node))
			return

		var collectable_id: String = collectable_node.collectable_id
		var collectable_type: String = collectable_node.collectable_type

		var collectable := Collectable.new(collectable_id, collectable_type, SaveDataManager.loaded_data.collectables.get(collectable_id, false))

		collectables.set(collectable_id, collectable)
		all_collectables.append(collectable)
		(collectables_per_type.get_or_add(collectable.type, CollectablesArray.new()) as CollectablesArray).collectables.append(collectable)
	
	collectables_set.emit()

func to_saved_collectables() -> Dictionary[String, bool]:
	return all_collectables.reduce(
			func(acc: Dictionary[String, bool], collectable: Collectable) -> Dictionary[String, bool]:
				acc[collectable.id] = collectable.is_collected
				return acc,
		{} as Dictionary[String, bool]
	)

func get_amount_of_collected_collectables_by_type(type: String) -> int:
	if !collectables_per_type.has(type):
		return 0

	return collectables_per_type[type].collectables.filter(
		func (collectable: Collectable) -> bool: return collectable.is_collected
	).size()
