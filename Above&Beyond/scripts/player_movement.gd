# PlayerController.gd
# Main controller script that manages player movement and physics
class_name PlayerController
extends CharacterBody2D

# Component references
@onready var movement_comp: MovementComponent
@onready var physics_comp: PhysicsComponent

# Godot's gravity from project settings5
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)

func _ready():
	# Get or create components
	movement_comp = get_node("MovementComponent") if has_node("MovementComponent") else null
	physics_comp = get_node("PhysicsComponent") if has_node("PhysicsComponent") else null
	
	if not movement_comp:
		movement_comp = MovementComponent.new()
		add_child(movement_comp)
	
	if not physics_comp:
		physics_comp = PhysicsComponent.new()
		add_child(physics_comp)
	
	# Initialize physics
	_initialize_physics()

func _initialize_physics():
	# Calculate ground gravity based on jump parameters
	# Note: In Godot, we want positive gravity for downward movement
	physics_comp.ground_gravity = (2.0 * movement_comp.jump_height) / pow(movement_comp.time_to_jump_apex, 2)

func _physics_process(delta):
	_handle_input()
	_update_movement(delta)
	_update_physics(delta)
	move_and_slide()
	_update_collision_state()

func _handle_input():
	if not movement_comp.can_move:
		return
		
	# Get horizontal input
	movement_comp.direction = Input.get_axis("move_left", "move_right")
	movement_comp.pressing_key = movement_comp.direction != 0.0
	
	# Get jump input
	movement_comp.pressing_jump = Input.is_action_pressed("jump")
	if Input.is_action_just_pressed("jump"):
		movement_comp.desired_jump = true

func _update_movement(delta):
	if not movement_comp.can_move:
		return
		
	# Calculate desired velocity
	movement_comp.desired_velocity.x = movement_comp.direction * max(movement_comp.max_speed - physics_comp.friction, 0.0)
	
	# Update movement based on acceleration settings
	if movement_comp.use_acceleration:
		_run_with_acceleration(delta)
	else:
		_run_without_acceleration()
	
	# Handle jumping
	_calculate_jump_buffer(delta)
	_calculate_variable_jump(delta)
	_calculate_coyote_time(delta)
	_do_a_jump(delta)
	
	# Handle variable jump height
	if movement_comp.variable_jump_height and velocity.y < -0.01 and not movement_comp.on_floor:
		_handle_variable_jump_height(delta)

func _run_with_acceleration(delta):
	var mv = movement_comp
	
	# Set acceleration values based on ground state
	mv.acceleration = mv.max_acceleration if mv.on_floor else mv.max_air_acceleration
	mv.deceleration = mv.max_deceleration if mv.on_floor else mv.max_air_deceleration
	mv.turn_speed = mv.max_turn_speed if mv.on_floor else mv.max_air_turn_speed
	
	if mv.pressing_key:
		# Check if we're turning around
		if sign(mv.direction) != sign(velocity.x):
			mv.max_speed_change = mv.turn_speed * delta
		else:
			mv.max_speed_change = mv.acceleration * delta
	else:
		mv.max_speed_change = mv.deceleration * delta
	
	velocity.x = _move_towards(velocity.x, mv.desired_velocity.x, mv.max_speed_change)

func _run_without_acceleration():
	velocity.x = movement_comp.desired_velocity.x

func _move_towards(current: float, target: float, step_speed: float) -> float:
	var difference = target - current
	if abs(difference) <= step_speed:
		return target
	return current + step_speed if difference > 0 else current - step_speed

func _calculate_jump_buffer(delta):
	var mv = movement_comp
	if mv.jump_buffer <= 0:
		return
		
	if not mv.desired_jump:
		return
		
	mv.jump_buffer_counter += delta
	if mv.jump_buffer_counter > mv.jump_buffer:
		mv.desired_jump = false
		mv.jump_buffer_counter = 0.0

func _calculate_coyote_time(delta):
	var mv = movement_comp
	if mv.on_floor:
		mv.coyote_time_counter = 0.0
	else:
		mv.coyote_time_counter += delta

func _calculate_variable_jump(delta):
	var mv = movement_comp
	if not mv.variable_jump_height:
		return
		
	mv.jump_hold_time = mv.jump_hold_time + delta if mv.pressing_jump else 0.0

func _do_a_jump(_delta):
	var mv = movement_comp
	if not mv.desired_jump:
		return
		
	# Check jump conditions
	var can_jump = mv.on_floor or (mv.coyote_time_counter > 0.03 and mv.coyote_time_counter < mv.coyote_time) or mv.air_jumps > 0
	
	if can_jump:
		mv.desired_jump = false
		mv.jump_buffer_counter = 0.0
		
		# Use air jump if not on floor and past coyote time
		if not mv.on_floor and mv.coyote_time_counter > mv.coyote_time:
			mv.air_jumps -= 1
		
		# Calculate jump force
		mv.jump_force = sqrt(2.0 * gravity * (physics_comp.ground_gravity / gravity) * mv.jump_height)
		
		# Adjust jump force based on current velocity
		if velocity.y < 0.0:
			mv.jump_force = max(mv.jump_force + velocity.y, 0.0)
		elif velocity.y > 0.0:
			mv.jump_force = mv.jump_force + abs(velocity.y) # * 0.85
		
		# Apply jump (negative Y for upward movement in Godot)
		velocity.y = velocity.y - mv.jump_force
		mv.currently_jumping = true
		
		# Initialize variable jump tracking
		if mv.variable_jump_height:
			mv.jump_start_time = Time.get_unix_time_from_system()
			mv.jump_minimum_reached = false
	
	if mv.jump_buffer == 0:
		mv.desired_jump = false

func _update_physics(delta):
	var mv = movement_comp
	var rb = physics_comp
	
	# Calculate gravity scale
	rb.gravity_scale = (rb.ground_gravity / gravity) * rb.gravity_multiplier
	
	# Update movement component velocity from physics
	mv.velocity.y = velocity.y
	
	if not mv.desired_jump:
		_calculate_gravity(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta * rb.gravity_scale
		
		# Limit fall speed (positive values since we're falling down)
		if velocity.y > 0.01:
			velocity.y = min(velocity.y, mv.fall_speed_limit)

func _calculate_gravity(_delta):
	var mv = movement_comp
	var rb = physics_comp
	
	# Change gravity based on vertical movement direction
	if velocity.y < -0.01:  # Going up
		if mv.on_floor:
			rb.gravity_multiplier = rb.default_gravity_scale
		else:
			if not mv.variable_jump_height:
				rb.gravity_multiplier = mv.upward_movement_multiplier
	elif velocity.y > 0.01:  # Going down
		if mv.on_floor:
			rb.gravity_multiplier = rb.default_gravity_scale
		else:
			rb.gravity_multiplier = mv.downward_movement_multiplier
			# Reset jump state when falling
			if mv.variable_jump_height and mv.currently_jumping:
				mv.currently_jumping = false
	else:  # Not moving vertically
		if mv.on_floor:
			mv.currently_jumping = false
			if mv.variable_jump_height:
				mv.jump_minimum_reached = false
		rb.gravity_multiplier = rb.default_gravity_scale

func _handle_variable_jump_height(_delta):
	var mv = movement_comp
	var rb = physics_comp
	
	if not mv.currently_jumping:
		rb.gravity_multiplier = mv.upward_movement_multiplier
		return
	
	# Calculate jump duration
	var current_time = Time.get_unix_time_from_system()
	var jump_duration = current_time - mv.jump_start_time
	
	# Check minimum jump time
	if jump_duration >= mv.min_jump_hold_time:
		mv.jump_minimum_reached = true
	
	# Apply gravity based on jump state
	if mv.pressing_jump:
		if jump_duration < mv.max_jump_hold_time:
			rb.gravity_multiplier = mv.upward_movement_multiplier * mv.jump_hold_gravity_multiplier
		else:
			rb.gravity_multiplier = mv.upward_movement_multiplier
	else:
		if mv.jump_minimum_reached:
			rb.gravity_multiplier = mv.upward_movement_multiplier * mv.jump_release_gravity_multiplier
		else:
			rb.gravity_multiplier = mv.upward_movement_multiplier * mv.jump_hold_gravity_multiplier
	
	# Optional peak floatiness
	if mv.enable_peak_floatiness and abs(velocity.y) < mv.peak_velocity_threshold:
		rb.gravity_multiplier *= mv.peak_gravity_multiplier

func _update_collision_state():
	var mv = movement_comp
	
	# Update floor state
	var was_on_floor = mv.on_floor
	mv.on_floor = is_on_floor()
	
	# Reset air jumps when landing
	if mv.on_floor and not was_on_floor:
		mv.air_jumps = mv.max_air_jumps
