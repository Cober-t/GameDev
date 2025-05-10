extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var previous_position: Vector2 = Vector2.ZERO
var render_position: Vector2 = Vector2.ZERO
var sprite_offset: Vector2 = Vector2.ZERO

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D


# ---------------------------------------------------------------------

func _ready():
	previous_position = global_position
	render_position = global_position
	sprite_offset = animated_sprite.position
	
# ---------------------------------------------------------------------

func fix_movement_jittering():
	# Calculate interpolation factor based on how far we are through the current frame
	var interpolation_factor = Engine.get_physics_interpolation_fraction()
	
	# Interpolate between previous and current position
	render_position = previous_position.lerp(global_position, interpolation_factor)
	render_position += sprite_offset
	
	# For a platformer, we need to handle this differently
	# Only interpolate the X position, keep Y position synced with physics body
	# This prevents the character from appearing inside the floor
	if animated_sprite:
		animated_sprite.global_position = render_position
	
	# Optionally update camera position if it's a child of this node
	if has_node("Camera2D"):
		camera_2d.global_position = render_position

# ---------------------------------------------------------------------

func _process(delta: float) -> void:
	fix_movement_jittering()
	
# ---------------------------------------------------------------------

func _physics_process(delta):
	
	previous_position = global_position
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
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
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
