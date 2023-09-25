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
onready var health_bar = $HUDLayer/Health/Healthbar
var direction_prev
var is_airborne = false
var fall_speed = 0.0
var is_prone = false
var prone_time = 1.5 # hardcoded to length of prone animation
var prone_timer = 0.0
var is_climbing = false

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
func _physics_process(_delta):
	handle_falling()
	handle_movement(_delta)
	handle_animation()



func get_direction():
	return Vector2(
		Input.get_action_strength("move_right" + action_suffix) - Input.get_action_strength("move_left" + action_suffix),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump" + action_suffix) else 0
	)

func handle_movement(delta):
	# Being prone disables all movement (x & y) so it could 
	# cause a bug if they should continue falling while prone
	if is_prone:
		handle_prone(delta)
		return
	if is_climbing: # movement disabled while climbing
		return
	
	# Get input
	if Input.is_action_just_pressed("jump" + action_suffix) and is_on_floor():
		sound_jump.play()
	var max_velocity = max_velocity_walking
	if Input.is_action_pressed("Sprint" + action_suffix):
		max_velocity = max_velocity_sprinting
		# TODO: drain health
	var direction = get_direction()

	# Act on input
	_velocity = calculate_move_velocity(direction, max_velocity, delta)

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

func handle_prone(delta):
	if prone_timer < prone_time:
		prone_timer += delta
	else:
		is_prone = false
		prone_timer = 0.0

func handle_falling():
	if is_airborne:
		if _velocity.y > fall_speed:
			fall_speed = _velocity.y
		if is_on_floor():
			is_airborne = false
			if fall_speed > MAX_SAFE_FALL_SPEED:
				print("Ouch, you fell kinda far! (", fall_speed, ")")
				is_prone = true
				health_bar.value -= 20 # takes damage when falling far
			fall_speed = 0.0
	if not is_on_floor():
		is_airborne = true

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

func handle_animation():
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)

func get_new_animation():
	var animation_new = ""
	if is_on_floor():
		if is_prone:
			animation_new = "prone"
		elif abs(_velocity.x) > 0.1:
			animation_new = "walk"
			if abs(_velocity.x) > max_velocity_walking:
				animation_new = "run"
		else:
			animation_new = "idle"
	else:
		if _velocity.y > 0:
			animation_new = "fall"
		else:
			animation_new = "jump"
	return animation_new
