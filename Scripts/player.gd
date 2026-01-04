extends CharacterBody2D
class_name Player

const CAMERA_2D = preload("uid://bt6eq5c6omec0")

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2d

@export var environment_tile_map_layer: TileMapLayer

const LETHAL_LAYER = 8

enum PlayerState {
	IDLE,
	WALK,
	JUMP,
	FALL,
	CLIMB
}

var current_state := PlayerState.IDLE

var process_state: Dictionary[PlayerState, Callable] = {
	PlayerState.IDLE: process_idle_state,
	PlayerState.WALK: process_walk_state,
	PlayerState.JUMP: process_jump_state,
	PlayerState.FALL: process_fall_state,
	PlayerState.CLIMB: process_climb_state,
}

var on_enter_state: Dictionary[PlayerState, Callable] = {
	PlayerState.IDLE: on_idle_state,
	PlayerState.WALK: on_walk_state,
	PlayerState.JUMP: on_jump_state,
	#PlayerState.FALL: on_fall_state,
	PlayerState.CLIMB: on_climb_state
}

const SPEED: float = 200.0
const INITIAL_JUMP_Speed: float = -170.0
const HOLD_JUMP_VELOCITY: float = -180.0

const CLIMB_SPEED: int = -200

const MAX_JUMP_DELAY_AFTER_NOT_ON_FLOOR: float = 0.08
var time_since_left_floor: float = 0.0
var coyote_jump_consumed: bool = false

const MAX_JUMP_TIME := 0.2
var jump_time_used := 0.0

var MAX_JUMPS := 1
var jumps_used := 0

var overlapping_areas: Array[CollisionShape2D] = []

var camera: GameCamera2D

var initial_position: Vector2
var last_position: Vector2

var distance_walked_in_pixels_buffer: float = 0.0
const PIXEL_PER_METER_RATIO: float = 50
const DISTANCE_WALKED_BUFFER_MAX_SIZE: float = 200

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
	last_position = position
	
	MAX_JUMPS = 1
	
	if SaveDataManager.loaded_data.player_position != Vector2.INF:
		position = SaveDataManager.loaded_data.player_position

func _physics_process(delta: float) -> void:
	assert(process_state.has(current_state), "Missing function to process state %s" % current_state)

	# Add the gravity.
	if not is_on_floor() and current_state != PlayerState.JUMP:
		velocity += get_gravity() * delta
	
	process_state[current_state].call(delta)
	
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true

	move_and_slide()

	check_distance_walked()
	check_letal_tiles()

#region Process state
func process_idle_state(delta: float) -> void:
	try_move()
	try_jump(delta)
	
	var is_climbing := try_climb()
	
	if is_climbing:
		switch_state(PlayerState.CLIMB)
		return
	
	if velocity.y > 0:
		switch_state(PlayerState.FALL)
		return

func process_walk_state(delta: float) -> void:
	try_move()
	try_jump(delta)
	
	var is_climbing := try_climb()
	
	if is_climbing:
		switch_state(PlayerState.CLIMB)
		return
	if velocity.x == 0 and velocity.y == 0:
		switch_state(PlayerState.IDLE)
		return
	if velocity.y > 0:
		switch_state(PlayerState.FALL)
		return

func process_jump_state(delta: float) -> void:
	jump_time_used += delta
	
	try_move()
	try_jump(delta)
	
	if is_on_floor():
		switch_state(PlayerState.IDLE)
		return
	if Input.is_action_just_released("jump") or jump_time_used >= MAX_JUMP_TIME:
		switch_state(PlayerState.FALL)
		return

	velocity.y += HOLD_JUMP_VELOCITY * delta

func process_fall_state(delta: float) -> void:
	try_jump(delta)

	time_since_left_floor += delta
	
	# Only consume coyote jump for first jump
	if time_since_left_floor > MAX_JUMP_DELAY_AFTER_NOT_ON_FLOOR and jumps_used == 0:
		coyote_jump_consumed = true
	
	if is_on_floor():
		switch_state(PlayerState.IDLE)
		return
	
	try_move()
	
	var is_climbing := try_climb()
	
	if is_climbing:
		switch_state(PlayerState.CLIMB)
		return

func process_climb_state(_delta: float) -> void:
	try_move()
	var is_climbing := try_climb()
	
	if !is_climbing:
		switch_state(PlayerState.FALL)
		return

#endregion

func switch_state(new_state: PlayerState) -> void:
	if on_enter_state.has(new_state):
		on_enter_state[new_state].call()

	current_state = new_state

#region On state
func on_idle_state() -> void:
	jumps_used = 0
	time_since_left_floor = 0
	coyote_jump_consumed = false
	
func on_walk_state() -> void:
	jumps_used = 0
	time_since_left_floor = 0
	coyote_jump_consumed = false

func on_jump_state() -> void:
	match jumps_used:
		0:
			StatsManager.increment_stat(Stats.StatType.JUMP)
		1:
			StatsManager.increment_stat(Stats.StatType.DOUBLE_JUMP)
	
	jump_time_used = 0.0
	jumps_used += 1
	velocity.y = INITIAL_JUMP_Speed

func on_climb_state() -> void:
	# Consume one jump when starting using ladders
	# So that player can't jump out of the ladder
	jumps_used = 1

#endregion

func try_move() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# Returns if the player is climbing
func try_climb() -> bool:
	if Input.is_action_pressed("move_up"):
		var tile := get_tile_under_player(environment_tile_map_layer)

		if tile and tile.get_custom_data("climbable"):
			velocity.y = CLIMB_SPEED
			return true
	return false

func try_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and (jumps_used + (1 if coyote_jump_consumed else 0)) < MAX_JUMPS:
		switch_state(PlayerState.JUMP)
		return

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

func check_distance_walked() -> void:
	distance_walked_in_pixels_buffer += global_position.distance_to(last_position)
	last_position = global_position
	if distance_walked_in_pixels_buffer >= DISTANCE_WALKED_BUFFER_MAX_SIZE:
		StatsManager.increment_stat_by(Stats.StatType.DISTANCE_WALKED, distance_walked_in_pixels_buffer / PIXEL_PER_METER_RATIO)
		distance_walked_in_pixels_buffer = 0

func die() -> void:
	StatsManager.increment_stat(Stats.StatType.DEATH)
	audio_stream_player_2d.play()
	position = initial_position
	last_position = position
