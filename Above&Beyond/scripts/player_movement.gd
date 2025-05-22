extends CharacterBody2D

@export var base_speed :float = 130.0
@export var run_speed :float = 250.0
@export_range(0, 1) var deceleration :float = 0.1
@export_range(0, 1) var aceleration  :float = 0.1
@onready var camera_2d: Camera2D = $"../Camera2D"

@export var max_jumps :int = 2
@export var jump_force :float = -300.0
@export var next_jumps_force :float = -100.0
@export var fall_speed_multiplier :float = 0.5
@export var fall_speed_on_wall :float = 45.0
@export var jump_recoil_on_wall :float = 100.0
@export_range(0, 1) var deceleration_on_jump_release :float = 0.5

var jumps_count :int = 0

@export var dash_speed :float = 1000.0
@export var dash_max_time :float = 0.5
@export var dash_cooldown :float = 1.0
@export var dash_inertia :float = 0.5
@export var dash_curve : Curve

var dash_enable :bool = true # To allow recharge the dash only when on floor or on wall
var is_dashing :bool = false
var dash_start_time :float = 0.0
var dash_direction :int = 0
var dash_cooldown_timer :float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var previous_position: Vector2 = Vector2.ZERO
var render_position: Vector2 = Vector2.ZERO
var sprite_offset: Vector2 = Vector2.ZERO
var last_direction_pressed: int = 1

@onready var animated_sprite = $AnimatedSprite2D


# ---------------------------------------------------------------------

func _ready():
	gravity *= fall_speed_multiplier
	previous_position = global_position
	render_position = global_position
	sprite_offset = animated_sprite.position
	
# ---------------------------------------------------------------------

func fix_movement_jittering():
	# Calculate interpolation factor based on how far we are through the current frame
	var interpolation_factor = Engine.get_physics_interpolation_fraction()
	
	# Interpolate between previous and current position
	render_position = previous_position.lerp(global_position, interpolation_factor)
	# This prevents the character from appearing inside the floor
	render_position += sprite_offset
	
	if animated_sprite:
		animated_sprite.global_position = render_position
	#if camera_2d:
		#camera_2d.global_position = render_position

# ---------------------------------------------------------------------

func _process(delta: float) -> void:
	pass
	#fix_movement_jittering()
		
func _physics_process(delta: float) -> void:
	previous_position = global_position
	
	var direction = Global.moving_direction()
	#handle_dash(delta)
	#handle_jump(delta)
	handle_movement(direction)
	#play_animations(direction)
	
	move_and_slide()
	
# ---------------------------------------------------------------------

func handle_movement(dir: float) ->void:
	var speed = run_speed if Global.is_running() else base_speed
	
	# Get the input direction: -1, 0, 1
	if dir and not is_dashing:
		last_direction_pressed = int(dir) # TODO: Handle it better for the controller
		velocity.x = move_toward(velocity.x, dir * speed, speed * aceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)

# ---------------------------------------------------------------------

func handle_jump(delta: float) ->void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if Global.is_jumping() and is_on_floor():
		velocity.y = jump_force
		jumps_count = max_jumps - 1
	if jumps_count > 0 and Global.is_jumping() and not is_on_floor(): # Second jump
		velocity.y = next_jumps_force
		jumps_count -= 1
	if Global.is_jumping() and is_on_wall():
		velocity.y = jump_force
		jumps_count = max_jumps - 1 # Recharge double-jump on wall
		velocity.x += last_direction_pressed * -1 * jump_recoil_on_wall
	if not Global.is_jumping() and (Global.is_moving_left() or Global.is_moving_right()) and is_on_wall() and not is_on_floor():
		velocity.y *= fall_speed_on_wall * delta
	if Global.is_jumping_released() and velocity.y < 0:
		velocity.y *= deceleration_on_jump_release

# ---------------------------------------------------------------------

func handle_dash(delta: float) ->void:
	if is_on_floor() or is_on_wall():
		dash_enable = true
	if Global.is_dashing() and not is_dashing and dash_cooldown_timer <= 0 and dash_enable:
		is_dashing = true
		dash_enable = false
		dash_start_time = Time.get_ticks_msec()
		if is_on_wall():
			last_direction_pressed *= -1
		dash_direction = last_direction_pressed
		dash_cooldown_timer = dash_cooldown
	if is_dashing:
		var current_time = abs(Time.get_ticks_msec() - dash_start_time) / 1000
		if current_time >= dash_max_time:
			is_dashing = false
			velocity.x *= dash_inertia
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_time / dash_max_time)
			velocity.y = 0
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

# ---------------------------------------------------------------------

func play_animations(dir: float) ->void:
	# Flip the Sprite
	if last_direction_pressed > 0:
		animated_sprite.flip_h = false
	elif last_direction_pressed < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if dir == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

# ---------------------------------------------------------------------
