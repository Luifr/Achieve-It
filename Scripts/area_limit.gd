extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
	if !body is Player:
		return

	(body as Player).on_area_entered(collision_shape_2d)


func _on_body_exited(body: Node2D) -> void:
	if !body is Player:
		return

	(body as Player).on_area_exited(collision_shape_2d)
