extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var collectable_id: String
const collectable_type: String = "coin"

func _ready() -> void:
	if !collectable_id:
		printerr("Coin does not have collectable id: " + get_path().get_concatenated_names())
		return

	if CollectablesManager.collectables.has(collectable_id):
		if CollectablesManager.collectables[collectable_id].is_collected:
			queue_free()
	else:
		CollectablesManager.add_collectable(collectable_id, collectable_type)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body is Player:
		return

	hide()
	CollectablesManager.collect_collectable(collectable_id)
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	queue_free()
