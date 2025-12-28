extends CharacterBody2D
class_name Player

const CAMERA_2D = preload("uid://bt6eq5c6omec0")

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2d

@export var environment_tile_map_layer: TileMapLayer

const LETHAL_LAYER = 8

const SPEED: float = 200.0
const MAX_JUMP_VELOCITY: float = -400.0
const JUMP_VELOCITY_DIVISOR: float = 4.0

const CLIMB_SPEED = -200

const MAX_JUMP_DELAY_AFTER_NOT_ON_FLOOR: float = 0.08
var time_since_left_floor: float = 0.0

var is_jumping: bool = false
var jump_velocity_used: float = 0.0
var stoped_jumping: bool = false

var overlapping_areas: Array[CollisionShape2D] = []

var camera: GameCamera2D

var initial_position: Vector2

func reparent_camera() -> void:
	camera = get_tree().get_first_node_in_group("camera")

	if !camera:
		camera = CAMERA_2D.instantiate()
		add_child(camera)
	else:
		camera.reparent(self)
		camera.position = Vector2.ZERO

func _ready() -> void:
	call_deferred("reparent_camera")
	initial_position = position
	
	if SaveDataManager.loaded_data.player_position != Vector2.INF:
		position = SaveDataManager.loaded_data.player_position

func _physics_process(delta: float) -> void:
	var on_floor: bool = is_on_floor()
	
	# Add the gravity.
	if not on_floor:
		velocity += get_gravity() * delta
		time_since_left_floor += delta
	elif on_floor and time_since_left_floor > 0:
		time_since_left_floor = 0
		jump_velocity_used = 0.0
		stoped_jumping = false


	if Input.is_action_just_pressed("jump") and time_since_left_floor < MAX_JUMP_DELAY_AFTER_NOT_ON_FLOOR and !is_jumping:
		is_jumping = true
		StatsManager.increment_stat(Stats.StatType.JUMP)
		velocity.y = MAX_JUMP_VELOCITY/JUMP_VELOCITY_DIVISOR
		jump_velocity_used = MAX_JUMP_VELOCITY/JUMP_VELOCITY_DIVISOR
	elif on_floor and is_jumping:
		is_jumping = false
		jump_velocity_used = 0
	elif !on_floor and is_jumping and !stoped_jumping and Input.is_action_pressed("jump"):
		if jump_velocity_used > MAX_JUMP_VELOCITY:
			velocity.y += MAX_JUMP_VELOCITY/JUMP_VELOCITY_DIVISOR
			jump_velocity_used += MAX_JUMP_VELOCITY/JUMP_VELOCITY_DIVISOR
	elif is_jumping and !stoped_jumping and !Input.is_action_pressed("jump"):
		stoped_jumping = true

	if Input.is_action_pressed("move_up"):
		var tile := get_tile_under_player(environment_tile_map_layer)

		if tile and tile.get_custom_data("climbable"):
			velocity.y = CLIMB_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true

	move_and_slide()

	check_letal_tiles()

func on_area_entered(area_collision_shape_2d: CollisionShape2D) -> void:
	overlapping_areas.append(area_collision_shape_2d)
	camera.update_bounds(area_collision_shape_2d)
	
func on_area_exited(area_collision_shape_2d: CollisionShape2D) -> void:
	overlapping_areas.erase(area_collision_shape_2d)
	if overlapping_areas.size() == 1:
		camera.update_bounds(overlapping_areas[0])

func check_letal_tiles() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)

		if collision.get_collider() is TileMapLayer:
			var collider_rid := collision.get_collider_rid()
			var collider_layer := PhysicsServer2D.body_get_collision_layer(collider_rid)

			# Lethal layer is 8 (00001000)
			# Player could collide with a lethal object hat is also in another layer
			# If that is the case the coller_layer would have multiple bits set as 1
			# eg: 00001001 -> Layer 1 and 8 are on, collider_layer variable is 9
			# The "&" operator (bitwise and) will return 1 for each bit that is 1 in both numbers
			# The LETHAL_LAYER has only 1 bit on
			# when collider_layer does not include layer 8, the bitwise operation returns 0
			# If the result is not 0, then collision is on object that has lethal layer enabled
			if collider_layer & LETHAL_LAYER != 0:
				die()
				return

func get_tile_under_player(tilemap: TileMapLayer) -> TileData:
	var cell := tilemap.local_to_map(tilemap.to_local(global_position))
	return tilemap.get_cell_tile_data(cell)

func die() -> void:
	StatsManager.increment_stat(Stats.StatType.DEATH)
	audio_stream_player_2d.play()
	position = initial_position
