extends CharacterBody2D

@export var base_speed = 130.0
@export var run_speed = 250.0
@export_range(0, 1) var deceleration = 0.1
@export_range(0, 1) var aceleration  = 0.1

@export var max_jumps = 2
@export var jump_force = -300.0
@export var next_jumps_force = -100.0
@export var fall_speed_multiplier = 0.5
@export var fall_speed_on_wall = 50
@export var jump_recoil_on_wall = 100.0
@export_range(0, 1) var deceleration_on_jump_release = 0.5

var jumps_count = 0

@export var dash_speed = 1000.0
@export var dash_max_distance = 300.0
@export var dash_cooldown = 1.0
@export var dash_inertia = 0.5
@export var dash_curve : Curve

var dash_enable = true # To allow recharge the dash only when on floor or on wall
var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

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
	
	# Optionally update camera position if it's a child of this node
	#if has_node("Camera2D"):
		#camera_2d.global_position = render_position

# ---------------------------------------------------------------------

func _process(delta: float) -> void:
	pass
	fix_movement_jittering()
	
# ---------------------------------------------------------------------

func _physics_process(delta):
	
	previous_position = global_position
	
	# Handle MOVEMENT
	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = base_speed
			
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	# Apply movement
	if direction:
		last_direction_pressed = direction
		velocity.x = move_toward(velocity.x, direction * speed, speed * aceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	
	# Handle JUMP.
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor() or is_on_wall():
		dash_enable = true
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		jumps_count = max_jumps
	if jumps_count == max_jumps and Input.is_action_just_pressed("jump") and not is_on_floor(): # Second jump
		velocity.y = next_jumps_force
		jumps_count -= 1
	if Input.is_action_just_pressed("jump") and is_on_wall():
		velocity.y = jump_force
		jumps_count = 2 # Recharge double-jump on wall
		velocity.x += last_direction_pressed * -1 * jump_recoil_on_wall
	if not Input.is_action_just_pressed("jump") and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and is_on_wall() and not is_on_floor():
		velocity.y *= fall_speed_on_wall * delta
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= deceleration_on_jump_release

	# Handle DASH
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_timer <= 0 and dash_enable:
		is_dashing = true
		dash_enable = false
		dash_start_position = position.x
		dash_direction = last_direction_pressed
		dash_timer = dash_cooldown
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
			velocity.x *= dash_inertia
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
	if dash_timer > 0:
		dash_timer -= delta
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	move_and_slide()
