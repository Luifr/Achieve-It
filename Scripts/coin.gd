extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var collectable_id: String

func _ready() -> void:
	if !collectable_id:
		printerr("Coin does not have collectable id: " + get_path().get_concatenated_names())
		return

	if SaveDataManager.collectables.has(collectable_id):
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body is Player:
		return

	StatsManager.increment_stat("coin")
	hide()
	SaveDataManager.collectables.set(collectable_id, true)
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	queue_free()
