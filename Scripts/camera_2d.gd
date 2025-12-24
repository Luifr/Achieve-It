class_name GameCamera2D
extends Camera2D

func update_bounds(collision_shape_2d: CollisionShape2D) -> void:
	var collision_rect: Rect2 = collision_shape_2d.shape.get_rect()

	# Convert local rect corners to global space
	var top_left: Vector2 = collision_shape_2d.global_transform * collision_rect.position
	var bottom_right: Vector2 = collision_shape_2d.global_transform * collision_rect.end
	
	limit_left = int(top_left.x)
	limit_right = int(bottom_right.x)
	limit_top = int(top_left.y)
	limit_bottom = int(bottom_right.y)
