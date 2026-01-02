extends Node

@export var tile_maps: Node

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

	for child in tile_maps.get_children():
		child.show()
