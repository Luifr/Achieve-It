extends Area2D

@export var coins_needed: int = 7
@export var door_1_text_label: Label
@export var map_tile_map_layer: TileMapLayer

var door_1_text := "Collect %d coins to open door!
Collected so far: %d"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door_1_text_label.hide()

	CollectablesManager.collectables_set.connect(
		func() -> void:
			if CollectablesManager.get_amount_of_collected_collectables_by_type("coin") >= coins_needed:
				destroy_door_1()
	)

func _on_body_entered(body: Node2D) -> void:
	if !(body is Player):
		return
	
	var coins_collected := CollectablesManager.get_amount_of_collected_collectables_by_type("coin")
	if coins_collected >= coins_needed:
		destroy_door_1()
	else:
		door_1_text_label.text = door_1_text % [coins_needed, coins_collected]
		door_1_text_label.show()
		await get_tree().create_timer(3).timeout
		door_1_text_label.hide()

func destroy_door_1() -> void:
	var door_tiles := get_tiles_with_custom_data(map_tile_map_layer, "identifier", "door1")
	for door_tile in door_tiles:
		map_tile_map_layer.erase_cell(door_tile)
	
func get_tiles_with_custom_data(
	tilemap_layer: TileMapLayer,
	key: String,
	value: String
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for cell in tilemap_layer.get_used_cells():
		var tile_data := tilemap_layer.get_cell_tile_data(cell)
		if tile_data == null:
			continue

		if tile_data.get_custom_data(key) == value:
			result.append(cell)

	return result	
