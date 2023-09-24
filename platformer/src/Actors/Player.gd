class_name Player
extends Actor


# warning-ignore:unused_signal
signal collect_coin()

const FLOOR_DETECT_DISTANCE = 20.0
# sloope threshold in radians. 
# Anything greater will be treated like a wall: player slides down and can't jump from it
const SLOPE_THRESHOLD = 0.9
const MAX_SAFE_FALL_SPEED = 200.0


export(String) var action_suffix = ""

onready var platform_detector = $PlatformDetector
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var sound_jump = $Jump

var direction_prev
var is_airborne = false
var fall_speed = 0.0

func _ready():
	# Static types are necessary here to avoid warnings.
	var camera: Camera2D = $Camera
	if action_suffix == "_p1":
		camera.custom_viewport = $"../.."
		yield(get_tree(), "idle_frame")
		camera.make_current()
	elif action_suffix == "_p2":
		var viewport: Viewport = $"../../../../ViewportContainer2/Viewport2"
		viewport.world_2d = ($"../.." as Viewport).world_2d
		camera.custom_viewport = viewport
		yield(get_tree(), "idle_frame")
		camera.make_current()


# Physics process is a built-in loop in Godot that is called every frame.
# At a glance, you can see that the physics process loop:
# 1. Calculates the move direction.
# 2. Calculates the move velocity.
# 3. Moves the character.
# 4. Updates the sprite direction.
# 6. Updates the animation.
func _physics_process(_delta):

	if is_airborne:
		if _velocity.y > fall_speed:
			fall_speed = _velocity.y
		if is_on_floor():
			is_airborne = false
			if fall_speed > MAX_SAFE_FALL_SPEED:
				print("Ouch, you fell kinda far! (", fall_speed, ")")
				# TODO: loose health
				# TODO: fall prone for a few seconds
			fall_speed = 0.0
		
	if not is_on_floor():
		is_airborne = true
	
	if Input.is_action_just_pressed("jump" + action_suffix) and is_on_floor():
		sound_jump.play()

	var max_velocity = max_velocity_walking
	if Input.is_action_pressed("Sprint" + action_suffix):
		max_velocity = max_velocity_sprinting
		# TODO: play sprint animation
		# TODO: drain health

	var direction = get_direction()

	_velocity = calculate_move_velocity(direction, max_velocity, _delta)

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	_velocity.y = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, SLOPE_THRESHOLD, false
	).y

	# Flip character sprite so it faces the move direction
	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1

	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_direction():
	return Vector2(
		Input.get_action_strength("move_right" + action_suffix) - Input.get_action_strength("move_left" + action_suffix),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump" + action_suffix) else 0
	)


# This function calculates a new velocity whenever you need it.
func calculate_move_velocity(
		direction,
		max_velocity,
		delta
	):
	var velocity = _velocity
	
	# Horizontal velocity
	if direction != direction_prev:
		direction_prev = direction
		velocity.x = base_velocity * direction.x
	if abs(velocity.x) > abs(max_velocity):
		velocity.x = max_velocity * direction.x
	elif abs(velocity.x) != abs(max_velocity):
		velocity.x += acceleration * direction.x * delta
	
	# Vertical velocity
	if direction.y != 0.0:
		velocity.y = jump_force * direction.y
		
	return velocity


func get_new_animation():
	var animation_new = ""
	if is_on_floor():
		if abs(_velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		if _velocity.y > 0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	return animation_new
